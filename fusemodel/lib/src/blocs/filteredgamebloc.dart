import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'gamesbloc.dart';
import 'teambloc.dart';

///
/// The set of filtered games.
///
class FilteredGameState extends Equatable {
  final Map<String, Game> games;
  final FilterDetails filter;
  final DateTime start;
  final DateTime end;

  FilteredGameState(
      {@required this.games,
      @required this.filter,
      @required this.start,
      @required this.end});
}

///
/// Not initialized filter set.
///
class FilteredGameUninitialized extends FilteredGameState {
  FilteredGameUninitialized()
      : super(
            games: {},
            filter: FilterDetails(),
            start: DateTime.now(),
            end: DateTime.now());
}

///
/// The loaded state.
///
class FilteredGameLoaded extends FilteredGameState {
  FilteredGameLoaded(
      {Map<String, Game> games,
      FilterDetails filter,
      DateTime start,
      DateTime end})
      : super(games: games, filter: filter, start: start, end: end);
}

///
/// The loading state, this is triggered when the filter changes or the basic
/// set of games does not match the existing set.
///
class FilterGameLoading extends FilteredGameState {
  FilterGameLoading(Map<String, Game> games, FilterDetails filter,
      DateTime start, DateTime end)
      : super(games: games, filter: filter, start: start, end: end);
}

class FilteredGameEvent extends Equatable {}

class _FilteredGameEventGamesLoaded extends FilteredGameEvent {
  GameLoaded loaded;

  _FilteredGameEventGamesLoaded({@required this.loaded});
}

class _FilteredGameEventGamesUpdated extends FilteredGameEvent {
  GameLoaded loaded;

  _FilteredGameEventGamesUpdated({@required this.loaded});
}

class _FilteredGameEventGamesLogout extends FilteredGameEvent {
  _FilteredGameEventGamesLogout();
}

class _FilteredGameEventUpdatedStuff extends FilteredGameEvent {
  _FilteredGameEventUpdatedStuff();
}

///
/// Updates the filter to use for the game set.
///
class FilteredGameEventUpdateFilter extends FilteredGameEvent {
  final FilterDetails filter;

  FilteredGameEventUpdateFilter({@required this.filter});
}

///
/// Updates the dates we use for the date ranges.
///
class FilteredGameEventUpdateDates extends FilteredGameEvent {
  final DateTime start;
  final DateTime end;

  FilteredGameEventUpdateDates({@required this.start, @required this.end});
}

///
/// The game bloc that handles filtering all the games from the firestore
/// system.
///
class FilteredGameBloc extends Bloc<FilteredGameEvent, FilteredGameState> {
  final GameBloc gameBloc;
  final TeamBloc teamBloc;

  Map<String, StreamSubscription<GameSnapshotEvent>> _newerGameSubscriptions =
      {};
  Map<String, StreamSubscription<GameSnapshotEvent>> _olderGameSubscriptions =
      {};
  Map<String, Iterable<Game>> _newerGamesByTeam = {};
  Map<String, Map<String, Game>> _olderGamesByTeam = {};

  StreamSubscription<GameState> _gameSub;

  FilteredGameBloc({@required this.gameBloc, @required this.teamBloc}) {
    _gameSub = gameBloc.state.listen((GameState state) {
      if (state is GameLoaded) {
        dispatch(_FilteredGameEventGamesLoaded(loaded: state));
      } else {
        dispatch(_FilteredGameEventGamesLogout());
      }
    });
  }

  @override
  FilteredGameState get initialState => FilteredGameUninitialized();

  @override
  void dispose() {
    super.dispose();
    _cleanup();
    _gameSub.cancel();
    _gameSub = null;
  }

  void _cleanup() {}

  void _loadMoreGames() {
    if (currentState.start.isBefore(gameBloc.currentState.start)) {
      // Load all of this from the world of firestore.
      Map<String, Game> newGames = new Map<String, Game>();
      for (String teamUid in teamBloc.currentState.allTeamUids) {
        if (!_newerGameSubscriptions.containsKey(teamUid)) {
          String myUid = teamUid;
          _newerGameSubscriptions[teamUid] = gameBloc
              .coordinationBloc.databaseUpdateModel
              .getBasicGames(
                  start: currentState.start,
                  end: gameBloc.currentState.start,
                  teamUid: teamUid)
              .listen((GameSnapshotEvent gse) {
            if (gse.type == GameSnapshotEventType.GameList) {
              _newerGamesByTeam[myUid] = gse.newGames;
              dispatch(_FilteredGameEventUpdatedStuff());
            } else {
              List<Game> updateGames = _newerGamesByTeam[myUid].toList();
              for (Game g in _newerGamesByTeam[myUid]) {
                if (g.uid == gse.gameUid) {
                  updateGames.remove(g);
                  updateGames.add(g.rebuild(
                      (b) => b..sharedData = gse.sharedGame.toBuilder()));
                }
              }
              _newerGamesByTeam[myUid] = updateGames;
              dispatch(_FilteredGameEventUpdatedStuff());
            }
          });
        }
      }
    }
    if (currentState.end.isAfter(gameBloc.currentState.end)) {}
  }

  // Filter the games down by the current filter.  This is based on the
  // existing basic game set.  If this filter is not encompased inside this
  // then we need to do a query to get more data.
  Map<String, Game> _filterGames(GameLoaded state, FilterDetails details) {
    Map<String, Game> result = {};

    for (Map<String, Game> teamGames in state.gamesByTeam.values) {
      for (Game g in teamGames.values) {
        Team t = teamBloc.currentState.getTeam(g.teamUid);
        if (t != null) {
          // See if we have the eason.
          if (t.seasons.containsKey(g.seasonUid)) {
            // We do.  Yay.
            Season season = t.seasons[g.seasonUid];
            if (details.isIncluded(g, season)) {
              result[g.uid] = g;
            }
          }
        }
      }
    }
    for (Iterable<Game> gameList in _newerGamesByTeam.values) {
      for (Game g in gameList) {
        Team t = teamBloc.currentState.getTeam(g.teamUid);
        if (t != null) {
          // See if we have the eason.
          if (t.seasons.containsKey(g.seasonUid)) {
            // We do.  Yay.
            Season season = t.seasons[g.seasonUid];
            if (details.isIncluded(g, season)) {
              result[g.uid] = g;
            }
          }
        }
      }
    }
    return result;
  }

  @override
  Stream<FilteredGameState> mapEventToState(FilteredGameEvent event) async* {
    if (event is _FilteredGameEventGamesLoaded) {
      // Filter the loaded games :)
      yield FilteredGameLoaded(
          games: _filterGames(event.loaded, currentState.filter),
          filter: currentState.filter,
          start: event.loaded.start,
          end: event.loaded.end);
    }
    if (event is FilteredGameEventUpdateFilter) {
      yield FilteredGameLoaded(
          games: _filterGames(
              gameBloc.currentState.gamesByTeam as GameLoaded, event.filter),
          filter: event.filter,
          start: currentState.start,
          end: currentState.end);
    }
    if (event is _FilteredGameEventGamesLogout) {
      _cleanup();
      yield FilteredGameUninitialized();
    }
    // Our internal set of stuff updated.
    if (event is _FilteredGameEventUpdatedStuff) {
      yield FilteredGameLoaded(
          games: _filterGames(gameBloc.currentState.gamesByTeam as GameLoaded,
              currentState.filter),
          filter: currentState.filter,
          start: currentState.start,
          end: currentState.end);
    }
  }
}
