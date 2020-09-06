import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../data/gameblocstate.dart';
import '../gamesbloc.dart';

abstract class SingleGameState extends Equatable {
  final Game game;
  final BuiltList<GameLog> gameLog;
  final bool loadedLogs;

  SingleGameState(
      {@required this.game, @required this.gameLog, @required this.loadedLogs});

  @override
  // TODO: implement props
  List<Object> get props => [game, gameLog, loadedLogs];
}

///
/// Game in the process of being loaded.
///
class SingleGameLoading extends SingleGameState {
  SingleGameLoading()
      : super(game: null, gameLog: BuiltList(), loadedLogs: false);
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
  SingleGameDeleted.empty()
      : super(game: null, gameLog: BuiltList(), loadedLogs: false);

  @override
  String toString() {
    return 'SingleGameDeleted{}';
  }
}

abstract class SingleGameEvent {}

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
  final String gameUid;
  final GameBloc gameBloc;

  static String createNew = "new";

  StreamSubscription<GameState> _gameSub;
  StreamSubscription<Iterable<GameLog>> _gameLogSub;
  StreamSubscription<Game> _singleGameSub;

  SingleGameBloc({@required this.gameBloc, @required this.gameUid})
      : super(_getInitialState(gameBloc, gameUid)) {
    _gameSub = gameBloc.listen((GameState gameState) {
      Game game = gameState.getGame(gameUid);
      if (game != null) {
        // Only send this if the game is not the same.
        if (game != state.game) {
          add(_SingleGameNewGame(newGame: game));
        }
      }
    });
    Game g = gameBloc.state.getGame(gameUid);
    if (g == null) {
      _singleGameSub = gameBloc.coordinationBloc.databaseUpdateModel
          .getGame(gameUid)
          .listen((Game g) {
        if (g == null) {
          add(_SingleGameDeleted());
        } else {
          add(_SingleGameNewGame(newGame: g));
        }
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _gameSub?.cancel();
    _gameLogSub?.cancel();
    _singleGameSub?.cancel();
  }

  @override
  static SingleGameState _getInitialState(GameBloc gameBloc, String gameUid) {
    Game g = gameBloc.state.getGame(gameUid);

    if (g != null) {
      return SingleGameLoaded(game: g, gamelog: []);
    }

    return SingleGameLoading();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
      print("exist update $gameUid");
      yield SingleGameLoaded(game: event.newGame, state: state);
    }

    // The game is deleted.
    if (event is _SingleGameDeleted) {
      yield SingleGameDeleted.empty();
    }

    // Update the game.
    if (event is SingleGameUpdate) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreGame(event.game, false);
        yield SingleGameSaveDone(state: state);
        yield SingleGameLoaded(state: state, game: event.game);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Update the shared data of the game.
    if (event is SingleGameUpdateSharedData) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSharedGame(event.sharedData);
        yield SingleGameSaveDone(state: state);
        yield SingleGameLoaded(
            state: state,
            game: state.game
                .rebuild((b) => b..sharedData = event.sharedData.toBuilder()));
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Add a gane log.
    if (event is SingleGameAddGameLog) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .addFirestoreGameLog(state.game, event.log);
        List<GameLog> logs = state.gameLog.toList();
        logs.add(event.log);
        yield SingleGameSaveDone(state: state);
        yield SingleGameLoaded(state: state, gamelog: logs);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Update attendence
    if (event is SingleGameUpdateAttendance) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreGameAttendence(
                state.game, event.playerUid, event.attendance);
        GameBuilder builder = state.game.toBuilder();
        builder.attendance[event.playerUid] = event.attendance;
        yield SingleGameSaveDone(state: state);
        yield SingleGameLoaded(game: builder.build(), state: state);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Update game result
    if (event is SingleGameUpdateResult) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreGameResult(state.game.uid, event.result);
        yield SingleGameSaveDone(state: state);
        yield SingleGameLoaded(
            game:
                state.game.rebuild((b) => b..result = event.result.toBuilder()),
            state: state);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    // Update offical game result
    if (event is SingleGameUpdateOfficalResult) {
      yield SingleGameSaving(singleGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOfficalGameResult(
                state.game.sharedData.uid, event.result);
        yield SingleGameSaveDone(state: state);
        yield SingleGameLoaded(state: state);
      } catch (e) {
        yield SingleGameSaveFailed(singleGameState: state, error: e);
      }
    }

    if (event is _SingleGameNewLogs) {
      yield SingleGameLoaded(
          game: state.game,
          gamelog: event.logs,
          loadedLogs: true,
          state: state);
    }

    if (event is SingleGameLoadGameLog) {
      _gameLogSub = gameBloc.coordinationBloc.databaseUpdateModel
          .readGameLogs(state.game)
          .listen((Iterable<GameLog> logs) {
        add(_SingleGameNewLogs(logs: logs));
      });
    }
  }
}
