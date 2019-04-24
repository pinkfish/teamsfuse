import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentbloc.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentSeasonState extends Equatable {
  final LeagueOrTournamentSeason leagueOrTournamentSeason;
  final Map<String, LeagueOrTournamentDivison> leagueOrTournamentDivisons;

  SingleLeagueOrTournamentSeasonState(
      {@required this.leagueOrTournamentSeason,
      @required this.leagueOrTournamentDivisons});
}

///
/// Doing something.
///
class SingleLeagueOrTournamentSeasonLoaded
    extends SingleLeagueOrTournamentSeasonState {
  SingleLeagueOrTournamentSeasonLoaded(
      {@required LeagueOrTournamentSeason leagueOrTournamentSeason,
      Map<String, LeagueOrTournamentDivison> leagueOrTournamentDivisons})
      : super(
            leagueOrTournamentSeason: leagueOrTournamentSeason,
            leagueOrTournamentDivisons: leagueOrTournamentDivisons);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentSeasonLoaded{}';
  }
}

///
/// Saveing failed, with an specified error.
///
class SingleLeagueOrTournamentSeasonSaveFailed
    extends SingleLeagueOrTournamentSeasonState {
  final Error error;

  SingleLeagueOrTournamentSeasonSaveFailed(
      {@required SingleLeagueOrTournamentSeasonState leagueOrTournament,
      @required this.error})
      : super(
            leagueOrTournamentSeason:
                leagueOrTournament.leagueOrTournamentSeason,
            leagueOrTournamentDivisons:
                leagueOrTournament.leagueOrTournamentDivisons);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonSaveFailed{}';
  }
}

///
/// In the process of saving.
///
class SingleLeagueOrTournamentSeasonSaving
    extends SingleLeagueOrTournamentSeasonState {
  SingleLeagueOrTournamentSeasonSaving(
      {@required SingleLeagueOrTournamentSeasonState leagueOrTournament})
      : super(
            leagueOrTournamentSeason:
                leagueOrTournament.leagueOrTournamentSeason,
            leagueOrTournamentDivisons:
                leagueOrTournament.leagueOrTournamentDivisons);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonSaving{}';
  }
}

///
/// Deleted
///
class SingleLeagueOrTournamentSeasonDeleted
    extends SingleLeagueOrTournamentSeasonState {
  SingleLeagueOrTournamentSeasonDeleted(
      {@required SingleLeagueOrTournamentSeasonState leagueOrTournament})
      : super(
            leagueOrTournamentSeason:
                leagueOrTournament.leagueOrTournamentSeason,
            leagueOrTournamentDivisons: {});
  SingleLeagueOrTournamentSeasonDeleted.empty()
      : super(leagueOrTournamentSeason: null, leagueOrTournamentDivisons: {});
  @override
  String toString() {
    return 'SingleLeagueOrTournamentSeasonSeleted{}';
  }
}

abstract class SingleLeagueOrTournamentSeasonEvent extends Equatable {}

class _SingleLeagueOrTournamentEventLeagueSeasonLoaded
    extends SingleLeagueOrTournamentSeasonEvent {
  final LeagueOrTournamentSeason league;

  _SingleLeagueOrTournamentEventLeagueSeasonLoaded({@required this.league});

  @override
  String toString() {
    return '_SingleLeagueOrTournamentEventLeagueLoaded{}';
  }
}

class _SingleLeagueOrTournamentEventSeasonDeleted
    extends SingleLeagueOrTournamentSeasonEvent {}

class _SingleLeagueOrTournamentEventSeasonDivisons
    extends SingleLeagueOrTournamentSeasonEvent {
  Iterable<LeagueOrTournamentDivison> divisons;

  _SingleLeagueOrTournamentEventSeasonDivisons({this.divisons});
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentSeasonLoadDivisions
    extends SingleLeagueOrTournamentSeasonEvent {}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentSeasonUpdate
    extends SingleLeagueOrTournamentSeasonEvent {
  final LeagueOrTournamentSeason season;
  SingleLeagueOrTournamentSeasonUpdate(this.season);
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentSeasonBloc extends Bloc<
    SingleLeagueOrTournamentSeasonEvent, SingleLeagueOrTournamentSeasonState> {
  final SingleLeagueOrTournamentBloc singleLeagueOrTournamentBloc;
  final String leagueSeasonUid;

  StreamSubscription<SingleLeagueOrTournamentState> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournamentDivison>>
      _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentSeasonBloc(
      {@required this.singleLeagueOrTournamentBloc,
      @required this.leagueSeasonUid}) {
    _coordSub = singleLeagueOrTournamentBloc.state
        .listen((SingleLeagueOrTournamentState state) {
      if (state is SingleLeagueOrTournamentLoaded) {
        if (state.leagueOrTournamentSeasons.containsKey(leagueSeasonUid)) {
          dispatch(_SingleLeagueOrTournamentEventLeagueSeasonLoaded(
              league: state.leagueOrTournamentSeasons[leagueSeasonUid]));
        } else {
          dispatch(_SingleLeagueOrTournamentEventSeasonDeleted());
        }
      }
      if (state is SingleLeagueOrTournamentDeleted) {
        dispatch(_SingleLeagueOrTournamentEventSeasonDeleted());
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
  }

  @override
  SingleLeagueOrTournamentSeasonState get initialState {
    if (singleLeagueOrTournamentBloc.currentState.leagueOrTournamentSeasons
        .containsKey(leagueSeasonUid)) {
      return SingleLeagueOrTournamentSeasonLoaded(
          leagueOrTournamentSeason: singleLeagueOrTournamentBloc
              .currentState.leagueOrTournamentSeasons[leagueSeasonUid],
          leagueOrTournamentDivisons: {});
    } else {
      return SingleLeagueOrTournamentSeasonDeleted.empty();
    }
  }

  void _updateDivisons(Iterable<LeagueOrTournamentDivison> divisons) {
    dispatch(_SingleLeagueOrTournamentEventSeasonDivisons(divisons: divisons));
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentSeasonState> _updateLeagueOrTournamentSeason(
      {LeagueOrTournamentSeason season}) async* {
    if (season.uid == leagueSeasonUid) {
      yield SingleLeagueOrTournamentSeasonSaving(
          leagueOrTournament: currentState);
      try {
        await singleLeagueOrTournamentBloc
            .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .updateLeagueSeason(season);
        yield SingleLeagueOrTournamentSeasonLoaded(
            leagueOrTournamentSeason: currentState.leagueOrTournamentSeason,
            leagueOrTournamentDivisons:
                currentState.leagueOrTournamentDivisons);
      } catch (e) {
        yield SingleLeagueOrTournamentSeasonSaveFailed(
            leagueOrTournament: currentState, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentSeasonSaveFailed(
          leagueOrTournament: currentState,
          error: ArgumentError("season uids don't match"));
    }
  }

  @override
  Stream<SingleLeagueOrTournamentSeasonState> mapEventToState(
      SingleLeagueOrTournamentSeasonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueSeasonLoaded) {
      yield SingleLeagueOrTournamentSeasonLoaded(
          leagueOrTournamentSeason: event.league,
          leagueOrTournamentDivisons: currentState.leagueOrTournamentDivisons);
    }

    if (event is _SingleLeagueOrTournamentEventSeasonDeleted) {
      yield SingleLeagueOrTournamentSeasonDeleted.empty();
    }

    if (event is SingleLeagueOrTournamentSeasonLoadDivisions) {
      _leagueOrTournamentSnapshot = singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .getLeagueDivisonsForSeason(leagueSeasonUid)
          .listen((Iterable<LeagueOrTournamentDivison> divisons) =>
              _updateDivisons(divisons));
    }

    if (event is _SingleLeagueOrTournamentEventSeasonDivisons) {
      Map<String, LeagueOrTournamentDivison> newDivisons = {};
      for (LeagueOrTournamentDivison season in event.divisons) {
        newDivisons[season.uid] = season;
      }
      yield SingleLeagueOrTournamentSeasonLoaded(
          leagueOrTournamentSeason: currentState.leagueOrTournamentSeason,
          leagueOrTournamentDivisons: newDivisons);
    }

    if (event is SingleLeagueOrTournamentSeasonUpdate) {
      yield* _updateLeagueOrTournamentSeason(season: event.season);
    }
  }
}
