import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import '../clubbloc.dart';
import '../data/clubblocstate.dart';
import 'data/singleclubbloc.dart';

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
  final BuiltList<InviteToClub> invites;

  _SingleClubInvitesAdded({@required this.invites});

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific club.
///
class SingleClubBloc
    extends AsyncHydratedBloc<SingleClubEvent, SingleClubState> {
  final ClubBloc clubBloc;
  String _clubUid;

  static String createNew = "new";

  String get clubUid => _clubUid;

  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<InviteToClub>> _inviteSub;

  SingleClubBloc({@required this.clubBloc, @required String clubUid})
      : super(
            clubBloc.state.clubs.containsKey(clubUid)
                ? SingleClubLoaded(
                    (b) => b..club = clubBloc.state.clubs[clubUid].toBuilder())
                : SingleClubDeleted(),
            "Singleclub" + clubUid) {
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
      yield (SingleClubLoaded.fromState(state)
            ..club = event.newClub.toBuilder())
          .build();
    }

    // The club is deleted.
    if (event is _SingleClubDeleted) {
      yield SingleClubDeleted.fromState(state).build();
    }

    // Save the club.
    if (event is SingleClubUpdate) {
      yield SingleClubSaving.fromState(state).build();
      try {
        Club club = event.club;
        if (event.image != null) {
          Uri clubUri = await clubBloc.coordinationBloc.databaseUpdateModel
              .updateClubImage(state.club, event.image);
          club = club.rebuild((b) => b..photoUrl = clubUri.toString());
        }
        await clubBloc.coordinationBloc.databaseUpdateModel
            .updateClub(club, includeMembers: event.includeMembers);
        yield (SingleClubLoaded.fromState(state)..club = event.club.toBuilder())
            .build();
      } catch (e) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
      }
    }

    if (event is SingleClubUpdateImage) {
      yield SingleClubSaving.fromState(state).build();
      try {
        Uri clubUri = await clubBloc.coordinationBloc.databaseUpdateModel
            .updateClubImage(state.club, event.image);

        yield (SingleClubLoaded.fromState(state)
              ..club = (state.club.toBuilder()..photoUrl = clubUri.toString()))
            .build();
      } catch (e) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
      }
    }

    // Create a new club.
    if (event is SingleClubAdd) {
      yield SingleClubSaving.fromState(state).build();
      try {
        _clubUid = await clubBloc.coordinationBloc.databaseUpdateModel
            .addClub(null, event.newClub);
        yield (SingleClubLoaded.fromState(state)
              ..club = event.newClub.toBuilder())
            .build();
      } catch (e) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
      }
    }

    if (event is SingleClubAddMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .addUserToClub(clubUid, event.adminUid, event.admin);
        yield SingleClubLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
      }
    }

    if (event is SingleClubDeleteMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel
            .deleteClubMember(state.club, event.adminUid);
        yield SingleClubLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
      }
    }

    if (event is SingleClubInviteMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await clubBloc.coordinationBloc.databaseUpdateModel.inviteUserToClub(
            clubName: state.club.name,
            email: event.email,
            admin: event.admin,
            clubUid: clubUid);
        yield SingleClubLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
      }
    }

    if (event is _SingleClubInvitesAdded) {
      yield (SingleClubLoaded.fromState(state)
            ..invites = event.invites.toBuilder())
          .build();
    }

    if (event is SingleClubLoadInvites) {
      _inviteSub = clubBloc.coordinationBloc.databaseUpdateModel
          .getInviteToClubStream(clubUid)
          .listen((Iterable<InviteToClub> invites) {
        add(_SingleClubInvitesAdded(invites: invites));
      });
    }
  }

  @override
  SingleClubState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleClubUninitialized();
    }

    SingleClubBlocStateType type =
        SingleClubBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleClubBlocStateType.Uninitialized:
        return SingleClubUninitialized();
      case SingleClubBlocStateType.Loaded:
        return SingleClubLoaded.fromMap(json);
      case SingleClubBlocStateType.Deleted:
        return SingleClubDeleted.fromMap(json);
      case SingleClubBlocStateType.SaveFailed:
        return SingleClubSaveFailed.fromMap(json);
      case SingleClubBlocStateType.Saving:
        return SingleClubSaving.fromMap(json);
    }
  }

  @override
  Map<String, dynamic> toJson(SingleClubState state) {
    return state.toMap();
  }
}
