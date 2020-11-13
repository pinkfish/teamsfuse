import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import 'data/singlegamebloc.dart';

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

class _SingleGameDeleted extends SingleGameEvent {}

class _SingleGameNewLogs extends SingleGameEvent {
  final BuiltList<GameLog> logs;
  _SingleGameNewLogs({@required this.logs});
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleGameBloc
    extends AsyncHydratedBloc<SingleGameEvent, SingleGameState> {
  final String gameUid;
  final DatabaseUpdateModel db;

  static String createNew = "new";

  StreamSubscription<Game> _gameSub;
  StreamSubscription<Iterable<GameLog>> _gameLogSub;
  StreamSubscription<Game> _singleGameSub;

  SingleGameBloc({@required this.gameUid, @required this.db})
      : super(SingleGameUninitialized(), 'SingleGamw' + gameUid) {
    print("Single game $gameUid");
    _gameSub = db.getGame(gameUid).listen((g) {
      if (g != null) {
        add(_SingleGameNewGame(newGame: g));
      } else {
        add(_SingleGameDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _gameSub?.cancel();
    _gameLogSub?.cancel();
    _singleGameSub?.cancel();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
      print("exist update $gameUid");
      yield (SingleGameLoaded.fromState(state)
            ..game = event.newGame.toBuilder())
          .build();
    }

    // The game is deleted.
    if (event is _SingleGameDeleted) {
      yield SingleGameDeleted.fromState(state).build();
    }

    // Update the game.
    if (event is SingleGameUpdate) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreGame(event.game, false);
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)..game = event.game.toBuilder())
            .build();
      } catch (e) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
      }
    }

    // Update the shared data of the game.
    if (event is SingleGameUpdateSharedData) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreSharedGame(event.sharedData);
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)
              ..game = (state.game.toBuilder()
                ..sharedData = event.sharedData.toBuilder()))
            .build();
      } catch (e) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
      }
    }

    // Add a gane log.
    if (event is SingleGameAddGameLog) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.addFirestoreGameLog(state.game, event.log);
        ListBuilder<GameLog> logs = state.gameLog.toBuilder();
        logs.add(event.log);
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)..gameLog = logs).build();
      } catch (e) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
      }
    }

    // Update attendence
    if (event is SingleGameUpdateAttendance) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreGameAttendence(
            state.game, event.playerUid, event.attendance);
        GameBuilder builder = state.game.toBuilder();
        builder.attendance[event.playerUid] = event.attendance;
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)..game = builder).build();
      } catch (e) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
      }
    }

    // Update game result
    if (event is SingleGameUpdateResult) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreGameResult(state.game.uid, event.result);
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)
              ..game =
                  (state.game.toBuilder()..result = event.result.toBuilder()))
            .build();
      } catch (e) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
      }
    }

    // Update offical game result
    if (event is SingleGameUpdateOfficalResult) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreOfficalGameResult(
            state.game.sharedData.uid, event.result);
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)).build();
      } catch (e) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
      }
    }

    if (event is _SingleGameNewLogs) {
      yield (SingleGameLoaded.fromState(state)
            ..gameLog = event.logs.toBuilder()
            ..loadedLogs = true
            ..firestoreLogSetup = true)
          .build();
    }

    if (event is SingleGameLoadGameLog) {
      _gameLogSub?.cancel();
      _gameLogSub =
          db.readGameLogs(state.game).listen((Iterable<GameLog> logs) {
        add(_SingleGameNewLogs(logs: logs));
      });
    }
  }

  @override
  SingleGameState fromJson(Map<String, dynamic> json) {
    //if (json == null || !json.containsKey("type")) {
    return SingleGameUninitialized();
    // }

    SingleGameBlocStateType type =
        SingleGameBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleGameBlocStateType.Uninitialized:
        return SingleGameUninitialized();
      case SingleGameBlocStateType.Loaded:
        var ret = SingleGameLoaded.fromMap(json);
        if (ret.loadedLogs) {
          add(SingleGameLoadGameLog());
        }
        return ret;
      case SingleGameBlocStateType.Deleted:
        return SingleGameDeleted.fromMap(json);
      case SingleGameBlocStateType.SaveFailed:
        return SingleGameSaveFailed.fromMap(json);
      case SingleGameBlocStateType.Saving:
        return SingleGameSaving.fromMap(json);
      case SingleGameBlocStateType.SaveDone:
        return SingleGameSaveDone.fromMap(json);
    }
    return SingleGameUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleGameState state) {
    return state.toMap();
  }
}
