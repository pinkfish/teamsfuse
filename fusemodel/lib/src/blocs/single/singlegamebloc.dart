import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

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

///
/// Load the game eventsa
///
class SingleGameLoadEvents extends SingleGameEvent {
  SingleGameLoadEvents();

  @override
  List<Object> get props => [];
}

///
/// Load the game media
///
class SingleGameLoadMedia extends SingleGameEvent {
  SingleGameLoadMedia();

  @override
  List<Object> get props => [];
}

///
/// Updates the game player into the opponent or player category.
///
class SingleGameUpdatePlayer extends SingleGameEvent {
  final BuiltMap<String, PlayerSummaryWithOpponent> summary;

  SingleGameUpdatePlayer({
    @required this.summary,
  });

  @override
  List<Object> get props => [summary];
}

///
/// Adds an admin to the game.
///
class SingleGameAddPlayer extends SingleGameEvent {
  final String playerUid;
  final bool opponent;

  SingleGameAddPlayer({@required this.playerUid, @required this.opponent});

  @override
  List<Object> get props => [playerUid, opponent];
}

///
/// Deletes an player from the game.
///
class SingleGameRemovePlayer extends SingleGameEvent {
  final String playerUid;
  final bool opponent;

  SingleGameRemovePlayer({@required this.playerUid, @required this.opponent});

  @override
  List<Object> get props => [playerUid, opponent];
}

///
/// Loads the players for the game.
///
class SingleGameLoadPlayers extends SingleGameEvent {
  List<Object> get props => [];
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

class _SingleGameNewEvents extends SingleGameEvent {
  final BuiltList<GameEvent> events;
  final BuiltList<GameEvent> newEvents;
  final BuiltList<GameEvent> removedEvents;

  _SingleGameNewEvents(
      {@required this.events, this.newEvents, this.removedEvents});

  @override
  List<Object> get props => [events, newEvents, removedEvents];
}

class _SingleGameNewMedia extends SingleGameEvent {
  final BuiltList<MediaInfo> newMedia;

  _SingleGameNewMedia({@required this.newMedia});

  @override
  List<Object> get props => [newMedia];
}

class _SingleGameUpdatePlayers extends SingleGameEvent {
  final BuiltMap<String, Player> players;

  _SingleGameUpdatePlayers({@required this.players});

  @override
  List<Object> get props => [players];
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleGameBloc
    extends AsyncHydratedBloc<SingleGameEvent, SingleGameState> {
  final String gameUid;
  final DatabaseUpdateModel db;
  final Lock _lock = Lock();
  final AnalyticsSubsystem crashes;

  static String createNew = "new";

  StreamSubscription<Game> _gameSub;
  StreamSubscription<Iterable<GameLog>> _gameLogSub;
  StreamSubscription<BuiltList<GameEvent>> _gameEventSub;
  StreamSubscription<BuiltList<MediaInfo>> _mediaInfoSub;

  Map<String, StreamSubscription<Player>> _players;
  Map<String, Player> _loadedPlayers;

  SingleGameBloc(
      {@required this.gameUid, @required this.db, @required this.crashes})
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
    _mediaInfoSub?.cancel();
    _gameEventSub?.cancel();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
      print("exist update $gameUid");
      yield (SingleGameLoaded.fromState(state)
            ..game = event.newGame.toBuilder())
          .build();
    }

    if (event is _SingleGameNewEvents) {
      yield (SingleGameChangeEvents.fromState(state)
            ..gameEvents = event.events.toBuilder()
            ..newEvents = event.newEvents.toBuilder()
            ..removedEvents = event.removedEvents.toBuilder())
          .build();
      yield (SingleGameLoaded.fromState(state)
            ..gameEvents = event.events.toBuilder()
            ..loadedEvents = true)
          .build();
    }

    if (event is SingleGameLoadEvents) {
      print(" events $event");

      _lock.synchronized(() {
        if (_gameEventSub == null) {
          _gameEventSub = db
              .getGameEvents(gameUid: gameUid)
              .listen((BuiltList<GameEvent> ev) => _newGameEvents(ev));
        }
      });
    }

    if (event is SingleGameLoadMedia) {
      print(" events $event");

      _lock.synchronized(() {
        if (_mediaInfoSub == null) {
          _mediaInfoSub = db.getMediaForGame(gameUid: gameUid).listen(
              (BuiltList<MediaInfo> ev) =>
                  add(_SingleGameNewMedia(newMedia: ev)));
        }
      });
    }

    if (event is _SingleGameNewMedia) {
      yield (SingleGameLoaded.fromState(state)
            ..media = event.newMedia.toBuilder()
            ..loadedMedia = true)
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
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordError(e, stack);
      }
    }

    // Load a single game.
    if (event is SingleGameLoadPlayers) {
      // Load all the player details for this season.
      _lock.synchronized(() {
        for (String playerUid in state.game.players.keys) {
          if (!_players.containsKey(playerUid)) {
            _players[playerUid] =
                db.getPlayerDetails(playerUid).listen(_onPlayerUpdated);
          }
        }
      });
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
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordError(e, stack);
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
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordError(e, stack);
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
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordError(e, stack);
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
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordError(e, stack);
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
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordError(e, stack);
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

    // Adds a player to the game
    if (event is SingleGameAddPlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.addGamePlayer(
            gameUid: gameUid,
            playerUid: event.playerUid,
            opponent: event.opponent);
        yield SingleGameSaveDone.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }

    // Updates a player in the game
    if (event is SingleGameUpdatePlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        for (MapEntry<String, PlayerSummaryWithOpponent> entry
            in event.summary.entries) {
          await db.updateGamePlayerData(
              gameUid: gameUid,
              opponent: entry.value.opponent,
              summary: entry.value.summary,
              playerUid: entry.key);
        }
        yield SingleGameSaveDone.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }
    // Removes a player from the game.
    if (event is SingleGameRemovePlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.deleteGamePlayer(
            gameUid: gameUid,
            playerUid: event.playerUid,
            opponent: event.opponent);
        yield SingleGameSaveDone.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        crashes.recordError(error, stack);
        yield (SingleGameSaveFailed.fromState(state)..error = error).build();
        yield SingleGameLoaded.fromState(state).build();
      }
    }

    if (event is _SingleGameUpdatePlayers) {
      yield (SingleGameLoaded.fromState(state)
            ..players = event.players.toBuilder()
            ..loadedPlayers = true)
          .build();
    }

    if (event is _SingleGameUpdatePlayers) {
      yield (SingleGameLoaded.fromState(state)
            ..players = event.players.toBuilder()
            ..loadedPlayers = true)
          .build();
    }
  }

  void _onPlayerUpdated(Player event) {
    _loadedPlayers[event.uid] = event;
    // Do updates after we are loaded.
    if (_loadedPlayers.length == _players.length || state.loadedPlayers) {
      // Loaded them all.
      add(_SingleGameUpdatePlayers(players: BuiltMap.of(_loadedPlayers)));
    }
  }

  void _newGameEvents(BuiltList<GameEvent> evList) {
    // Same length, don't recalculate.
    if (evList.length == state.gameEvents.length && state.loadedEvents) {
      return;
    }
    Map<String, GamePlayerSummaryBuilder> players = state.game.players
        .toMap()
        .map((var e, var v) => MapEntry(e, GamePlayerSummaryBuilder()));
    Map<String, GamePlayerSummaryBuilder> opponents = state.game.opponents
        .toMap()
        .map((var e, var v) => MapEntry(e, GamePlayerSummaryBuilder()));
    GameSummaryBuilder gameSummary = GameSummaryBuilder()
      ..pointsFor = 0
      ..pointsAgainst = 0;
    GamePlayerSummaryBuilder playerSummary = GamePlayerSummaryBuilder();
    GamePlayerSummaryBuilder opponentSummary = GamePlayerSummaryBuilder();

    var sortedList = evList.toList();
    sortedList
        .sort((GameEvent a, GameEvent b) => a.timestamp.compareTo(b.timestamp));
    GamePeriod currentPeriod = GamePeriod.notStarted;

    // Check the summary and update if needed.
    for (GameEvent ev in sortedList) {
      PlayerSummaryDataBuilder sum;
      PlayerSummaryDataBuilder playerSum;
      GamePeriod oldPeriod = currentPeriod;
      var getPlayerSum = (String playerUid) {
        if (ev.opponent) {
          return opponents[playerUid]
              .perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
        } else {
          return players[playerUid]
              .perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
        }
      };

      if (ev.type != GameEventType.PeriodStart &&
          ev.type != GameEventType.PeriodEnd &&
          ev.type != GameEventType.TimeoutEnd &&
          ev.type != GameEventType.TimeoutStart) {
        if (ev.opponent) {
          sum = opponentSummary.perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
          // .putIfAbsent(currentPeriod, () => PlayerSummaryData());
          playerSum = opponents[ev.playerUid]
              .perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
        } else {
          sum = playerSummary.perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
          playerSum = players[ev.playerUid]
              .perPeriod
              .putIfAbsent(currentPeriod, () => PlayerSummaryData())
              .toBuilder();
        }
        playerSum = getPlayerSum(ev.playerUid);
      }
      switch (ev.type) {
        case GameEventType.Made:
          if (ev.points == 1) {
            sum.one.made++;
            sum.one.attempts++;
            playerSum.one.made++;
            playerSum.one.attempts++;
          } else if (ev.points == 2) {
            sum.two.made++;
            sum.two.attempts++;
            playerSum.two.made++;
            playerSum.two.attempts++;
          } else if (ev.points == 3) {
            sum.three.made++;
            sum.three.attempts++;
            playerSum.three.made++;
            playerSum.three.attempts++;
          }
          if (ev.opponent) {
            gameSummary.pointsAgainst += ev.points;
          } else {
            gameSummary.pointsFor += ev.points;
          }
          if (ev.assistPlayerUid != null) {
            var assistSummary = getPlayerSum(ev.playerUid);
            assistSummary.assists++;
            sum.assists++;
          }
          break;
        case GameEventType.Missed:
          if (ev.points == 1) {
            sum.one.attempts++;
            playerSum.one.attempts++;
          } else if (ev.points == 2) {
            sum.two.attempts++;
            playerSum.two.attempts++;
          } else if (ev.points == 3) {
            sum.three.attempts++;
            playerSum.three.attempts++;
          }
          break;
        case GameEventType.Foul:
          sum.fouls++;
          playerSum.fouls++;
          break;
        case GameEventType.Sub:
          if (ev.opponent) {
            opponents[ev.playerUid].currentlyPlaying = false;
            opponents[ev.replacementPlayerUid].currentlyPlaying = true;
          } else {
            players[ev.playerUid].currentlyPlaying = false;
            players[ev.replacementPlayerUid].currentlyPlaying = true;
          }
          break;
        case GameEventType.OffsensiveRebound:
          sum.offensiveRebounds++;
          playerSum.offensiveRebounds++;
          break;
        case GameEventType.DefensiveRebound:
          sum.defensiveRebounds++;
          playerSum.defensiveRebounds++;
          break;
        case GameEventType.Block:
          sum.blocks++;
          playerSum.blocks++;
          break;
        case GameEventType.Steal:
          sum.steals++;
          playerSum.steals++;
          break;
        case GameEventType.Turnover:
          sum.turnovers++;
          playerSum.turnovers++;
          break;
        case GameEventType.PeriodStart:
          currentPeriod = ev.period;
          if (ev.period == GamePeriod.finalPeriod) {
            gameSummary.finished = true;
          } else {
            gameSummary.finished = false;
          }
          break;
      }
      if (ev.type != GameEventType.PeriodStart &&
          ev.type != GameEventType.PeriodEnd &&
          ev.type != GameEventType.TimeoutEnd &&
          ev.type != GameEventType.TimeoutStart) {
        if (ev.opponent) {
          opponentSummary.perPeriod[oldPeriod] = sum.build();
          opponents[ev.playerUid].perPeriod[oldPeriod] = playerSum.build();
        } else {
          playerSummary.perPeriod[oldPeriod] = sum.build();
          players[ev.playerUid].perPeriod[oldPeriod] = playerSum.build();
        }
      }
    }

    // See if this is different the current state and update if it is.
    print(gameSummary.build());
    if (state.game.playerSummaery != playerSummary.build() ||
        state.game.opponentSummary != opponentSummary.build() ||
        state.game.summary != gameSummary.build() ||
        state.game.players.entries.every(
            (MapEntry<String, GamePlayerSummary> e) =>
                players[e.key].build() == e.value) ||
        state.game.currentPeriod != currentPeriod ||
        state.game.opponents.entries.every(
            (MapEntry<String, GamePlayerSummary> e) =>
                opponents[e.key].build() == e.value)) {
      db.updateFirestoreGame(
          state.game.rebuild((b) => b
            ..summary = gameSummary
            ..opponentSummary = opponentSummary
            ..playerSummaery = playerSummary
            ..currentPeriod = currentPeriod.toBuilder()
            ..players = MapBuilder(
                players.map((var e, var v) => MapEntry(e, v.build())))
            ..opponents = MapBuilder(
                opponents.map((var e, var v) => MapEntry(e, v.build())))),
          false);
    }

    var removed = state.gameEvents
        .where((GameEvent e) => evList.every((GameEvent e2) => e != e2));
    var added = evList.where(
        (GameEvent e) => state.gameEvents.every((GameEvent e2) => e != e2));
    add(_SingleGameNewEvents(
        events: evList,
        removedEvents: BuiltList.of(removed),
        newEvents: BuiltList.of(added)));
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
