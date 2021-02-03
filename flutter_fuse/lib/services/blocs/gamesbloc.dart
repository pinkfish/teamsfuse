import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';
import 'teambloc.dart';

abstract class GameBlocEvent extends Equatable {}

class _GameEventLogout extends GameBlocEvent {
  @override
  List<Object> get props => [];
}

class _GameEventNewDataLoaded extends GameBlocEvent {
  final Iterable<Game> games;
  final String teamUid;

  _GameEventNewDataLoaded({@required this.teamUid, @required this.games});

  @override
  List<Object> get props => [teamUid, games];
}

class GameEventSetBoundaries extends GameBlocEvent {
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
class GameBloc extends HydratedBloc<GameBlocEvent, GameState> {
  final CoordinationBloc coordinationBloc;
  final TeamBloc teamBloc;
  final AnalyticsSubsystem crashes;

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<FirestoreChangedData> _gameChangeSub;
  Map<String, StreamSubscription<GameSnapshotEvent>> _gameSubscriptions = {};
  DateTime _start;
  DateTime _end;

  GameBloc(
      {@required this.coordinationBloc,
      @required this.teamBloc,
      @required this.crashes})
      : _start = new DateTime.now().subtract(new Duration(days: 60)).toUtc(),
        _end = new DateTime.now().add(new Duration(days: 240)).toUtc(),
        super(GameUninitialized()) {
    if (teamBloc.state is TeamLoaded) {
      _onTeamsUpdates(teamBloc.state.allTeamUids, true);
    }
    _teamSub = teamBloc.listen((TeamState state) {
      if (state is TeamLoaded) {
        _start = _start ??
            new DateTime.now().subtract(new Duration(days: 60)).toUtc();
        _end = _end ?? new DateTime.now().add(new Duration(days: 240)).toUtc();
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
  Stream<GameState> mapEventToState(GameBlocEvent event) async* {
    // New data from above.  Mark ourselves as done.
    if (event is _GameEventNewDataLoaded) {
      MapBuilder<String, BuiltMap<String, Game>> newGames =
          state.gamesByTeam.toBuilder();
      MapBuilder<String, Game> gamesToSerialize = MapBuilder();
      for (Game g in event.games) {
        if (g.sharedData.tzTime.isAfter(state.start) &&
            g.sharedData.tzTime.isBefore(state.end)) {
          gamesToSerialize[g.uid] = g;
        }
      }
      MapBuilder<String, GameSharedData> sharedGameData = MapBuilder();
      MapBuilder<String, GameSharedData> sharedGameToSerialize = MapBuilder();
      for (Game g in event.games) {
        if (g.sharedDataUid.isNotEmpty) {
          sharedGameData[g.sharedDataUid] = g.sharedData;
          if (g.sharedData.tzTime.isAfter(state.start) &&
              g.sharedData.tzTime.isBefore(state.end)) {
            sharedGameToSerialize[g.sharedDataUid] = g.sharedData;
          }
        }
      }
      yield (GameLoaded.fromState(state)
            ..sharedGameData = sharedGameData
            ..sharedGameDataToSerialize = sharedGameToSerialize
            ..gamesByTeamToSerialize = gamesToSerialize
            ..gamesByTeam = newGames
            ..loadedFirestore = true
            ..start = _start.toUtc()
            ..end = _end.toUtc())
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Game));
    }

    // Unload everything.
    if (event is _GameEventLogout) {
      yield GameUninitialized((b) => b
        ..start = state.start
        ..end = state.end);
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
        try {
          TraceProxy gamesTrace =
              coordinationBloc.analyticsSubsystem.newTrace("gamaData");
          gamesTrace.start();
          var loaded = GameLoaded.fromMap(json);
          MapBuilder<String, MapBuilder<String, Game>> gamesByTeam =
              MapBuilder<String, MapBuilder<String, Game>>();
          for (Game g in loaded.gamesByTeamToSerialize.values) {
            gamesByTeam.putIfAbsent(
                g.teamUid, () => MapBuilder<String, Game>());
            gamesByTeam[g.teamUid][g.uid] = g;
          }

          var rebuilt = MapBuilder<String, BuiltMap<String, Game>>();
          gamesByTeam.updateAllValues((k, v) {
            rebuilt[k] = v.build();
            return v;
          });

          loaded = loaded.rebuild((b) => b..gamesByTeam = rebuilt);
          print('End games  ${loaded.gamesByTeam.length}');
          gamesTrace.stop();
          return loaded;
        } catch (e, stack) {
          if (e is Error) {
            crashes.recordError(e, stack);
          } else {
            crashes.recordException(e, stack);
          }
        }
        return GameUninitialized();
      default:
        return GameUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(GameState state) {
    return state.toMap();
  }
}
