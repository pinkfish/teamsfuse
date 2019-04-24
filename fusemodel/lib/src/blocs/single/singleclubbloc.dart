import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'clubbloc.dart';

abstract class SingleClubState extends Equatable {
  final Club club;
  final Iterable<Team> teams;
  final Iterable<InviteToClub> invites;

  SingleClubState(
      {@required this.club, @required this.teams, @required this.invites});
}

///
/// We have a club, default state.
///
class SingleClubLoaded extends SingleClubState {
  SingleClubLoaded(
      {@required Club club,
      @required Iterable<Team> teams,
      @required Iterable<InviteToClub> invites})
      : super(club: club, teams: teams, invites: invites);

  SingleClubLoaded.copy(SingleClubState state)
      : super(club: state.club, teams: state.teams, invites: state.invites);

  @override
  String toString() {
    return 'SingleClubLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleClubSaving extends SingleClubState {
  SingleClubSaving({@required SingleClubState singleClubState})
      : super(
            club: singleClubState.club,
            teams: singleClubState.teams,
            invites: singleClubState.invites);

  @override
  String toString() {
    return 'SingleClubSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleClubSaveFailed extends SingleClubState {
  final Error error;

  SingleClubSaveFailed({@required SingleClubState singleClubState, this.error})
      : super(
            club: singleClubState.club,
            teams: singleClubState.teams,
            invites: singleClubState.invites);

  @override
  String toString() {
    return 'SingleClubSaveFailed{}';
  }
}

///
/// Club got deleted.
///
class SingleClubDeleted extends SingleClubState {
  SingleClubDeleted(@required SingleClubState state)
      : super(club: state.club, teams: state.teams, invites: state.invites);

  SingleClubDeleted.empty() : super(club: null, teams: {}, invites: []);

  @override
  String toString() {
    return 'SingleClubDeleted{}';
  }
}

abstract class SingleClubEvent extends Equatable {}

///
/// Updates the club (writes it out to firebase.
///
class SingleClubUpdate extends SingleClubEvent {
  final Club club;
  final bool includeMembers;

  SingleClubUpdate({@required this.club, this.includeMembers = false});
}

///
/// Loads the invites for this club.
///
class SingleClubLoadInvites extends SingleClubEvent {
  SingleClubLoadInvites();
}

///
/// Adds the club writes it out to firebase.
///
class SingleClubAdd extends SingleClubEvent {
  final Club newClub;

  SingleClubAdd({@required this.newClub});
}

///
/// Updates the image for the club.
///
class SingleClubUpdateImage extends SingleClubEvent {
  final File image;

  SingleClubUpdateImage({@required this.image});
}

///
/// Adds an admin to the club.
///
class SingleClubAddMember extends SingleClubEvent {
  final String adminUid;
  final bool admin;

  SingleClubAddMember({@required this.adminUid, this.admin});
}

///
/// Deletes an admin from the club.
///
class SingleClubDeleteMember extends SingleClubEvent {
  final String adminUid;

  SingleClubDeleteMember({@required this.adminUid});
}

///
/// Invites someone to be an admin for this club.
///
class SingleClubInviteMember extends SingleClubEvent {
  final String email;
  final bool admin;

  SingleClubInviteMember({@required this.email, this.admin = false});
}

///
/// Delete this club from the world.
///
class SingleClubDelete extends SingleClubEvent {
  SingleClubDelete();
}

///
/// Loads the teams from firebase.
///
class SingleClubLoadTeams extends SingleClubEvent {
  SingleClubLoadTeams();
}

class _SingleClubNewClub extends SingleClubEvent {
  final Club newClub;

  _SingleClubNewClub({@required this.newClub});
}

class _SingleClubDeleted extends SingleClubEvent {
  _SingleClubDeleted();
}

class _SingleClubInvitesAdded extends SingleClubEvent {
  final Iterable<InviteToClub> invites;

  _SingleClubInvitesAdded({@required this.invites});
}

///
/// Bloc to handle updates and state of a specific club.
///
class SingleClubBloc extends Bloc<SingleClubEvent, SingleClubState> {
  final ClubBloc clubBloc;
  String _clubUid;

  static String createNew = "new";

  String get clubUid => _clubUid;

  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<InviteToClub>> _inviteSub;

  SingleClubBloc({@required this.clubBloc, @required String clubUid}) {
    _clubUid = clubUid;
    _clubSub = clubBloc.state.listen((ClubState state) {
      Club club = state.clubs[clubUid];
      if (club != null) {
        // Only send this if the club is not the same.
        if (club != currentState.club) {
          dispatch(_SingleClubNewClub(newClub: club));
        }
      } else {
        dispatch(_SingleClubDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _clubSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  SingleClubState get initialState {
    if (clubBloc.currentState.clubs.containsKey(clubUid)) {
      return SingleClubLoaded(
          club: clubBloc.currentState.clubs[clubUid], teams: {}, invites: []);
    }
    return SingleClubDeleted.empty();
  }

  @override
  Stream<SingleClubState> mapEventToState(SingleClubEvent event) async* {
    if (event is _SingleClubNewClub) {
      yield SingleClubLoaded(
          club: event.newClub,
          teams: currentState.teams,
          invites: currentState.invites);
    }

    // The club is deleted.
    if (event is _SingleClubDeleted) {
      yield SingleClubDeleted(currentState);
    }

    // Save the club.
    if (event is SingleClubUpdate) {
      yield SingleClubSaving(singleClubState: currentState);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .updateClub(event.club, includeMembers: event.includeMembers);
        yield SingleClubLoaded(club: event.club, teams: currentState.teams);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: currentState, error: e);
      }
    }

    // Create a new club.
    if (event is SingleClubAdd) {
      yield SingleClubSaving(singleClubState: currentState);
      try {
        _clubUid = await clubBloc.coordinationBloc.databaseUpdateModel
            .addClub(null, event.newClub);
        yield SingleClubLoaded(
            invites: currentState.invites,
            club: event.newClub,
            teams: currentState.teams);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: currentState, error: e);
      }
    }

    if (event is SingleClubAddMember) {
      yield SingleClubSaving(singleClubState: currentState);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .addUserToClub(clubUid, event.adminUid, event.admin);
        yield SingleClubLoaded.copy(currentState);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: currentState, error: e);
      }
    }

    if (event is SingleClubDeleteMember) {
      yield SingleClubSaving(singleClubState: currentState);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .deleteClubMember(currentState.club, event.adminUid);
        yield SingleClubLoaded.copy(currentState);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: currentState, error: e);
      }
    }

    if (event is SingleClubInviteMember) {
      yield SingleClubSaving(singleClubState: currentState);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel.inviteUserToClub(
            clubName: currentState.club.name,
            email: event.email,
            admin: event.admin,
            clubUid: clubUid);
        yield SingleClubLoaded(
            club: currentState.club,
            invites: currentState.invites,
            teams: currentState.teams);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: currentState, error: e);
      }
    }

    if (event is _SingleClubInvitesAdded) {
      yield SingleClubLoaded(
          club: currentState.club,
          teams: currentState.teams,
          invites: event.invites);
    }

    if (event is SingleClubLoadInvites) {
      _inviteSub = clubBloc.coordinationBloc.databaseUpdateModel
          .getInviteToClubStream(clubUid)
          .listen((Iterable<InviteToClub> invites) {
        dispatch(_SingleClubInvitesAdded(invites: invites));
      });
    }
  }
}
