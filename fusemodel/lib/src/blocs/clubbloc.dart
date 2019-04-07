import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'teambloc.dart';
import 'internal/blocstoload.dart';

///
/// Basic state for all the data in this system.
///
class ClubState extends Equatable {
  final Map<String, Club> clubs;
  final bool onlySql;

  ClubState({@required this.clubs, @required this.onlySql});
}

///
/// No data at all yet.
///
class ClubUninitialized extends ClubState {
  ClubUninitialized() : super(clubs: {}, onlySql: true);

  @override
  String toString() {
    return 'ClubUninitialized{}';
  }
}

///
/// Doing something.
///
class ClubLoaded extends ClubState {
  ClubLoaded({@required Map<String, Club> clubs, @required bool onlySql})
      : super(clubs: clubs, onlySql: onlySql);

  @override
  String toString() {
    return 'ClubLoaded{}';
  }
}

class ClubEvent extends Equatable {}

class _ClubEventUserLoaded extends ClubEvent {
  final String uid;

  _ClubEventUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_ClubEventUserLoaded{}';
  }
}

class _ClubEventLoadFromFirestore extends ClubEvent {
  final String uid;

  _ClubEventLoadFromFirestore({@required this.uid});

  @override
  String toString() {
    return '_ClubEventLoadFromFirestore{}';
  }
}

class _ClubEventLogout extends ClubEvent {}

class _ClubEventNewDataLoaded extends ClubEvent {
  final Map<String, Club> clubs;

  _ClubEventNewDataLoaded({@required this.clubs});
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<FirestoreChangedData> _clubChangeSub;
  Map<String, TeamSubscription> _clubSubscriptions;
  Map<String, StreamSubscription<Iterable<Team>>> _clubTeamsSubscriptions;

  ClubBloc({@required this.coordinationBloc, @required this.teamBloc}) {
    _coordSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateStartLoadingSql) {
        _startLoading(state);
      } else if (state is CoordinationStateLoggedOut) {
        dispatch(_ClubEventLogout());
      }
    });
    if (!(coordinationBloc.currentState is CoordinationStateLoggedOut)) {
      _startLoading(coordinationBloc.currentState);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _clubChangeSub?.cancel();
    _clubChangeSub = null;
    for (TeamSubscription sub in _clubSubscriptions.values) {
      sub.dispose();
    }
    _clubSubscriptions.clear();
    for (StreamSubscription<Iterable<Team>> sub
        in _clubTeamsSubscriptions.values) {
      sub.cancel();
    }
    _clubTeamsSubscriptions.clear();
  }

  void _startLoading(CoordinationState state) {
    dispatch(_ClubEventUserLoaded(uid: state.uid));
  }

  @override
  ClubState get initialState => ClubUninitialized();

  void _onClubsUpdated(
      List<FirestoreWrappedData> newList, List<FirestoreWrappedData> removed) {
    Map<String, Club> newClubs;

    for (FirestoreWrappedData data in newList) {
      Club club = new Club.fromJson(data.id, data.data);
      newClubs[data.id] = club;
      if (!_clubSubscriptions.containsKey(data.id)) {
        _clubSubscriptions[data.id] =
            coordinationBloc.databaseUpdateModel.getClubTeams(club);
        _clubTeamsSubscriptions[data.id] =
            _clubSubscriptions[data.id].stream.listen((Iterable<Team> teams) {
          // Add in all the teams in the list to the teams list and
          // filter out any that have a club on them that now don't
          // exist.
          Map<String, Team> clubTeams = {};
          for (Team t in teams) {
            clubTeams[t.uid] = t;
          }
          teamBloc
              .dispatch(TeamClubTeams(clubTeams: clubTeams, clubUid: club.uid));
        });
      }
      coordinationBloc.persistentData
          .updateElement(PersistenData.clubsTable, club.uid, data.data);
    }
    dispatch(_ClubEventNewDataLoaded(clubs: newClubs));
  }

  @override
  Stream<ClubState> mapEventToState(ClubEvent event) async* {
    if (event is _ClubEventUserLoaded) {
      // Reset stuff first.
      // Club data;
      TraceProxy clubTrace =
          coordinationBloc.analyticsSubsystem.newTrace("clubData");
      clubTrace.start();
      DateTime start = new DateTime.now();
      Map<String, Map<String, dynamic>> data = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.clubsTable);
      Map<String, Club> newClubs = new Map<String, Club>();
      data.forEach((String uid, Map<String, dynamic> input) {
        coordinationBloc.sqlTrace.incrementCounter("club");
        Club club = new Club.fromJson(uid, input);
        newClubs[uid] = club;
      });
      print(
          'End clubs ${start.difference(new DateTime.now())} ${newClubs.length}');
      clubTrace.stop();
      yield ClubLoaded(clubs: newClubs);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Club, sql: true));
    }

    if (event is _ClubEventLoadFromFirestore) {
      // Load the clubs first.
      InitialSubscription clubInitialData =
          coordinationBloc.databaseUpdateModel.getMainClubs(event.uid);
      clubInitialData.startData.then((List<FirestoreWrappedData> data) {
        _onClubsUpdated(data, []);
      });
      _clubChangeSub =
          clubInitialData.stream.listen((FirestoreChangedData data) {
        _onClubsUpdated(data.newList, data.removed);
      });
    }

    // New data from above.  Mark ourselves as done.
    if (event is _ClubEventNewDataLoaded) {
      yield ClubLoaded(clubs: event.clubs, onlySql: false);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Club, sql: false));
    }

    // Unload everything.
    if (event is _ClubEventLogout) {
      yield ClubUninitialized();
      _cleanupStuff();
    }
  }
}
