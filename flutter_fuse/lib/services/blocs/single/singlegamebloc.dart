import 'dart:async';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';
import '../gamesbloc.dart';

/// The base class for al the single game events.
abstract class SingleGameEvent extends Equatable {}

///
/// Updates the game (writes it out to firebase.
///
class SingleGameUpdate extends SingleGameEvent {
  /// The game to update.
  final Game game;

  /// If we should update the shared data too.
  final bool updateShared;

  /// Update the game with new data.
  SingleGameUpdate({@required this.game, this.updateShared = false});

  @override
  List<Object> get props => [game, updateShared];
}

///
/// Updates the game (writes it out to firebase.
///
class SingleGameUpdateSharedData extends SingleGameEvent {
  final GameSharedData sharedData;

  SingleGameUpdateSharedData({
    @required this.sharedData,
  });
  @override
  List<Object> get props => [sharedData];
}

///
/// Delete this game from the world.
///
class SingleGameDelete extends SingleGameEvent {
  @override
  List<Object> get props => [];
}

///
/// Updated the attendence for the player.
///s
class SingleGameUpdateAttendance extends SingleGameEvent {
  /// The player uid for the player to update.
  final String playerUid;

  /// The new attendence details.
  final Attendance attendance;

  SingleGameUpdateAttendance({
    @required this.playerUid,
    @required this.attendance,
  });
  @override
  List<Object> get props => [playerUid, attendance];
}

///
/// Update the result for this game.
///s
class SingleGameUpdateResult extends SingleGameEvent {
  /// The result for this game.
  final GameResultDetails result;

  SingleGameUpdateResult({
    @required this.result,
  });
  @override
  List<Object> get props => [result];
}

///
/// Update the offical result for this game.
///s
class SingleGameUpdateOfficalResult extends SingleGameEvent {
  /// The new offical game results.
  final GameOfficialResults result;

  SingleGameUpdateOfficalResult({
    @required this.result,
  });

  @override
  List<Object> get props => [result];
}

///
/// Load the game eventsa
///
class SingleGameLoadEvents extends SingleGameEvent {
  @override
  List<Object> get props => [];
}

///
/// Load the game media
///
class SingleGameLoadMedia extends SingleGameEvent {
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
/// Loads the players for the game.
///
class SingleGameLoadPlayers extends SingleGameEvent {
  @override
  List<Object> get props => [];
}

///
/// Adds the guest player to the game.
///
class SingleGameAddGuestPlayer extends SingleGameEvent {
  /// The player to add.
  final String playerName;

  /// The jersey number to add.
  final String jerseyNumber;

  /// Create the guest player.
  SingleGameAddGuestPlayer(
    this.playerName,
    this.jerseyNumber,
  );

  @override
  List<Object> get props => [playerName, jerseyNumber];
}

///
/// Adds the opponent player to the game.
///
class SingleGameAddOpponentPlayer extends SingleGameEvent {
  /// The opponent name to add.
  final String opponentPlayerName;

  /// The jersey number of the opponent player.
  final String jerseyNumber;

  /// Create the guest player.
  SingleGameAddOpponentPlayer({
    this.opponentPlayerName,
    @required this.jerseyNumber,
  }) : assert(jerseyNumber != null);

  @override
  List<Object> get props => [opponentPlayerName, jerseyNumber];
}

///
/// Loads the players for the opponent.
///
class SingleGameLoadOpponentPlayers extends SingleGameEvent {
  @override
  List<Object> get props => [];
}

class _SingleGameNewGame extends SingleGameEvent {
  final Game newGame;

  _SingleGameNewGame({@required this.newGame});

  @override
  List<Object> get props => [newGame];
}

class _SingleGameDeleted extends SingleGameEvent {
  @override
  List<Object> get props => [];
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

class _SingleGameUpdateOpponents extends SingleGameEvent {
  final BuiltList<Player> opponentPlayers;

  _SingleGameUpdateOpponents({@required this.opponentPlayers});

  @override
  List<Object> get props => [opponentPlayers];
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

  static String createNew = 'new';

  StreamSubscription<Game> _gameSub;
  StreamSubscription<BuiltList<GameEvent>> _gameEventSub;
  StreamSubscription<BuiltList<MediaInfo>> _mediaInfoSub;

  Map<String, StreamSubscription<Player>> _players;
  Map<String, Player> _loadedPlayers;
  StreamSubscription<BuiltList<Player>> _opPlayers;

  SingleGameBloc(
      {@required this.gameUid,
      @required this.db,
      @required this.crashes,
      GameBloc gamesBloc})
      : super(_getInitialState(gameUid, gamesBloc), 'SingleGame' + gameUid) {
    _gameSub = db.getGame(gameUid).listen((g) {
      if (g != null) {
        add(_SingleGameNewGame(newGame: g));
      } else {
        print('Got null, pushing game deleted');
        add(_SingleGameDeleted());
      }
    });
    _gameSub.onError((e, stack) {
      crashes.recordException(e, stack);
      add(_SingleGameDeleted());
    });
  }

  static SingleGameState _getInitialState(String uid, GameBloc gameBloc) {
    final game = gameBloc.getGame(uid);
    if (game == null) {
      return SingleGameUninitialized();
    }
    return SingleGameLoaded((b) => b..game);
  }

  @override
  Future<void> close() async {
    await super.close();
    await _gameSub?.cancel();
    await _mediaInfoSub?.cancel();
    await _gameEventSub?.cancel();
    await _opPlayers?.cancel();
  }

  @override
  Stream<SingleGameState> mapEventToState(SingleGameEvent event) async* {
    if (event is _SingleGameNewGame) {
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
      if (state is SingleGameLoaded) {
        await _lock.synchronized(() {
          if (_gameEventSub == null) {
            _gameEventSub = db
                .getGameEvents(gameUid: gameUid)
                .listen((BuiltList<GameEvent> ev) => _newGameEvents(ev));
            _gameEventSub.onError((e, stack) {
              crashes.recordException(e, stack);
              _newGameEvents(BuiltList.of(<GameEvent>[]));
            });
            // See if we can find a player(s) for the opponent.  If so,
            // update our list.
          }
        });
      }
    }

    if (event is SingleGameLoadOpponentPlayers) {
      if (state is SingleGameLoaded) {
        await _lock.synchronized(() {
          if (_opPlayers == null) {
            _opPlayers = db
                .getPlayersForOpponent(
                    teamUid: state.game.teamUid,
                    opponentUid: state.game.opponentUid)
                .listen((pl) {
              add(_SingleGameUpdateOpponents(opponentPlayers: pl));
            });
            _opPlayers.onError((e, stack) {
              crashes.recordException(e, stack);
              debugPrint(stack, wrapWidth: 1024);
              add(_SingleGameUpdateOpponents(
                  opponentPlayers: BuiltList<Player>.of([])));
            });
          }
        });
      }
    }

    if (event is _SingleGameUpdateOpponents) {
      yield (SingleGameLoaded.fromState(state)..loadedOpponentPlayers = true)
          .build();
      var gameBuilder = state.game.toBuilder();
      var modified = false;
      for (var pl in event.opponentPlayers) {
        // Update stuff.
        if (!state.game.opponents.containsKey(pl.uid)) {
          gameBuilder.opponents[pl.uid] = GamePlayerSummary();
          modified = true;
        }
      }
      if (modified) {
        add(SingleGameUpdate(game: gameBuilder.build(), updateShared: false));
      }
    }

    if (event is SingleGameLoadMedia) {
      if (state is SingleGameLoaded) {
        await _lock.synchronized(() {
          if (_mediaInfoSub == null) {
            _mediaInfoSub = db.getMediaForGame(gameUid: gameUid).listen(
                (BuiltList<MediaInfo> ev) =>
                    add(_SingleGameNewMedia(newMedia: ev)));
            _mediaInfoSub.onError((e, stack) {
              crashes.recordException(e, stack);
              add(_SingleGameNewMedia(newMedia: BuiltList.of(<MediaInfo>[])));
            });
          }
        });
      }
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
        await db.updateFirestoreGame(event.game, event.updateShared);
        yield (SingleGameSaveDone.fromState(state)
              ..game = event.game.toBuilder())
            .build();
        yield (SingleGameLoaded.fromState(state)..game = event.game.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)..error = e).build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Load a single game.
    if (event is SingleGameLoadPlayers) {
      // Load all the player details for this season.
      await _lock.synchronized(() {
        for (var playerUid in state.game.players.keys) {
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
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Update attendence
    if (event is SingleGameUpdateAttendance) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreGameAttendence(
            state.game, event.playerUid, event.attendance);
        var builder = state.game.toBuilder();
        builder.attendance[event.playerUid] = event.attendance;
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)..game = builder).build();
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
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
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
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
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Updates a player in the game
    if (event is SingleGameUpdatePlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        for (var entry in event.summary.entries) {
          if (entry.value.opponent) {
            await db.updateGameOpponentData(
                gameUid: gameUid,
                summary: entry.value.summary,
                opponentUid: entry.key);
          } else {
            await db.updateGamePlayerData(
                gameUid: gameUid,
                summary: entry.value.summary,
                playerUid: entry.key);
          }
        }
        yield SingleGameSaveDone.fromState(state).build();
        yield SingleGameLoaded.fromState(state).build();
      } catch (error, stack) {
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(error.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(error, stack);
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

    // Add an opponent player.
    if (event is SingleGameAddOpponentPlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.addGameOpponentPlayer(
          teamUid: state.game.teamUid,
          gameUid: state.game.uid,
          opponentUid: state.game.opponentUid,
          opponentName: event.opponentPlayerName,
          jerseyNumber: event.jerseyNumber,
        );
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)).build();
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Add a guest player.
    if (event is SingleGameAddGuestPlayer) {
      yield SingleGameSaving.fromState(state).build();
      try {
        await db.addGameGuestPlayer(
          gameUid: state.game.uid,
          guestName: event.playerName,
          jerseyNumber: event.jerseyNumber,
        );
        yield SingleGameSaveDone.fromState(state).build();
        yield (SingleGameLoaded.fromState(state)).build();
      } catch (e, stack) {
        yield (SingleGameSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleGameLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
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
    var players = state.game.players
        .toMap()
        .map((var e, var v) => MapEntry(e, GamePlayerSummaryBuilder()));
    var opponents = state.game.opponents
        .toMap()
        .map((var e, var v) => MapEntry(e, GamePlayerSummaryBuilder()));
    var result = state.game.result.toBuilder();
    var playerSummary = GamePlayerSummaryBuilder();
    var opponentSummary = GamePlayerSummaryBuilder();

    var sortedList = evList.toList();
    sortedList
        .sort((GameEvent a, GameEvent b) => a.timestamp.compareTo(b.timestamp));
    var currentPeriod = GamePeriod.notStarted;
    var ptsAgainst = 0;
    var ptsFor = 0;

    // Check the summary and update if needed.
    for (var ev in sortedList) {
      PlayerSummaryDataBuilder sum;
      PlayerSummaryDataBuilder playerSum;
      var oldPeriod = currentPeriod;
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
          ev.type != GameEventType.TimeoutStart &&
          ev.type != GameEventType.ScoreSet) {
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
            ptsAgainst += ev.points;
          } else {
            ptsFor += ev.points;
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
        case GameEventType.OffensiveRebound:
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
          if (result.currentPeriod.type != ev.period.type) {
            ptsFor = 0;
            ptsAgainst = 0;
          }
          if (ev.period == GamePeriod.finalPeriod) {
            result.inProgress = GameInProgress.Final;
          } else {
            currentPeriod = ev.period;
            result.inProgress = GameInProgress.InProgress;
          }
          break;
        case GameEventType.PeriodEnd:
          var newCurrentPeriod = ev.period.toBuilder();
          newCurrentPeriod.periodNumber = 1;
          result.scoresInternal[newCurrentPeriod.build()] =
              GameResultPerPeriod((b) => b
                ..period = newCurrentPeriod
                ..score.ptsFor = ptsFor
                ..score.ptsAgainst = ptsAgainst);
          break;
        case GameEventType.ScoreSet:
          result.scoresInternal[ev.period] = GameResultPerPeriod((b) => b
            ..period = ev.period.toBuilder()
            ..score.ptsFor = ev.fixedScore.ptsFor
            ..score.ptsAgainst = ev.fixedScore.ptsFor);
          ptsFor = ev.fixedScore.ptsFor;
          ptsAgainst = ev.fixedScore.ptsAgainst;
          // Update this to be the end, no matter what if the score is set.
          result.inProgress = GameInProgress.Final;
          break;
      }
      if (ev.type != GameEventType.PeriodStart &&
          ev.type != GameEventType.PeriodEnd &&
          ev.type != GameEventType.ScoreSet) {
        if (ev.opponent) {
          opponentSummary.perPeriod[oldPeriod] = sum.build();
          opponents[ev.playerUid].perPeriod[oldPeriod] = playerSum.build();
        } else {
          playerSummary.perPeriod[oldPeriod] = sum.build();
          players[ev.playerUid].perPeriod[oldPeriod] = playerSum.build();
        }
      }
    }

    if (result.inProgress == GameInProgress.Final) {
      /// Setup the win/loss.
      var b = result.build();
      if (b.totalScore.ptsFor > b.totalScore.ptsAgainst) {
        result.result = GameResult.Win;
      } else if (b.totalScore.ptsFor < b.totalScore.ptsAgainst) {
        result.result = GameResult.Loss;
      } else {
        result.result = GameResult.Tie;
      }
    } else {
      // Update the current period score.
      var newCurrentPeriod = currentPeriod.toBuilder();
      newCurrentPeriod.periodNumber = 1;
      result.scoresInternal[newCurrentPeriod.build()] =
          GameResultPerPeriod((b) => b
            ..period = newCurrentPeriod
            ..score.ptsFor = ptsFor
            ..score.ptsAgainst = ptsAgainst);
    }

    // See if this is different the current state and update if it is.
    if (state.game.playerSummary != playerSummary.build() ||
        state.game.opponentSummary != opponentSummary.build() ||
        state.game.result != result.build() ||
        state.game.players.entries.every(
            (MapEntry<String, GamePlayerSummary> e) =>
                players[e.key].build() == e.value) ||
        state.game.result.currentPeriod != currentPeriod ||
        state.game.opponents.entries.every(
            (MapEntry<String, GamePlayerSummary> e) =>
                opponents[e.key].build() == e.value)) {
      db.updateFirestoreGame(
          state.game.rebuild((b) => b
            ..result = result
            ..opponentSummary = opponentSummary
            ..playerSummary = playerSummary
            ..result.currentPeriod = currentPeriod.toBuilder()
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
    if (!(state is SingleGameUninitialized)) {
      return state;
    }

    if (json == null || !json.containsKey('type')) {
      return SingleGameUninitialized();
    }
    try {
      var type = SingleGameBlocStateType.valueOf(json['type']);
      switch (type) {
        case SingleGameBlocStateType.Uninitialized:
          return SingleGameUninitialized();
        case SingleGameBlocStateType.Loaded:
          var ret = SingleGameLoaded.fromMap(json);
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
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleGameUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleGameState state) {
    return state.toMap();
  }
}
