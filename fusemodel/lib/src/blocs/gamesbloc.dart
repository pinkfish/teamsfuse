import 'dart:async';

import 'package:bloc/bloc.dart';
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
  final Map<String, Map<String, Game>> gamesByTeam;
  final DateTime start;
  final DateTime end;
  final bool onlySql;

  GameState(
      {@required this.gamesByTeam,
      @required this.onlySql,
      @required this.start,
      @required this.end});

  ///
  /// Finds the game in the currently loaded set of games.
  ///
  Game getGame(String uid) {
    for (Map<String, Game> games in gamesByTeam.values) {
      if (games.containsKey(uid)) {
        return games[uid];
      }
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
            gamesByTeam: {},
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
      {@required Map<String, Map<String, Game>> gamesByTeam,
      @required bool onlySql,
      @required DateTime start,
      @required end})
      : super(
            gamesByTeam: gamesByTeam, onlySql: onlySql, start: start, end: end);

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

class _GameEventSharedDataUpdated extends GameEvent {
  final GameSharedData sharedData;
  final String teamUid;
  final String gameUid;

  _GameEventSharedDataUpdated(
      {@required this.teamUid,
      @required this.gameUid,
      @required this.sharedData});
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
  Map<String, StreamSubscription<GameSnapshotEvent>> _gameSubscriptions;
  DateTime _start;
  DateTime _end;

  GameBloc({@required this.coordinationBloc, @required this.teamBloc}) {
    if (teamBloc.currentState is TeamLoaded) {
      _onTeamsUpdates(teamBloc.currentState.allTeamUids);
    }
    _teamSub = teamBloc.state.listen((TeamState state) {
      if (state is TeamLoaded) {
        _start = _start ?? new DateTime.now().subtract(new Duration(days: 60));
        _end = _end ?? new DateTime.now().add(new Duration(days: 240));
        if (state.onlySql) {
          dispatch(_GameEventUserLoaded(teams: state.allTeamUids));
        } else {
          _onTeamsUpdates(state.allTeamUids);
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

  void _onTeamsUpdates(Set<String> uids) {
    // Load all of this from the world of firestore.
    Map<String, Game> newGames = new Map<String, Game>();
    for (String teamUid in uids) {
      if (!_gameSubscriptions.containsKey(teamUid)) {
        String myUid = teamUid;
        _gameSubscriptions[teamUid] = coordinationBloc.databaseUpdateModel
            .getBasicGames(start: _start, end: _end, teamUid: teamUid)
            .listen((GameSnapshotEvent gse) {
          if (gse.type == GameSnapshotEventType.GameList) {
            dispatch(
                _GameEventNewDataLoaded(teamUid: myUid, games: gse.newGames));
          } else {
            dispatch(_GameEventSharedDataUpdated(
                teamUid: gse.teamUid,
                gameUid: gse.gameUid,
                sharedData: gse.sharedGame));
          }
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
      Map<String, Map<String, Game>> newGames =
          new Map<String, Map<String, Game>>();
      for (String teamUid in event.teams) {
        Map<String, Map<String, dynamic>> data = await coordinationBloc
            .persistentData
            .getAllTeamElements(PersistenData.gameTable, teamUid);
        Map<String, Game> teamGames = {};
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
          } else {
            sharedData = GameSharedData.fromJSON(sharedDataUid, input).build();
          }
          Game game = Game.fromJSON(teamUid, uid, input, sharedData).build();
          teamGames[uid] = game;
        }
        newGames[teamUid] = teamGames;
      }
      print(
          'End games ${coordinationBloc.start.difference(new DateTime.now())} ${newGames.length}');
      gamesTrace.stop();
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Club, sql: true));

      if (currentState.onlySql) {
        yield GameLoaded(
            gamesByTeam: newGames, onlySql: true, start: _start, end: _end);
      }
    }

    // New data from above.  Mark ourselves as done.
    if (event is _GameEventNewDataLoaded) {
      Map<String, Map<String, Game>> newGames =
          Map.from(currentState.gamesByTeam);
      newGames[event.teamUid] =
          Map.from(currentState.gamesByTeam[event.teamUid]);
      Set<String> toRemoveGames = Set.from(newGames[event.teamUid].keys);
      for (Game g in event.games) {
        toRemoveGames.remove(g.uid);
        newGames[event.teamUid][g.uid] = g;
      }
      for (String rem in toRemoveGames) {
        newGames[event.teamUid].remove(rem);
      }
      yield GameLoaded(
          gamesByTeam: newGames, onlySql: false, start: _start, end: _end);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Club, sql: false));
    }

    // New shared game data.
    if (event is _GameEventSharedDataUpdated) {
      Map<String, Map<String, Game>> allGames =
          Map.from(currentState.gamesByTeam);
      allGames[event.teamUid] = Map.from(allGames[event.teamUid]);
      Game g = allGames[event.teamUid][event.gameUid];
      allGames[event.teamUid][event.gameUid] =
          g.rebuild((b) => b..sharedData = event.sharedData.toBuilder());
      yield GameLoaded(
          gamesByTeam: allGames,
          onlySql: currentState.onlySql,
          start: _start,
          end: _end);
    }

    // Unload everything.
    if (event is _GameEventLogout) {
      yield GameUninitialized();
      _cleanupStuff();
    }
  }
}
