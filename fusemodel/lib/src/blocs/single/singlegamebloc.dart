import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../gamesbloc.dart';

abstract class SingleGameState extends Equatable {
  final Game game;
  final Iterable<GameLog> gameLog;
  final bool loadedLogs;

  SingleGameState(
      {@required this.game, @required this.gameLog, @required this.loadedLogs});
}

///
/// We have a game, default state.
///
class SingleGameLoaded extends SingleGameState {
  SingleGameLoaded(
      {@required SingleGameState state,
      Game game,
      Iterable<GameLog> gamelog,
      bool loadedLogs})
      : super(
            game: game ?? state.game,
            gameLog: gamelog ?? state.gameLog,
            loadedLogs: loadedLogs ?? state.loadedLogs);

  SingleGameLoaded.copy(SingleGameState state)
      : super(
            game: state.game,
            gameLog: state.gameLog,
            loadedLogs: state.loadedLogs);

  @override
  String toString() {
    return 'SingleGameLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleGameSaving extends SingleGameState {
  SingleGameSaving({@required SingleGameState singleGameState})
      : super(
            game: singleGameState.game,
            gameLog: singleGameState.gameLog,
            loadedLogs: singleGameState.loadedLogs);

  @override
  String toString() {
    return 'SingleGameSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleGameSaveFailed extends SingleGameState {
  final Error error;

  SingleGameSaveFailed({@required SingleGameState singleGameState, this.error})
      : super(
            game: singleGameState.game,
            gameLog: singleGameState.gameLog,
            loadedLogs: singleGameState.loadedLogs);

  @override
  String toString() {
    return 'SingleGameSaveFailed{}';
  }
}

///
/// State for when the saving is done.
///
class SingleGameSaveDone extends SingleGameState {
  SingleGameSaveDone({@required SingleGameState state})
      : super(
            game: state.game,
            gameLog: state.gameLog,
            loadedLogs: state.loadedLogs);

  @override
  String toString() {
    return 'SingleGameSaveDone()';
  }
}

///
/// Game got deleted.
///
class SingleGameDeleted extends SingleGameState {
  SingleGameDeleted.empty() : super(game: null, gameLog: [], loadedLogs: false);

  @override
  String toString() {
    return 'SingleGameDeleted{}';
  }
}

abstract class SingleGameEvent extends Equatable {}

///
/// Updates the game (writes it out to firebase.
///
class SingleGameUpdate extends SingleGameEvent {
  final Game game;

  SingleGameUpdate({@required this.game});
}

///
/// Updates the game (writes it out to firebase.
///
class SingleGameUpdateSharedData extends SingleGameEvent {
  final GameSharedData sharedData;

  SingleGameUpdateSharedData({@required this.sharedData});
}

///
/// Adds a log to the game.
///
class SingleGameAddGameLog extends SingleGameEvent {
  final GameLog log;

  SingleGameAddGameLog({@required this.log});
}

///
/// Loads the gane log for this game.
///
class SingleGameLoadGameLog extends SingleGameEvent {
  SingleGameLoadGameLog();
}

///
/// Delete this game from the world.
///
class SingleGameDelete extends SingleGameEvent {
  SingleGameDelete();
}

///
/// Updated the attendence for the player.
///s
class SingleGameUpdateAttendance extends SingleGameEvent {
  final String playerUid;
  final Attendance attendance;

  SingleGameUpdateAttendance(
      {@required this.playerUid, @required this.attendance});
}

///
/// Update the result for this game.
///s
class SingleGameUpdateResult extends SingleGameEvent {
  final GameResultDetails result;

  SingleGameUpdateResult({@required this.result});
}

///
/// Update the offical result for this game.
///s
class SingleGameUpdateOfficalResult extends SingleGameEvent {
  final GameOfficialResults result;

  SingleGameUpdateOfficalResult({@required this.result});
}

class _SingleGameNewGame extends SingleGameEvent {
  final Game newGame;

  _SingleGameNewGame({@required this.newGame});
}

class _SingleGameDeleted extends SingleGameEvent {
  _SingleGameDeleted();
}

class _SingleGameNewLogs extends SingleGameEvent {
  final Iterable<GameLog> logs;
  _SingleGameNewLogs({@required this.logs});
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleGameBloc extends Bloc<SingleGameEvent, SingleGameState> {
  final GameBloc gameBloc;
  String _gameUid;

  static String createNew = "new";

  String get gameUid => _gameUid;

  StreamSubscription<GameState> _gameSub;
  StreamSubscription<Iterable<GameLog>> _gameLogSub;

  SingleGameBloc({@required this.gameBloc, @required String gameUid}) {
    _gameUid = gameUid;
    _gameSub = gameBloc.state.listen((GameState state) {
      Game game = state.getGame(gameUid);
      if (game != null) {
        // Only send this if the game is not the same.
        if (game != currentState.game) {
          dispatch(_SingleGameNewGame(newGame: game));
        }
      } else {
        dispatch(_SingleGameDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameSub?.cancel();
    _gameLogSub?.cancel();
  }

  @override
  SingleGameState get initialState {
    Game g = gameBloc.currentState.getGame(gameUid);

    if (g != null) {
      return SingleGameLoaded(game: g, gamelog: []);
    }
    return SingleGameDeleted.empty();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
      yield SingleGameLoaded(
          game: event.newGame, gamelog: currentState.gameLog);
    }

    // The game is deleted.
    if (event is _SingleGameDeleted) {
      yield SingleGameDeleted.empty();
    }

    // Update the game.
    if (event is SingleGameUpdate) {
      yield SingleGameSaving(singleGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreGame(event.game, false);
        yield SingleGameSaveDone(state: currentState);
        yield SingleGameLoaded(state: currentState, game: event.game);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: currentState, error: e);
      }
    }

    // Update the shared data of the game.
    if (event is SingleGameUpdateSharedData) {
      yield SingleGameSaving(singleGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSharedGame(event.sharedData);
        yield SingleGameSaveDone(state: currentState);
        yield SingleGameLoaded(
            state: currentState,
            game: currentState.game
                .rebuild((b) => b..sharedData = event.sharedData.toBuilder()));
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: currentState, error: e);
      }
    }

    // Add a gane log.
    if (event is SingleGameAddGameLog) {
      yield SingleGameSaving(singleGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .addFirestoreGameLog(currentState.game, event.log);
        List<GameLog> logs = currentState.gameLog.toList();
        logs.add(event.log);
        yield SingleGameSaveDone(state: currentState);
        yield SingleGameLoaded(state: currentState, gamelog: logs);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: currentState, error: e);
      }
    }

    // Update attendence
    if (event is SingleGameUpdateAttendance) {
      yield SingleGameSaving(singleGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreGameAttendence(
                currentState.game, event.playerUid, event.attendance);
        GameBuilder builder = currentState.game.toBuilder();
        builder.attendance[event.playerUid] = event.attendance;
        yield SingleGameSaveDone(state: currentState);
        yield SingleGameLoaded(game: builder.build(), state: currentState);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: currentState, error: e);
      }
    }

    // Update game result
    if (event is SingleGameUpdateResult) {
      yield SingleGameSaving(singleGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreGameResult(currentState.game.uid, event.result);
        yield SingleGameSaveDone(state: currentState);
        yield SingleGameLoaded(
            game: currentState.game
                .rebuild((b) => b..result = event.result.toBuilder()),
            state: currentState);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: currentState, error: e);
      }
    }

    // Update offical game result
    if (event is SingleGameUpdateOfficalResult) {
      yield SingleGameSaving(singleGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOfficalGameResult(
                currentState.game.sharedData.uid, event.result);
        yield SingleGameSaveDone(state: currentState);
        yield SingleGameLoaded(state: currentState);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: currentState, error: e);
      }
    }

    if (event is _SingleGameNewLogs) {
      yield SingleGameLoaded(
          game: currentState.game, gamelog: event.logs, loadedLogs: true);
    }

    if (event is SingleGameLoadGameLog) {
      _gameLogSub = gameBloc.coordinationBloc.databaseUpdateModel
          .readGameLogs(currentState.game)
          .listen((Iterable<GameLog> logs) {
        dispatch(_SingleGameNewLogs(logs: logs));
      });
    }
  }
}
