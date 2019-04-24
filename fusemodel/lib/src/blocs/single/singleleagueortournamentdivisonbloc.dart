import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentseasonbloc.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentDivisonState extends Equatable {
  final LeagueOrTournamentDivison leagueOrTournamentDivison;
  final Map<String, LeagueOrTournamentTeam> leagueOrTournamentTeams;
  final Map<String, GameSharedData> games;

  SingleLeagueOrTournamentDivisonState(
      {@required this.leagueOrTournamentDivison,
      @required this.leagueOrTournamentTeams,
      @required this.games});
}

///
/// Doing something.
///
class SingleLeagueOrTournamentDivisonLoaded
    extends SingleLeagueOrTournamentDivisonState {
  SingleLeagueOrTournamentDivisonLoaded(
      {@required LeagueOrTournamentDivison leagueOrTournamentDivison,
      @required Map<String, LeagueOrTournamentTeam> leagueOrTournamentTeams,
      @required Map<String, GameSharedData> games})
      : super(
            leagueOrTournamentDivison: leagueOrTournamentDivison,
            leagueOrTournamentTeams: leagueOrTournamentTeams,
            games: games);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonLoaded{}';
  }
}

///
/// Saveing failed, with an specified error.
///
class SingleLeagueOrTournamentDivisonSaveFailed
    extends SingleLeagueOrTournamentDivisonState {
  final Error error;

  SingleLeagueOrTournamentDivisonSaveFailed(
      {@required SingleLeagueOrTournamentDivisonState leagueOrTournament,
      @required this.error})
      : super(
            leagueOrTournamentDivison:
                leagueOrTournament.leagueOrTournamentDivison,
            leagueOrTournamentTeams: leagueOrTournament.leagueOrTournamentTeams,
            games: leagueOrTournament.games);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonSaveFailed{}';
  }
}

///
/// In the process of saving.
///
class SingleLeagueOrTournamentDivisonSaving
    extends SingleLeagueOrTournamentDivisonState {
  SingleLeagueOrTournamentDivisonSaving(
      {@required SingleLeagueOrTournamentDivisonState leagueOrTournament})
      : super(
            leagueOrTournamentDivison:
                leagueOrTournament.leagueOrTournamentDivison,
            leagueOrTournamentTeams: leagueOrTournament.leagueOrTournamentTeams,
            games: leagueOrTournament.games);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonSaving{}';
  }
}

///
/// Deleted
///
class SingleLeagueOrTournamentDivisonDeleted
    extends SingleLeagueOrTournamentDivisonState {
  SingleLeagueOrTournamentDivisonDeleted(
      {@required SingleLeagueOrTournamentDivisonState leagueOrTournament})
      : super(
            leagueOrTournamentDivison:
                leagueOrTournament.leagueOrTournamentDivison,
            games: leagueOrTournament.games,
            leagueOrTournamentTeams:
                leagueOrTournament.leagueOrTournamentTeams);
  SingleLeagueOrTournamentDivisonDeleted.empty()
      : super(
            leagueOrTournamentDivison: null,
            leagueOrTournamentTeams: {},
            games: {});
  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonDeleted{}';
  }
}

abstract class SingleLeagueOrTournamentDivisonEvent extends Equatable {}

class _SingleLeagueOrTournamentEventLeagueDivisonLoaded
    extends SingleLeagueOrTournamentDivisonEvent {
  final LeagueOrTournamentDivison leagueDivision;

  _SingleLeagueOrTournamentEventLeagueDivisonLoaded(
      {@required this.leagueDivision});

  @override
  String toString() {
    return '_SingleLeagueOrTournamentEventLeagueDivisonLoaded{}';
  }
}

class _SingleLeagueOrTournamentEventDivisonDeleted
    extends SingleLeagueOrTournamentDivisonEvent {}

class _SingleLeagueOrTournamentEventDivisonTeams
    extends SingleLeagueOrTournamentDivisonEvent {
  Iterable<LeagueOrTournamentTeam> teams;

  _SingleLeagueOrTournamentEventDivisonTeams({this.teams});
}

class _SingleLeagueOrTournamentEventDivisonGames
    extends SingleLeagueOrTournamentDivisonEvent {
  Iterable<GameSharedData> games;

  _SingleLeagueOrTournamentEventDivisonGames({this.games});
}

///
/// Loads the Teams for this league or tournament.
///
class SingleLeagueOrTournamentDivisonLoadTeams
    extends SingleLeagueOrTournamentDivisonEvent {}

///
/// Loads the Games for this league or tournament.
///
class SingleLeagueOrTournamentDivisonLoadGames
    extends SingleLeagueOrTournamentDivisonEvent {}

///
/// Writes the updated data out to the database.
///
class SingleLeagueOrTournamentDivisonUpdate
    extends SingleLeagueOrTournamentDivisonEvent {
  final LeagueOrTournamentDivison leagueOrTournamentDivison;

  SingleLeagueOrTournamentDivisonUpdate(
      {@required this.leagueOrTournamentDivison});
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentDivisonBloc extends Bloc<
    SingleLeagueOrTournamentDivisonEvent,
    SingleLeagueOrTournamentDivisonState> {
  final SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc;
  final String leagueDivisonUid;

  StreamSubscription<SingleLeagueOrTournamentSeasonState> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournamentTeam>>
      _leagueOrTournamentSnapshot;
  StreamSubscription<Iterable<GameSharedData>> _gamesSnapshot;

  SingleLeagueOrTournamentDivisonBloc(
      {@required this.singleLeagueOrTournamentSeasonBloc,
      @required this.leagueDivisonUid}) {
    _coordSub = singleLeagueOrTournamentSeasonBloc.state
        .listen((SingleLeagueOrTournamentSeasonState state) {
      if (state is SingleLeagueOrTournamentSeasonLoaded) {
        if (state.leagueOrTournamentDivisons.containsKey(leagueDivisonUid)) {
          dispatch(_SingleLeagueOrTournamentEventLeagueDivisonLoaded(
              leagueDivision:
                  state.leagueOrTournamentDivisons[leagueDivisonUid]));
        } else {
          dispatch(_SingleLeagueOrTournamentEventDivisonDeleted());
        }
      }
      if (state is SingleLeagueOrTournamentSeasonDeleted) {
        dispatch(_SingleLeagueOrTournamentEventDivisonDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
    _gamesSnapshot?.cancel();
    _gamesSnapshot = null;
  }

  @override
  SingleLeagueOrTournamentDivisonState get initialState {
    if (singleLeagueOrTournamentSeasonBloc
        .currentState.leagueOrTournamentDivisons
        .containsKey(leagueDivisonUid)) {
      return SingleLeagueOrTournamentDivisonLoaded(
          leagueOrTournamentDivison: singleLeagueOrTournamentSeasonBloc
              .currentState.leagueOrTournamentDivisons[leagueDivisonUid],
          games: {},
          leagueOrTournamentTeams: {});
    } else {
      return SingleLeagueOrTournamentDivisonDeleted.empty();
    }
  }

  void _updateTeams(Iterable<LeagueOrTournamentTeam> teams) {
    dispatch(_SingleLeagueOrTournamentEventDivisonTeams(teams: teams));
  }

  void _updateGames(Iterable<GameSharedData> games) {
    dispatch(_SingleLeagueOrTournamentEventDivisonGames(games: games));
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentDivisonState> _updateLeagueOrTournamentDivison(
      {LeagueOrTournamentDivison divison}) async* {
    if (divison.uid == leagueDivisonUid) {
      yield SingleLeagueOrTournamentDivisonSaving(
          leagueOrTournament: currentState);
      try {
        await singleLeagueOrTournamentSeasonBloc.singleLeagueOrTournamentBloc
            .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .updateLeagueDivison(divison);
        yield SingleLeagueOrTournamentDivisonLoaded(
            leagueOrTournamentDivison: currentState.leagueOrTournamentDivison,
            games: currentState.games,
            leagueOrTournamentTeams: currentState.leagueOrTournamentTeams);
      } catch (e) {
        yield SingleLeagueOrTournamentDivisonSaveFailed(
            leagueOrTournament: currentState, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentDivisonSaveFailed(
          leagueOrTournament: currentState,
          error: ArgumentError("league uids don't match"));
    }
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonState> mapEventToState(
      SingleLeagueOrTournamentDivisonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueDivisonLoaded) {
      yield SingleLeagueOrTournamentDivisonLoaded(
          leagueOrTournamentDivison: event.leagueDivision,
          leagueOrTournamentTeams: currentState.leagueOrTournamentTeams,
          games: currentState.games);
    }

    if (event is SingleLeagueOrTournamentDivisonLoadTeams) {
      _leagueOrTournamentSnapshot = singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .getLeagueDivisionTeams(leagueDivisonUid)
          .listen((Iterable<LeagueOrTournamentTeam> divisons) =>
              _updateTeams(divisons));
    }

    if (event is SingleLeagueOrTournamentDivisonLoadGames) {
      _gamesSnapshot = singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .getLeagueGamesForDivison(leagueDivisonUid)
          .listen((Iterable<GameSharedData> games) => _updateGames(games));
    }

    if (event is _SingleLeagueOrTournamentEventDivisonTeams) {
      Map<String, LeagueOrTournamentTeam> newTeams = {};
      for (LeagueOrTournamentTeam team in event.teams) {
        newTeams[team.uid] = team;
      }
      yield SingleLeagueOrTournamentDivisonLoaded(
          leagueOrTournamentDivison: currentState.leagueOrTournamentDivison,
          leagueOrTournamentTeams: newTeams,
          games: currentState.games);
    }

    if (event is _SingleLeagueOrTournamentEventDivisonGames) {
      Map<String, GameSharedData> newGames = {};
      for (GameSharedData game in event.games) {
        newGames[game.uid] = game;
      }
      yield SingleLeagueOrTournamentDivisonLoaded(
          leagueOrTournamentDivison: currentState.leagueOrTournamentDivison,
          leagueOrTournamentTeams: currentState.leagueOrTournamentTeams,
          games: newGames);
    }

    // Unload everything.
    if (event is _SingleLeagueOrTournamentEventDivisonDeleted) {
      yield SingleLeagueOrTournamentDivisonDeleted.empty();
      _cleanupStuff();
    }

    if (event is SingleLeagueOrTournamentDivisonUpdate) {
      yield* _updateLeagueOrTournamentDivison(
          divison: event.leagueOrTournamentDivison);
    }
  }
}
