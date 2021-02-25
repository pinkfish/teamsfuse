import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'gamesbloc.dart';
import 'seasonbloc.dart';
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

  @override
  List<Object> get props => [games, filter, start, end];
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

abstract class FilteredGameEvent extends Equatable {}

class _FilteredGameEventGamesLoaded extends FilteredGameEvent {
  final GameLoaded loaded;

  _FilteredGameEventGamesLoaded({@required this.loaded});

  @override
  List<Object> get props => [loaded];
}

class _FilteredGameEventGamesLogout extends FilteredGameEvent {
  @override
  List<Object> get props => [];
}

///
/// Updates the filter to use for the game set.
///
class FilteredGameEventUpdateFilter extends FilteredGameEvent {
  final FilterDetails filter;

  FilteredGameEventUpdateFilter({@required this.filter});

  @override
  List<Object> get props => [filter];
}

///
/// Updates the dates we use for the date ranges.
///
class FilteredGameEventUpdateDates extends FilteredGameEvent {
  final DateTime start;
  final DateTime end;

  FilteredGameEventUpdateDates({@required this.start, @required this.end});

  @override
  List<Object> get props => [start, end];
}

///
/// The game bloc that handles filtering all the games from the firestore
/// system.
///
class FilteredGameBloc extends Bloc<FilteredGameEvent, FilteredGameState> {
  final GameBloc gameBloc;
  final TeamBloc teamBloc;
  final SeasonBloc seasonBloc;

  Map<String, BuiltList<Game>> _newerGamesByTeam = {};

  StreamSubscription<GameState> _gameSub;

  FilteredGameBloc(
      {@required this.gameBloc,
      @required this.teamBloc,
      @required this.seasonBloc})
      : super(FilteredGameUninitialized()) {
    _gameSub = gameBloc.listen((GameState gameState) {
      if (gameState is GameLoaded) {
        add(_FilteredGameEventGamesLoaded(loaded: gameState));
      } else {
        add(_FilteredGameEventGamesLogout());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanup();
    _gameSub.cancel();
    _gameSub = null;
  }

  void _cleanup() {}

  // Filter the games down by the current filter.  This is based on the
  // existing basic game set.  If this filter is not encompased inside this
  // then we need to do a query to get more data.
  Map<String, Game> _filterGames(GameState state, FilterDetails details) {
    var result = <String, Game>{};

    for (var teamGames in state.gamesByTeam.values) {
      for (var g in teamGames) {
        var t = teamBloc.state.getTeam(g.teamUid);
        if (t != null) {
          SeasonState seasonState = seasonBloc.state;
          // See if we have the eason.
          if (seasonState.seasons.containsKey(g.seasonUid)) {
            // We do.  Yay.
            Season season = seasonState.seasons[g.seasonUid];
            if (details.isIncluded(g, season)) {
              result[g.uid] = g;
            }
          }
        }
      }
    }
    for (var gameList in _newerGamesByTeam.values) {
      for (var g in gameList) {
        var t = teamBloc.state.getTeam(g.teamUid);
        if (t != null) {
          SeasonState seasonState = seasonBloc.state;
          // See if we have the season.
          if (seasonState.seasons.containsKey(g.seasonUid)) {
            // We do.  Yay.
            Season season = seasonState.seasons[g.seasonUid];
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
          games: _filterGames(event.loaded, state.filter),
          filter: state.filter,
          start: event.loaded.start,
          end: event.loaded.end);
    }
    if (event is FilteredGameEventUpdateFilter) {
      yield FilteredGameLoaded(
          games: _filterGames(
              gameBloc.state.gamesByTeam as GameLoaded, event.filter),
          filter: event.filter,
          start: state.start,
          end: state.end);
    }

    if (event is _FilteredGameEventGamesLogout) {
      _cleanup();
      yield FilteredGameUninitialized();
    }

    // Our internal set of stuff updated.
    if (event is FilteredGameEventUpdateDates) {
      gameBloc.add(GameEventSetBoundaries(
        start: event.start,
        end: event.end,
      ));
      yield FilteredGameLoaded(
          games: _filterGames(gameBloc.state, state.filter),
          filter: state.filter,
          start: event.start,
          end: event.end);
    }
  }
}
