import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../clubbloc.dart';
import '../data/clubblocstate.dart';

abstract class SingleClubState extends Equatable {
  final Club club;
  final Iterable<Team> teams;
  final Iterable<InviteToClub> invites;

  SingleClubState(
      {@required this.club, @required this.teams, @required this.invites});

  @override
  List<Object> get props => [club, teams, invites];
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
  final File image;

  SingleClubUpdate(
      {@required this.club, this.includeMembers = false, this.image});

  @override
  List<Object> get props => [club, includeMembers, image];
}

///
/// Loads the invites for this club.
///
class SingleClubLoadInvites extends SingleClubEvent {
  SingleClubLoadInvites();

  @override
  List<Object> get props => [];
}

///
/// Adds the club writes it out to firebase.
///
class SingleClubAdd extends SingleClubEvent {
  final Club newClub;

  SingleClubAdd({@required this.newClub});

  @override
  List<Object> get props => [newClub];
}

///
/// Updates the image for the club.
///
class SingleClubUpdateImage extends SingleClubEvent {
  final File image;

  SingleClubUpdateImage({@required this.image});

  @override
  List<Object> get props => [image];
}

///
/// Adds an admin to the club.
///
class SingleClubAddMember extends SingleClubEvent {
  final String adminUid;
  final bool admin;

  SingleClubAddMember({@required this.adminUid, this.admin});

  @override
  List<Object> get props => [adminUid, admin];
}

///
/// Deletes an admin from the club.
///
class SingleClubDeleteMember extends SingleClubEvent {
  final String adminUid;

  SingleClubDeleteMember({@required this.adminUid});

  @override
  List<Object> get props => [adminUid];
}

///
/// Invites someone to be an admin for this club.
///
class SingleClubInviteMember extends SingleClubEvent {
  final String email;
  final bool admin;

  SingleClubInviteMember({@required this.email, this.admin = false});

  @override
  List<Object> get props => [email, admin];
}

///
/// Delete this club from the world.
///
class SingleClubDelete extends SingleClubEvent {
  SingleClubDelete();

  @override
  List<Object> get props => [];
}

///
/// Loads the teams from firebase.
///
class SingleClubLoadTeams extends SingleClubEvent {
  SingleClubLoadTeams();

  @override
  List<Object> get props => [];
}

class _SingleClubNewClub extends SingleClubEvent {
  final Club newClub;

  _SingleClubNewClub({@required this.newClub});

  @override
  List<Object> get props => [];
}

class _SingleClubDeleted extends SingleClubEvent {
  _SingleClubDeleted();

  @override
  List<Object> get props => [];
}

class _SingleClubInvitesAdded extends SingleClubEvent {
  final Iterable<InviteToClub> invites;

  _SingleClubInvitesAdded({@required this.invites});

  @override
  List<Object> get props => [];
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

  SingleClubBloc({@required this.clubBloc, @required String clubUid})
      : super(clubBloc.state.clubs.containsKey(clubUid)
            ? SingleClubLoaded(
                club: clubBloc.state.clubs[clubUid], teams: {}, invites: [])
            : SingleClubDeleted.empty()) {
    _clubUid = clubUid;
    _clubSub = clubBloc.listen((ClubState clubState) {
      Club club = clubState.clubs[clubUid];
      if (club != null) {
        // Only send this if the club is not the same.
        if (club != state.club) {
          add(_SingleClubNewClub(newClub: club));
        }
      } else {
        add(_SingleClubDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _clubSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  SingleClubState get initialState {
    ;
  }

  @override
  Stream<SingleClubState> mapEventToState(SingleClubEvent event) async* {
    if (event is _SingleClubNewClub) {
      yield SingleClubLoaded(
          club: event.newClub, teams: state.teams, invites: state.invites);
    }

    // The club is deleted.
    if (event is _SingleClubDeleted) {
      yield SingleClubDeleted(state);
    }

    // Save the club.
    if (event is SingleClubUpdate) {
      yield SingleClubSaving(singleClubState: state);
      try {
        Club club = event.club;
        if (event.image != null) {
          Uri clubUri = await clubBloc.coordinationBloc.databaseUpdateModel
              .updateClubImage(state.club, event.image);
          club = club.rebuild((b) => b..photoUrl = clubUri.toString());
        }
        await clubBloc.coordinationBloc.databaseUpdateModel
            .updateClub(club, includeMembers: event.includeMembers);
        yield SingleClubLoaded(
            club: event.club, teams: state.teams, invites: state.invites);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: state, error: e);
      }
    }

    if (event is SingleClubUpdateImage) {
      yield SingleClubSaving(singleClubState: state);
      try {
        Uri clubUri = await clubBloc.coordinationBloc.databaseUpdateModel
            .updateClubImage(state.club, event.image);

        yield SingleClubLoaded(
            club: state.club.rebuild((b) => b..photoUrl = clubUri.toString()),
            teams: state.teams,
            invites: state.invites);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: state, error: e);
      }
    }

    // Create a new club.
    if (event is SingleClubAdd) {
      yield SingleClubSaving(singleClubState: state);
      try {
        _clubUid = await clubBloc.coordinationBloc.databaseUpdateModel
            .addClub(null, event.newClub);
        yield SingleClubLoaded(
            invites: state.invites, club: event.newClub, teams: state.teams);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: state, error: e);
      }
    }

    if (event is SingleClubAddMember) {
      yield SingleClubSaving(singleClubState: state);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .addUserToClub(clubUid, event.adminUid, event.admin);
        yield SingleClubLoaded.copy(state);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: state, error: e);
      }
    }

    if (event is SingleClubDeleteMember) {
      yield SingleClubSaving(singleClubState: state);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .deleteClubMember(state.club, event.adminUid);
        yield SingleClubLoaded.copy(state);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: state, error: e);
      }
    }

    if (event is SingleClubInviteMember) {
      yield SingleClubSaving(singleClubState: state);
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel.inviteUserToClub(
            clubName: state.club.name,
            email: event.email,
            admin: event.admin,
            clubUid: clubUid);
        yield SingleClubLoaded(
            club: state.club, invites: state.invites, teams: state.teams);
      } catch (e) {
        yield SingleClubSaveFailed(singleClubState: state, error: e);
      }
    }

    if (event is _SingleClubInvitesAdded) {
      yield SingleClubLoaded(
          club: state.club, teams: state.teams, invites: event.invites);
    }

    if (event is SingleClubLoadInvites) {
      _inviteSub = clubBloc.coordinationBloc.databaseUpdateModel
          .getInviteToClubStream(clubUid)
          .listen((Iterable<InviteToClub> invites) {
        add(_SingleClubInvitesAdded(invites: invites));
      });
    }
  }
}
