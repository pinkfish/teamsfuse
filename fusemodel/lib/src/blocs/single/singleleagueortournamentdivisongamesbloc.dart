import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentdivisonbloc.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentDivisonGamesState extends Equatable {
  final BuiltMap<String, GameSharedData> leagueOrTournamentGames;
  final bool loadedGames;

  SingleLeagueOrTournamentDivisonGamesState(
      {@required this.leagueOrTournamentGames, @required this.loadedGames})
      : super([leagueOrTournamentGames, loadedGames]);
}

///
/// Loaded all the games.
///
class SingleLeagueOrTournamentDivisonGamesLoaded
    extends SingleLeagueOrTournamentDivisonGamesState {
  SingleLeagueOrTournamentDivisonGamesLoaded(
      SingleLeagueOrTournamentDivisonGamesState state,
      {BuiltMap<String, GameSharedData> leagueOrTournamentGames,
      bool loadedGames})
      : super(
            leagueOrTournamentGames:
                leagueOrTournamentGames ?? state.leagueOrTournamentGames,
            loadedGames: loadedGames ?? state.loadedGames);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonGamesLoaded{}';
  }
}

///
/// Loading...
///
class SingleLeagueOrTournamentDivisonGamesLoading
    extends SingleLeagueOrTournamentDivisonGamesState {
  SingleLeagueOrTournamentDivisonGamesLoading(
      {@required SingleLeagueOrTournamentDivisonGamesState leagueOrTournament})
      : super(
            leagueOrTournamentGames: leagueOrTournament.leagueOrTournamentGames,
            loadedGames: leagueOrTournament.loadedGames);
  SingleLeagueOrTournamentDivisonGamesLoading.empty()
      : super(leagueOrTournamentGames: BuiltMap(), loadedGames: false);
  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonLoading{}';
  }
}

abstract class SingleLeagueOrTournamentDivisonGamesEvent extends Equatable {}

class _SingleLeagueOrTournamentEventDivisonGamesLoaded
    extends SingleLeagueOrTournamentDivisonGamesEvent {
  Iterable<GameSharedData> games;

  _SingleLeagueOrTournamentEventDivisonGamesLoaded({this.games});
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentDivisonGamesBloc extends Bloc<
    SingleLeagueOrTournamentDivisonGamesEvent,
    SingleLeagueOrTournamentDivisonGamesState> {
  final SingleLeagueOrTournamentDivisonBloc singleLeagueOrTournamentDivisonBloc;

  StreamSubscription<Iterable<GameSharedData>> _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentDivisonGamesBloc(
      {@required this.singleLeagueOrTournamentDivisonBloc}) {
    _leagueOrTournamentSnapshot = singleLeagueOrTournamentDivisonBloc
        .singleLeagueOrTournamentSeasonBloc
        .singleLeagueOrTournamentBloc
        .leagueOrTournamentBloc
        .coordinationBloc
        .databaseUpdateModel
        .getLeagueGamesForDivison(
            singleLeagueOrTournamentDivisonBloc.leagueDivisonUid)
        .listen((Iterable<GameSharedData> games) => _updateGames(games));
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
  }

  @override
  SingleLeagueOrTournamentDivisonGamesState get initialState {
    return SingleLeagueOrTournamentDivisonGamesLoading.empty();
  }

  void _updateGames(Iterable<GameSharedData> games) {
    dispatch(_SingleLeagueOrTournamentEventDivisonGamesLoaded(games: games));
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonGamesState> mapEventToState(
      SingleLeagueOrTournamentDivisonGamesEvent event) async* {
    if (event is SingleLeagueOrTournamentDivisonLoadTeams) {
      if (!currentState.loadedGames) {}
    }

    if (event is _SingleLeagueOrTournamentEventDivisonGamesLoaded) {
      Map<String, GameSharedData> newTeams = {};
      for (GameSharedData game in event.games) {
        newTeams[game.uid] = game;
      }
      yield SingleLeagueOrTournamentDivisonGamesLoaded(currentState,
          leagueOrTournamentGames: BuiltMap.from(newTeams), loadedGames: true);
    }
  }
}
