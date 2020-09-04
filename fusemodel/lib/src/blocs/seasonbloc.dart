import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class SeasonEvent extends Equatable {}

class _SeasonUserLoaded extends SeasonEvent {
  final String uid;

  _SeasonUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_SeasonUserLoaded{}';
  }

  @override
  List<Object> get props => [uid];
}

class _SeasonFirestoreStart extends SeasonEvent {
  final String uid;

  _SeasonFirestoreStart({@required this.uid});

  @override
  String toString() {
    return '_SeasonFirestoreStart{}';
  }

  @override
  List<Object> get props => [uid];
}

class _SeasonLoggedOut extends SeasonEvent {
  @override
  List<Object> get props => [];
}

class _SeasonAdminUpdated extends SeasonEvent {
  final Map<String, Season> adminSeasons;

  _SeasonAdminUpdated({@required this.adminSeasons});

  @override
  List<Object> get props => [adminSeasons];
}

class _SeasonUpdate extends SeasonEvent {
  final BuiltMap<String, Season> newSeasons;

  _SeasonUpdate({@required this.newSeasons});

  @override
  List<Object> get props => [newSeasons];
}

///
/// Basic state for all the season states.
///
abstract class SeasonState extends Equatable {
  final BuiltMap<String, Season> seasons;
  final bool onlySql;

  SeasonState({@required this.onlySql, @required this.seasons});

  @override
  List<Object> get props => [onlySql, seasons];
}

///
/// No data at all, we are uninitialized.
///
class SeasonUninitialized extends SeasonState {
  SeasonUninitialized() : super(seasons: BuiltMap(), onlySql: true);

  @override
  String toString() {
    return 'SeasonUninitialized{players: ${seasons.length}, onlySql: $onlySql}';
  }
}

///
/// Player data is loaded and everything is fluffy.
///
class SeasonLoaded extends SeasonState {
  SeasonLoaded(
      {@required SeasonState state,
      BuiltMap<String, Season> SeasonsByPlayer,
      BuiltMap<String, Season> adminSeasons,
      BuiltMap<String, BuiltMap<String, Season>> clubSeasons,
      BuiltMap<String, Season> publicSeasons,
      BuiltMap<String, Season> seasons,
      BuiltMap<String, Opponent> opponents,
      bool onlySql})
      : super(
            onlySql: onlySql ?? state.onlySql,
            seasons: seasons ?? state.seasons);

  @override
  String toString() {
    return 'SeasonLoaded{SeasonsByPlayer: ${seasons.length}, onlySql: $onlySql}';
  }
}

///
/// Season bloc handles the Seasons flow.  Loading all the Seasons from
/// firestore.
///
class SeasonBloc extends Bloc<SeasonEvent, SeasonState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<Season>> _seasonSub;
  TraceProxy _seasonByPlayerTrace;

  bool _loadingSql = false;
  bool _loadingFirestore = false;

  SeasonBloc({@required this.coordinationBloc}) : super(SeasonUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Season));

    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        _loadingSql = false;
        add(_SeasonLoggedOut());
      } else if (coordState is CoordinationStateLoadingSql) {
        if (!_loadingSql) {
          _loadingSql = true;
          _startLoading(coordState);
        }
      } else if (coordState is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;
          _startLoadingFirestore(coordState);
        }
      }
    });
  }

  void _startLoading(CoordinationState state) {
    add(_SeasonUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationState state) {
    add(_SeasonFirestoreStart(uid: state.uid));
  }

  void _cleanupSnaps() {
    _seasonSub?.cancel();
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupSnaps();
    _coordSub?.cancel();
  }

  @override
  void onClubUpdated(FirestoreWrappedData data) {}

  void _onSeasonUpdatePeristentData(
      BuiltMap<String, Season> oldSeasons, Iterable<Season> newSeasons) {
    Set<String> toRemove = Set.of(oldSeasons.keys);
    print('onSeasonUpdated');

    for (Season doc in newSeasons) {
      coordinationBloc.loadingTrace?.incrementCounter("season");
      coordinationBloc.persistentData
          .updateElement(PersistenData.seasonTable, doc.uid, doc.toJSON());
      toRemove.remove(doc.uid);
    }
    for (String SeasonId in toRemove) {
      coordinationBloc.persistentData
          .deleteElement(PersistenData.seasonTable, SeasonId);
    }
  }

  @override
  Stream<SeasonState> mapEventToState(SeasonEvent event) async* {
    if (event is _SeasonUserLoaded) {
      // Starting, nothing loaded yet.
      yield SeasonUninitialized();
      TraceProxy SeasonsTrace =
          coordinationBloc.analyticsSubsystem.newTrace("SeasonData");
      SeasonsTrace.start();
      Map<String, Map<String, dynamic>> data = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.seasonTable);
      Map<String, Season> newSeasons = new Map<String, Season>();
      print(
          'Start Seasons ${coordinationBloc.start.difference(new DateTime.now())}');
      for (String uid in data.keys) {
        coordinationBloc.sqlTrace?.incrementCounter("season");
        SeasonsTrace.incrementCounter("season");
        Map<String, dynamic> input = data[uid];
        SeasonBuilder season = Season.fromJSON(uid, input);

        // Load opponents.
        newSeasons[uid] = season.build();
      }
      yield SeasonLoaded(
          state: state, seasons: BuiltMap.from(newSeasons), onlySql: true);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Season, sql: true));
    }

    // Start the firestore loading.
    if (event is _SeasonFirestoreStart) {
      // Do the admin Season loading thing.
      TraceProxy adminTrace =
          coordinationBloc.analytics.newTrace('adminSeasons');
      Stream<Iterable<Season>> initialState =
          coordinationBloc.databaseUpdateModel.getSeasons(event.uid);
      Completer<Iterable<Season>> seasonData = Completer();
      _seasonSub = initialState.listen((Iterable<Season> data) {
        if (!seasonData.isCompleted) {
          seasonData.complete(data);
        }
        add(_SeasonAdminUpdated(
            adminSeasons:
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t)));
      });
      coordinationBloc.loadingTrace?.incrementCounter("adminSeasons");
      BuiltMap<String, Season> oldSeasons = state.seasons;
      Iterable<Season> startStuff = await seasonData.future;
      yield SeasonLoaded(
          state: state,
          adminSeasons: BuiltMap.from(Map.fromIterable(startStuff,
              key: (t) => t.uid, value: (t) => t)));
      _onSeasonUpdatePeristentData(oldSeasons, startStuff);

      adminTrace.stop();
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Season, sql: false));
    }

    // Unload everything.
    if (event is _SeasonLoggedOut) {
      yield SeasonUninitialized();
      _cleanupSnaps();
    }

    // Update just the seasons.
    if (event is _SeasonUpdate) {
      BuiltMap<String, Season> oldSeasons = state.seasons;
      yield SeasonLoaded(
          state: state, seasons: event.newSeasons, onlySql: false);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Season, sql: true));
      _onSeasonUpdatePeristentData(oldSeasons, event.newSeasons.values);
    }
  }
}
