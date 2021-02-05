import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

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
/// Loads the teams from firebase.  If the public flag is set then only
/// public teams are loaded.
///
class SingleClubLoadTeams extends SingleClubEvent {
  bool publicLoad;

  SingleClubLoadTeams(this.publicLoad);

  @override
  List<Object> get props => [];
}

class _SingleClubNewClub extends SingleClubEvent {
  final Club newClub;

  _SingleClubNewClub({@required this.newClub});

  @override
  List<Object> get props => [newClub];
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
  List<Object> get props => [invites];
}

class _SingleClubTeamsAdded extends SingleClubEvent {
  final BuiltList<Team> teams;

  _SingleClubTeamsAdded({@required this.teams});

  @override
  List<Object> get props => [teams];
}

///
/// Bloc to handle updates and state of a specific club.
///
class SingleClubBloc
    extends AsyncHydratedBloc<SingleClubEvent, SingleClubState> {
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;
  final String clubUid;

  static String createNew = "new";

  StreamSubscription<Club> _clubSub;
  StreamSubscription<Iterable<InviteToClub>> _inviteSub;

  StreamSubscription<BuiltList<Team>> _teamSub;

  SingleClubBloc(
      {@required this.db, @required this.clubUid, @required this.crashes})
      : super(SingleClubUninitialized(), "Singleclub" + clubUid) {
    _clubSub = db.getClubData(clubUid: clubUid).listen((club) {
      if (club != null) {
        add(_SingleClubNewClub(newClub: club));
      } else {
        add(_SingleClubDeleted());
      }
    });
    _clubSub.onError((e, stack) {
      print("Error loading the club '$clubUid'");
      add(_SingleClubDeleted());
      if (e is Exception) {
        crashes.recordException(e, stack);
      } else if (e is Error) {
        crashes.recordError(e, stack);
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
          Uri clubUri = await db.updateClubImage(
              state.club, await event.image.readAsBytes());
          club = club.rebuild((b) => b..photoUrl = clubUri.toString());
        }
        await db.updateClub(club, includeMembers: event.includeMembers);
        yield SingleClubSaveDone.fromState(state).build();
        yield (SingleClubLoaded.fromState(state)..club = event.club.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubUpdateImage) {
      yield SingleClubSaving.fromState(state).build();
      try {
        Uri clubUri = await db.updateClubImage(
            state.club, await event.image.readAsBytes());

        yield SingleClubSaveDone.fromState(state).build();
        yield (SingleClubLoaded.fromState(state)
              ..club = (state.club.toBuilder()..photoUrl = clubUri.toString()))
            .build();
      } catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubAddMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await db.addUserToClub(clubUid, event.adminUid, event.admin);
        yield SingleClubSaveDone.fromState(state).build();
        yield SingleClubLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubDeleteMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await db.deleteClubMember(state.club, event.adminUid);
        yield SingleClubSaveDone.fromState(state).build();
        yield SingleClubLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubInviteMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await db.inviteUserToClub(
            clubName: state.club.name,
            email: event.email,
            admin: event.admin,
            clubUid: clubUid);
        yield SingleClubSaveDone.fromState(state).build();
        yield SingleClubLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is _SingleClubInvitesAdded) {
      yield (SingleClubLoaded.fromState(state)
            ..invites = event.invites.toBuilder())
          .build();
    }

    if (event is SingleClubLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = db
            .getInviteToClubStream(clubUid)
            .listen((Iterable<InviteToClub> invites) {
          add(_SingleClubInvitesAdded(invites: invites));
        });
      }
    }

    if (event is SingleClubLoadTeams) {
      try {
        if (_teamSub == null && state is SingleClubLoaded) {
          _teamSub = db
              .getClubTeams(state.club, event.publicLoad)
              .listen((Iterable<Team> teams) {
            add(_SingleClubTeamsAdded(teams: teams));
          });
          _teamSub.onError((e, stack) {
            if (e is Exception) {
              crashes.recordException(e, stack);
              if (e is FirebaseException) {
                if (e.code == 'permission-denied') {
                  add(_SingleClubTeamsAdded(teams: BuiltList.of([])));
                }
              }
            } else if (e is Error) {
              crashes.recordError(e, stack);
            }
          });
        }
      } catch (e, stack) {
        crashes.recordException(e, stack);
        if (e is FirebaseException) {
          if (e.code == 'permission-denied') {
            yield (SingleClubLoaded.fromState(state)
                  ..teams = ListBuilder()
                  ..loadedTeams = true)
                .build();
          }
        }
      }
    }

    if (event is _SingleClubTeamsAdded) {
      yield (SingleClubLoaded.fromState(state)
            ..teams = event.teams.toBuilder()
            ..loadedTeams = true)
          .build();
    }
  }

  @override
  SingleClubState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleClubUninitialized();
    }

    try {
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
        case SingleClubBlocStateType.SaveDone:
          return SingleClubSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
      print(e);
    }

    return SingleClubUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleClubState state) {
    return state.toMap();
  }
}
