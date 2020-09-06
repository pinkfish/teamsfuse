import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'data/gameblocstate.dart';
import 'data/teamblocstate.dart';
import 'internal/blocstoload.dart';
import 'teambloc.dart';

abstract class GameEvent extends Equatable {}

class _GameEventLogout extends GameEvent {
  @override
  List<Object> get props => [];
}

class _GameEventNewDataLoaded extends GameEvent {
  final Iterable<Game> games;
  final String teamUid;

  _GameEventNewDataLoaded({@required this.teamUid, @required this.games});

  @override
  List<Object> get props => [teamUid, games];
}

class GameEventSetBoundaries extends GameEvent {
  final DateTime start;
  final DateTime end;

  GameEventSetBoundaries({this.start, this.end});

  @override
  List<Object> get props => [start, end];
}

///
/// Handles the work around the games and game system inside of
/// the app.
///
class GameBloc extends HydratedBloc<GameEvent, GameState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<FirestoreChangedData> _gameChangeSub;
  Map<String, StreamSubscription<GameSnapshotEvent>> _gameSubscriptions = {};
  DateTime _start;
  DateTime _end;

  GameBloc({@required this.coordinationBloc, @required this.teamBloc})
      : super(GameUninitialized()) {
    if (teamBloc.state is TeamLoaded) {
      _onTeamsUpdates(teamBloc.state.allTeamUids, true);
    }
    _teamSub = teamBloc.listen((TeamState state) {
      if (state is TeamLoaded) {
        _start = _start ?? new DateTime.now().subtract(new Duration(days: 60));
        _end = _end ?? new DateTime.now().add(new Duration(days: 240));
        _onTeamsUpdates(state.allTeamUids, false);
      } else {
        add(_GameEventLogout());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _teamSub?.cancel();
    _teamSub = null;
  }

  void _cleanupStuff() {
    _gameChangeSub?.cancel();
    _gameChangeSub = null;
    for (StreamSubscription<GameSnapshotEvent> sub
        in _gameSubscriptions.values) {
      sub.cancel();
    }
    _gameSubscriptions.clear();
  }

  void _onTeamsUpdates(Set<String> uids, bool updateBoundary) {
    // Load all of this from the world of firestore.
    for (String teamUid in uids) {
      if (!_gameSubscriptions.containsKey(teamUid) || updateBoundary) {
        _gameSubscriptions[teamUid]?.cancel();
        String myUid = teamUid;
        _gameSubscriptions[teamUid] = coordinationBloc.databaseUpdateModel
            .getBasicGames(start: _start, end: _end, teamUid: teamUid)
            .listen((GameSnapshotEvent gse) {
          add(_GameEventNewDataLoaded(teamUid: myUid, games: gse.newGames));
        });
      }
    }
  }

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    // New data from above.  Mark ourselves as done.
    if (event is _GameEventNewDataLoaded) {
      MapBuilder<String, BuiltMap<String, Game>> newGames =
          state.gamesByTeam.toBuilder();
      MapBuilder<String, Game> games = MapBuilder();
      for (Game g in event.games) {
        games[g.uid] = g;
      }
      MapBuilder<String, GameSharedData> sharedGameData = MapBuilder();
      for (Game g in event.games) {
        if (g.sharedDataUid.isNotEmpty) {
          sharedGameData[g.sharedDataUid] = g.sharedData;
        }
      }
      yield (GameLoaded.fromState(state)
            ..sharedGameData = sharedGameData
            ..gamesByTeam = newGames
            ..loadedFirestore = true
            ..start = _start
            ..end = _end)
          .build();
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Game, sql: false));
    }

    // Unload everything.
    if (event is _GameEventLogout) {
      yield GameUninitialized();
      _cleanupStuff();
    }

    if (event is GameEventSetBoundaries) {
      _start = event.start ?? _start;
      _end = event.end ?? _end;
      _onTeamsUpdates(teamBloc.state.allTeamUids, true);
    }
  }

  @override
  GameState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return GameUninitialized();
    }

    GameBlocStateType type = GameBlocStateType.valueOf(json["type"]);
    switch (type) {
      case GameBlocStateType.Uninitialized:
        return GameUninitialized();
      case GameBlocStateType.Loaded:
        TraceProxy gamesTrace =
            coordinationBloc.analyticsSubsystem.newTrace("gamaData");
        gamesTrace.start();
        var loaded = GameLoaded.fromMap(json);
        print(
            'End games ${coordinationBloc.start.difference(new DateTime.now())} ${loaded.gamesByTeam.length}');
        gamesTrace.stop();
        coordinationBloc.add(
            CoordinationEventLoadedData(loaded: BlocsToLoad.Game, sql: true));
        return loaded;
      default:
        return GameUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(GameState state) {
    return state.toMap();
  }
}
