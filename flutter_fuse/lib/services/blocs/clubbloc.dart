import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class ClubEvent extends Equatable {}

class _ClubEventLoadFromFirestore extends ClubEvent {
  final String uid;

  _ClubEventLoadFromFirestore({@required this.uid});

  @override
  String toString() {
    return '_ClubEventLoadFromFirestore{}';
  }

  @override
  List<Object> get props => [uid];
}

class _ClubEventLogout extends ClubEvent {
  @override
  List<Object> get props => [];
}

class _ClubEventNewDataLoaded extends ClubEvent {
  final BuiltMap<String, Club> clubs;

  _ClubEventNewDataLoaded({@required this.clubs});

  @override
  List<Object> get props => [clubs];
}

class _ClubEventNewTeamsLoaded extends ClubEvent {
  final String clubUid;
  final Iterable<Team> teams;

  _ClubEventNewTeamsLoaded({@required this.clubUid, @required this.teams});

  @override
  List<Object> get props => [clubUid, teams];
}

///
/// Deletes an admin from the club.
///
class ClubDeleteMember extends ClubEvent {
  final String memberUid;
  final String clubUid;

  ClubDeleteMember({@required this.memberUid, @required this.clubUid});

  @override
  List<Object> get props => [memberUid, clubUid];
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class ClubBloc extends HydratedBloc<ClubEvent, ClubState> {
  final CoordinationBloc coordinationBloc;
  final AnalyticsSubsystem crashes;
  bool _loadingFirestore = false;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Club>> _clubChangeSub;
  Map<String, StreamSubscription<Iterable<Team>>> _clubTeamsSubscriptions = {};

  ClubBloc({@required this.coordinationBloc, @required this.crashes})
      : super(ClubUninitialized()) {
    _coordSub = coordinationBloc.listen((CoordinationState coordinationState) {
      if (state is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_ClubEventLogout());
      } else if (state is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;
          add(_ClubEventLoadFromFirestore(uid: coordinationState.uid));
        }
      }
    });
    if (!(coordinationBloc.state is CoordinationStateLoggedOut) &&
        !(coordinationBloc.state is CoordinationStateUninitialized)) {
      if (!_loadingFirestore) {
        _loadingFirestore = true;
        add(_ClubEventLoadFromFirestore(uid: coordinationBloc.state.uid));
      }
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _clubChangeSub?.cancel();
    _clubChangeSub = null;
    for (StreamSubscription<Iterable<Team>> sub
        in _clubTeamsSubscriptions.values) {
      sub.cancel();
    }
    _clubTeamsSubscriptions.clear();
  }

  void _onClubsUpdated(Iterable<Club> clubs) {
    MapBuilder<String, Club> newClubs = MapBuilder();

    for (Club club in clubs) {
      newClubs[club.uid] = club;
      String clubUid = club.uid;
      if (!_clubTeamsSubscriptions.containsKey(club.uid)) {
        _clubTeamsSubscriptions[club.uid] = coordinationBloc.databaseUpdateModel
            .getClubTeams(club)
            .listen((Iterable<Team> teams) {
          // Add in all the teams in the list to the teams list and
          // filter out any that have a club on them that now don't
          // exist.
          add(_ClubEventNewTeamsLoaded(clubUid: clubUid, teams: teams));
        });
      }
    }
    add(_ClubEventNewDataLoaded(clubs: newClubs.build()));
  }

  @override
  Stream<ClubState> mapEventToState(ClubEvent event) async* {
    if (event is _ClubEventLoadFromFirestore) {
      // Load the clubs first.
      _clubChangeSub?.cancel();
      Stream<Iterable<Club>> clubData =
          coordinationBloc.databaseUpdateModel.getMainClubs();
      _clubChangeSub = clubData.listen((Iterable<Club> clubs) {
        _onClubsUpdated(clubs);
      });
    }

    // New data from above.  Mark ourselves as done.
    if (event is _ClubEventNewDataLoaded) {
      yield (ClubLoaded.fromState(state)
            ..clubs = event.clubs.toBuilder()
            ..loadedFirestore = true)
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Club));
    }

    // Unload everything.
    if (event is _ClubEventLogout) {
      yield ClubUninitialized();
      _cleanupStuff();
    }

    if (event is ClubDeleteMember) {
      if (!state.clubs.containsKey(event.clubUid)) {
        return;
      }
      try {
        await coordinationBloc.databaseUpdateModel
            .deleteClubMember(state.clubs[event.clubUid], event.memberUid);
      } catch (e) {}
    }

    if (event is _ClubEventNewTeamsLoaded) {
      MapBuilder<String, Iterable<Team>> teams = state.teams.toBuilder();
      teams[event.clubUid] = event.teams;
      yield (ClubLoaded.fromState(state)..teams = teams).build();
    }
  }

  @override
  ClubState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return ClubUninitialized();
    }

    ClubBlocStateType type = ClubBlocStateType.valueOf(json["type"]);
    switch (type) {
      case ClubBlocStateType.Uninitialized:
        return ClubUninitialized();
      case ClubBlocStateType.Loaded:
        try {
          TraceProxy clubTrace =
              coordinationBloc.analyticsSubsystem.newTrace("clubData");
          clubTrace.start();
          // If recovered this way it is only local data.
          var loaded = ClubLoaded.fromMap(json);
          print('End clubs  ${loaded.clubs.length}');
          clubTrace.stop();
          return loaded;
        } catch (e, stack) {
          if (e is Error) {
            crashes.recordError(e, stack);
          } else {
            crashes.recordException(e, stack);
          }
        }
        return ClubUninitialized();
      default:
        return ClubUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(ClubState state) {
    return state.toMap();
  }
}
