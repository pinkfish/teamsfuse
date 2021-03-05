import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:clock/clock.dart';
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
  final BuiltList<Game> games;
  final String teamUid;

  _GameEventNewDataLoaded({@required this.teamUid, @required this.games});

  @override
  List<Object> get props => [teamUid, games];
}

///
/// Sets the boundaries for the games.
///
class GameEventSetBoundaries extends GameBlocEvent {
  /// The new start point.
  final DateTime start;

  /// The new end point.
  final DateTime end;

  /// Create the game boundaries event
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
  final Map<String, StreamSubscription<BuiltList<Game>>> _gameSubscriptions =
      {};
  DateTime _start;
  DateTime _end;

  GameBloc(
      {@required this.coordinationBloc,
      @required this.teamBloc,
      @required this.crashes})
      : _start = clock.now().subtract(Duration(days: 60)).toUtc(),
        _end = clock.now().add(Duration(days: 240)).toUtc(),
        super(GameUninitialized()) {
    if (teamBloc.state is TeamLoaded) {
      _onTeamsUpdates(teamBloc.state.allTeamUids, true);
    }
    _teamSub = teamBloc.listen((TeamState state) {
      if (state is TeamLoaded) {
        _start = _start ?? clock.now().subtract(Duration(days: 60)).toUtc();
        _end = _end ?? clock.now().add(Duration(days: 240)).toUtc();
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
    await _teamSub?.cancel();
    _teamSub = null;
  }

  void _cleanupStuff() {
    for (var sub in _gameSubscriptions.values) {
      sub.cancel();
    }
    _gameSubscriptions.clear();
  }

  void _onTeamsUpdates(Set<String> uids, bool updateBoundary) {
    // Load all of this from the world of firestore.
    for (var teamUid in uids) {
      if (!_gameSubscriptions.containsKey(teamUid) || updateBoundary) {
        _gameSubscriptions[teamUid]?.cancel();
        var myUid = teamUid;
        _gameSubscriptions[teamUid] = coordinationBloc.databaseUpdateModel
            .getBasicGames(start: _start, end: _end, teamUid: teamUid)
            .listen((gse) {
          add(_GameEventNewDataLoaded(teamUid: myUid, games: gse));
        });
        _gameSubscriptions[teamUid].onError(crashes.recordException);
      }
    }
  }

  @override
  Stream<GameState> mapEventToState(GameBlocEvent event) async* {
    // New data from above.  Mark ourselves as done.
    if (event is _GameEventNewDataLoaded) {
      var newGames = state.gamesByTeam.toBuilder();
      newGames[event.teamUid] = event.games;
      var gamesToSerialize = state.gamesByTeamToSerialize.toBuilder();
      for (var g in event.games) {
        if (g.sharedData.tzTime.isAfter(state.start) &&
            g.sharedData.tzTime.isBefore(state.end)) {
          gamesToSerialize[g.uid] = g;
        }
      }
      yield (GameLoaded.fromState(state)
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
    if (json == null || !json.containsKey('type')) {
      return GameUninitialized();
    }

    var type = GameBlocStateType.valueOf(json['type']);
    switch (type) {
      case GameBlocStateType.Uninitialized:
        return GameUninitialized();
      case GameBlocStateType.Loaded:
        try {
          var gamesTrace = coordinationBloc.analytics.newTrace('gamaData');
          gamesTrace.start();
          var loaded = GameLoaded.fromMap(json);
          var gamesByTeam = MapBuilder<String, ListBuilder<Game>>();
          for (var g in loaded.gamesByTeamToSerialize.values) {
            gamesByTeam.putIfAbsent(g.teamUid, () => ListBuilder<Game>());
            gamesByTeam[g.teamUid].add(g);
          }

          var built = gamesByTeam.build();
          var rebuild = MapBuilder<String, BuiltList<Game>>();
          for (var uid in built.keys) {
            rebuild[uid] = built[uid].build();
          }

          loaded = loaded.rebuild((b) => b..gamesByTeam = rebuild);
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
