import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';
import 'teambloc.dart';

///
/// Basic state for all the data in this system.
///
class GameState extends Equatable {
  final BuiltMap<String, BuiltMap<String, Game>> gamesByTeam;
  final BuiltMap<String, GameSharedData> sharedGameData;
  final DateTime start;
  final DateTime end;
  final bool onlySql;

  GameState(
      {@required this.gamesByTeam,
      @required this.sharedGameData,
      @required this.onlySql,
      @required this.start,
      @required this.end})
      : super([gamesByTeam, sharedGameData, onlySql, start, end]);

  ///
  /// Finds the game in the currently loaded set of games.
  ///
  Game getGame(String uid) {
    for (BuiltMap<String, Game> games in gamesByTeam.values) {
      if (games.containsKey(uid)) {
        return games[uid];
      }
    }
    return null;
  }

  ///
  /// Finds the shared details for the game out of the loaded set.
  ///
  GameSharedData getSharedData(String uid) {
    if (sharedGameData.containsKey(uid)) {
      return sharedGameData[uid];
    }
    return null;
  }
}

///
/// No data at all yet.
///
class GameUninitialized extends GameState {
  GameUninitialized()
      : super(
            gamesByTeam: BuiltMap(),
            sharedGameData: BuiltMap(),
            onlySql: true,
            start: DateTime.now(),
            end: DateTime.now());

  @override
  String toString() {
    return 'GameUninitialized{}';
  }
}

///
/// Doing something.
///
class GameLoaded extends GameState {
  GameLoaded(
      {@required GameState state,
      BuiltMap<String, BuiltMap<String, Game>> gamesByTeam,
      BuiltMap<String, GameSharedData> sharedGames,
      bool onlySql,
      DateTime start,
      end})
      : super(
            gamesByTeam: gamesByTeam ?? state.gamesByTeam,
            sharedGameData: sharedGames ?? state.sharedGameData,
            onlySql: onlySql ?? state.onlySql,
            start: start ?? state.start,
            end: end ?? state.end);

  @override
  String toString() {
    return 'GameLoaded{}';
  }
}

class GameEvent extends Equatable {}

class _GameEventUserLoaded extends GameEvent {
  final Set<String> teams;

  _GameEventUserLoaded({@required this.teams});

  @override
  String toString() {
    return '_GameEventUserLoaded{}';
  }
}

class _GameEventLogout extends GameEvent {}

class _GameEventNewDataLoaded extends GameEvent {
  final Iterable<Game> games;
  final String teamUid;

  _GameEventNewDataLoaded({@required this.teamUid, @required this.games});
}

class GameEventSetBoundaries extends GameEvent {
  final DateTime start;
  final DateTime end;

  GameEventSetBoundaries({this.start, this.end});
}

///
/// Handles the work around the games and game system inside of
/// the app.
///
class GameBloc extends Bloc<GameEvent, GameState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<FirestoreChangedData> _gameChangeSub;
  Map<String, StreamSubscription<GameSnapshotEvent>> _gameSubscriptions = {};
  DateTime _start;
  DateTime _end;

  GameBloc({@required this.coordinationBloc, @required this.teamBloc}) {
    if (teamBloc.currentState is TeamLoaded) {
      _onTeamsUpdates(teamBloc.currentState.allTeamUids, true);
    }
    _teamSub = teamBloc.state.listen((TeamState state) {
      if (state is TeamLoaded) {
        _start = _start ?? new DateTime.now().subtract(new Duration(days: 60));
        _end = _end ?? new DateTime.now().add(new Duration(days: 240));
        if (state.onlySql) {
          dispatch(_GameEventUserLoaded(teams: state.allTeamUids));
        } else {
          _onTeamsUpdates(state.allTeamUids, false);
        }
      } else {
        dispatch(_GameEventLogout());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
          dispatch(
              _GameEventNewDataLoaded(teamUid: myUid, games: gse.newGames));
        });
      }
    }
  }

  @override
  GameState get initialState => GameUninitialized();

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    if (event is _GameEventUserLoaded) {
      TraceProxy gamesTrace =
          coordinationBloc.analyticsSubsystem.newTrace("gamaData");
      gamesTrace.start();
      MapBuilder<String, BuiltMap<String, Game>> newGames = MapBuilder();
      MapBuilder<String, GameSharedData> gameSharedData = MapBuilder();
      for (String teamUid in event.teams) {
        Map<String, Map<String, dynamic>> data = await coordinationBloc
            .persistentData
            .getAllTeamElements(PersistenData.gameTable, teamUid);
        MapBuilder<String, Game> teamGames = MapBuilder();
        for (String uid in data.keys) {
          Map<String, dynamic> input = data[uid];
          coordinationBloc.sqlTrace.incrementCounter("game");
          gamesTrace.incrementCounter("game");
          String sharedDataUid = input[Game.SHAREDDATAUID];
          GameSharedData sharedData;
          if (sharedDataUid.isNotEmpty) {
            Map<String, dynamic> sharedDataStuff = await coordinationBloc
                .persistentData
                .getElement(PersistenData.sharedGameTable, sharedDataUid);
            sharedData =
                GameSharedData.fromJSON(sharedDataUid, sharedDataStuff).build();
            gameSharedData[sharedDataUid] = sharedData;
          } else {
            sharedData = GameSharedData.fromJSON(sharedDataUid, input).build();
          }
          Game game = Game.fromJSON(teamUid, uid, input, sharedData).build();
          teamGames[uid] = game;
        }
        newGames[teamUid] = teamGames.build();
      }
      print(
          'End games ${coordinationBloc.start.difference(new DateTime.now())} ${newGames.length}');
      gamesTrace.stop();
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Game, sql: true));

      if (currentState.onlySql) {
        yield GameLoaded(
            state: currentState,
            gamesByTeam: newGames.build(),
            sharedGames: gameSharedData.build(),
            onlySql: true,
            start: _start,
            end: _end);
      }
    }

    // New data from above.  Mark ourselves as done.
    if (event is _GameEventNewDataLoaded) {
      MapBuilder<String, BuiltMap<String, Game>> newGames =
          currentState.gamesByTeam.toBuilder();
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
      yield GameLoaded(
          state: currentState,
          sharedGames: sharedGameData.build(),
          gamesByTeam: newGames.build(),
          onlySql: false,
          start: _start,
          end: _end);
      coordinationBloc.dispatch(
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
      _onTeamsUpdates(teamBloc.currentState.allTeamUids, true);
    }
  }
}
