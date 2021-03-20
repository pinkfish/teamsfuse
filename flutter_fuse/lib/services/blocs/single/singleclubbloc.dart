import 'dart:async';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

///
/// The base class for all the single club events.
///
abstract class SingleClubEvent extends Equatable {}

///
/// Updates the club (writes it out to firebase.
///
class SingleClubUpdate extends SingleClubEvent {
  /// The club to update.
  final Club club;

  /// If we include the members in the update (or not).
  final bool includeMembers;

  /// The data to update if there is a new image.
  final Uint8List image;

  /// The constructor of the update.
  SingleClubUpdate(
      {@required this.club, this.includeMembers = false, this.image});

  @override
  List<Object> get props => [club, includeMembers, image];
}

///
/// Loads the invites for this club.
///
class SingleClubLoadInvites extends SingleClubEvent {
  @override
  List<Object> get props => [];
}

///
/// Updates the image for the club.
///
class SingleClubUpdateImage extends SingleClubEvent {
  /// The image to update for the club.
  final Uint8List image;

  /// Constructor to update the image.
  SingleClubUpdateImage({@required this.image});

  @override
  List<Object> get props => [image];
}

///
/// Adds an admin to the club.
///
class SingleClubAddMember extends SingleClubEvent {
  /// The uid of the member to add.
  final String adminUid;

  /// If the mbmer is an admin.
  final bool admin;

  /// Create a new request to add a member to the club.
  SingleClubAddMember({@required this.adminUid, this.admin});

  @override
  List<Object> get props => [adminUid, admin];
}

///
/// Deletes an admin from the club.
///
class SingleClubDeleteMember extends SingleClubEvent {
  /// The uid of the member to delete.
  final String memberUid;

  /// A request to delete a member from the club.
  SingleClubDeleteMember({@required this.memberUid});

  @override
  List<Object> get props => [memberUid];
}

///
/// Invites someone to be an admin for this club.
///
class SingleClubInviteMember extends SingleClubEvent {
  /// Invite a new member to the club.
  final String email;

  /// If we should invite them as an admin or not.
  final bool admin;

  /// Create a request to invite a member to the club.
  SingleClubInviteMember({@required this.email, this.admin = false});

  @override
  List<Object> get props => [email, admin];
}

///
/// Delete this club from the world.
///
class SingleClubDelete extends SingleClubEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the teams from firebase.  If the public flag is set then only
/// public teams are loaded.
///
class SingleClubLoadTeams extends SingleClubEvent {
  /// If this is to only load the public teams.
  final bool publicLoad;

  /// Create a request to load the teams for the club.,
  SingleClubLoadTeams({this.publicLoad = false});

  @override
  List<Object> get props => [publicLoad];
}

///
/// Loads the coaches from firebase.
///
class SingleClubLoadCoaches extends SingleClubEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the news items from firebase.
///
class SingleClubLoadNewsItems extends SingleClubEvent {
  @override
  List<Object> get props => [startAt];

  /// The time at which we should start loading the news items.
  final DateTime startAt;

  /// Create a new club nees item thing.
  SingleClubLoadNewsItems({this.startAt});
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
  List<Object> get props => [
        invites,
      ];
}

class _SingleClubTeamsAdded extends SingleClubEvent {
  final BuiltList<Team> teams;

  _SingleClubTeamsAdded({@required this.teams});

  @override
  List<Object> get props => [teams];
}

class _SingleClubCoachesAdded extends SingleClubEvent {
  final BuiltList<Coach> coaches;

  _SingleClubCoachesAdded({@required this.coaches});

  @override
  List<Object> get props => [coaches];
}

class _SingleClubNewsItemAdded extends SingleClubEvent {
  final BuiltList<NewsItem> newsItems;
  final DateTime start;

  _SingleClubNewsItemAdded({@required this.newsItems, @required this.start});

  @override
  List<Object> get props => [newsItems, start];
}

///
/// Bloc to handle updates and state of a specific club.
///
class SingleClubBloc
    extends AsyncHydratedBloc<SingleClubEvent, SingleClubState> {
  /// The database to use for updating the model.
  final DatabaseUpdateModel db;

  /// Where to route all the crashes and stats.
  final AnalyticsSubsystem crashes;

  /// The uid of the club to load.
  final String clubUid;

  StreamSubscription<Club> _clubSub;
  StreamSubscription<Iterable<InviteToClub>> _inviteSub;

  StreamSubscription<BuiltList<Team>> _teamSub;
  StreamSubscription<BuiltList<Coach>> _coachSub;
  final Map<num, StreamSubscription<BuiltList<NewsItem>>> _newsSub = {};

  ///
  /// Creates a new club bloc to load all the things about the club.
  ///
  SingleClubBloc(
      {@required this.db, @required this.clubUid, @required this.crashes})
      : super(SingleClubUninitialized(), 'Singleclub$clubUid') {
    _clubSub = db.getClubData(clubUid: clubUid).listen((club) {
      if (club != null) {
        add(_SingleClubNewClub(newClub: club));
      } else {
        add(_SingleClubDeleted());
      }
    });
    _clubSub.onError((e, stack) {
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
    await _clubSub?.cancel();
    await _inviteSub?.cancel();
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
        var club = event.club;
        if (event.image != null) {
          var clubUri = await db.updateClubImage(state.club, event.image);
          club = club.rebuild((b) => b..photoUrl = clubUri.toString());
        }
        await db.updateClub(club, includeMembers: event.includeMembers);
        yield SingleClubSaveDone.fromState(state).build();
        yield (SingleClubLoaded.fromState(state)..club = event.club.toBuilder())
            .build();
      } on Exception catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubUpdateImage) {
      yield SingleClubSaving.fromState(state).build();
      try {
        var clubUri = await db.updateClubImage(state.club, event.image);

        yield SingleClubSaveDone.fromState(state).build();
        yield (SingleClubLoaded.fromState(state)
              ..club = (state.club.toBuilder()..photoUrl = clubUri.toString()))
            .build();
      } on Exception catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
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
      } on Exception catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
        yield SingleClubLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleClubDeleteMember) {
      yield SingleClubSaving.fromState(state).build();
      try {
        await db.deleteClubMember(state.club, event.memberUid);
        yield SingleClubSaveDone.fromState(state).build();
        yield SingleClubLoaded.fromState(state).build();
      } on Exception catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
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
      } on Exception catch (e, stack) {
        yield (SingleClubSaveFailed.fromState(state)..error = e).build();
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
      if (_inviteSub == null && state is SingleClubLoaded) {
        _inviteSub = db.getInviteToClubStream(clubUid).listen((invites) {
          add(_SingleClubInvitesAdded(invites: invites));
        });
        _inviteSub.onError((e, stack) {
          add(_SingleClubInvitesAdded(invites: BuiltList.of([])));
          crashes.recordException(e, stack);
        });
      }
    }

    if (event is SingleClubLoadNewsItems) {
      if (!_newsSub.containsKey(event.startAt) && state is SingleClubLoaded) {
        num idx = event?.startAt?.millisecondsSinceEpoch ?? 0;
        _newsSub[idx] = db
            .getClubNews(clubUid, start: event.startAt, limit: 10)
            .listen((newsItems) {
          add(_SingleClubNewsItemAdded(
              newsItems: newsItems, start: event.startAt));
        });
        _newsSub[idx].onError((e, stack) {
          add(_SingleClubNewsItemAdded(
              newsItems: BuiltList.of([]), start: event.startAt));
          crashes.recordException(e, stack);
        });
      }
    }

    if (event is _SingleClubNewsItemAdded) {
      if (event.start == null) {
        yield (SingleClubLoaded.fromState(state)
              ..newsItems = event.newsItems.toBuilder()
              ..loadedNewsItems = true)
            .build();
      } else {
        num idx = event.start.millisecondsSinceEpoch;

        var extraNewsItems = state.extraNewsItems.toBuilder();
        extraNewsItems[idx] = event.newsItems;
        yield (SingleClubLoaded.fromState(state)
              ..extraNewsItems = extraNewsItems)
            .build();
      }
    }

    if (event is SingleClubLoadCoaches) {
      if (_coachSub == null && state is SingleClubLoaded) {
        _coachSub = db.getClubCoaches(clubUid).listen((coaches) {
          add(_SingleClubCoachesAdded(coaches: coaches));
        });
        _coachSub.onError((e, stack) {
          add(_SingleClubCoachesAdded(coaches: BuiltList.of([])));
          crashes.recordException(e, stack);
        });
      }
    }

    if (event is _SingleClubCoachesAdded) {
      yield (SingleClubLoaded.fromState(state)
            ..coaches = event.coaches.toBuilder()
            ..loadedCoaches = true)
          .build();
    }

    if (event is SingleClubLoadTeams) {
      try {
        if (_teamSub == null && state is SingleClubLoaded) {
          _teamSub =
              db.getClubTeams(state.club, event.publicLoad).listen((teams) {
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
      } on Exception catch (e, stack) {
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
    if (!(state is SingleClubUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return SingleClubUninitialized();
    }

    try {
      var type = SingleClubBlocStateType.valueOf(json['type']);
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
      crashes.recordException(e, stack);
    }

    return SingleClubUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleClubState state) {
    return state.toMap();
  }
}
