import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentbloc.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentSeasonState extends Equatable {
  final LeagueOrTournamentSeason leagueOrTournamentSeason;
  final BuiltMap<String, LeagueOrTournamentDivison> leagueOrTournamentDivisons;
  final bool loadedDivisons;

  SingleLeagueOrTournamentSeasonState(
      {@required this.leagueOrTournamentSeason,
      @required this.leagueOrTournamentDivisons,
      @required this.loadedDivisons});

  @override
  List<Object> get props =>
      [leagueOrTournamentDivisons, leagueOrTournamentSeason, loadedDivisons];
}

///
/// Doing something.
///
class SingleLeagueOrTournamentSeasonLoaded
    extends SingleLeagueOrTournamentSeasonState {
  SingleLeagueOrTournamentSeasonLoaded(
      {@required LeagueOrTournamentSeason leagueOrTournamentSeason,
      BuiltMap<String, LeagueOrTournamentDivison> leagueOrTournamentDivisons,
      bool loadedDivisons})
      : super(
            leagueOrTournamentSeason: leagueOrTournamentSeason,
            leagueOrTournamentDivisons: leagueOrTournamentDivisons,
            loadedDivisons: loadedDivisons);

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
                leagueOrTournament.leagueOrTournamentDivisons,
            loadedDivisons: leagueOrTournament.loadedDivisons);

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
                leagueOrTournament.leagueOrTournamentDivisons,
            loadedDivisons: leagueOrTournament.loadedDivisons);

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
            leagueOrTournamentDivisons: BuiltMap(),
            loadedDivisons: false);
  SingleLeagueOrTournamentSeasonDeleted.empty()
      : super(
            leagueOrTournamentSeason: null,
            leagueOrTournamentDivisons: BuiltMap(),
            loadedDivisons: false);
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

  @override
  List<Object> get props => [league];
}

class _SingleLeagueOrTournamentEventSeasonDeleted
    extends SingleLeagueOrTournamentSeasonEvent {
  @override
  List<Object> get props => [];
}

class _SingleLeagueOrTournamentEventSeasonDivisons
    extends SingleLeagueOrTournamentSeasonEvent {
  Iterable<LeagueOrTournamentDivison> divisons;

  _SingleLeagueOrTournamentEventSeasonDivisons({this.divisons});
  @override
  List<Object> get props => [divisons];
}

class _SingleLeagueOrTournamentEventSeasonSaveFailed
    extends SingleLeagueOrTournamentSeasonEvent {
  final Error error;
  _SingleLeagueOrTournamentEventSeasonSaveFailed({this.error});

  @override
  List<Object> get props => [error];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentSeasonLoadDivisions
    extends SingleLeagueOrTournamentSeasonEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentSeasonUpdate
    extends SingleLeagueOrTournamentSeasonEvent {
  final LeagueOrTournamentSeason season;

  SingleLeagueOrTournamentSeasonUpdate({this.season});

  @override
  List<Object> get props => [season];
}

///
/// Loads the seasons for this league or tournament.
///
class SingleLeagueOrTournamentSeasonAddDivision
    extends SingleLeagueOrTournamentSeasonEvent {
  final String name;
  SingleLeagueOrTournamentSeasonAddDivision({this.name});

  @override
  List<Object> get props => [name];
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
    _coordSub = singleLeagueOrTournamentBloc
        .listen((SingleLeagueOrTournamentState state) {
      if (state is SingleLeagueOrTournamentLoaded) {
        if (state.leagueOrTournamentSeasons.containsKey(leagueSeasonUid)) {
          add(_SingleLeagueOrTournamentEventLeagueSeasonLoaded(
              league: state.leagueOrTournamentSeasons[leagueSeasonUid]));
        } else {
          add(_SingleLeagueOrTournamentEventSeasonDeleted());
        }
      }
      if (state is SingleLeagueOrTournamentDeleted) {
        add(_SingleLeagueOrTournamentEventSeasonDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
  }

  @override
  SingleLeagueOrTournamentSeasonState get initialState {
    if (singleLeagueOrTournamentBloc.state.leagueOrTournamentSeasons
        .containsKey(leagueSeasonUid)) {
      return SingleLeagueOrTournamentSeasonLoaded(
          leagueOrTournamentSeason: singleLeagueOrTournamentBloc
              .state.leagueOrTournamentSeasons[leagueSeasonUid],
          leagueOrTournamentDivisons: BuiltMap(),
          loadedDivisons: false);
    } else {
      return SingleLeagueOrTournamentSeasonDeleted.empty();
    }
  }

  void _updateDivisons(Iterable<LeagueOrTournamentDivison> divisons) {
    add(_SingleLeagueOrTournamentEventSeasonDivisons(divisons: divisons));
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentSeasonState> _updateLeagueOrTournamentSeason(
      {LeagueOrTournamentSeason season}) async* {
    if (season.uid == leagueSeasonUid) {
      yield SingleLeagueOrTournamentSeasonSaving(leagueOrTournament: state);
      try {
        await singleLeagueOrTournamentBloc
            .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .updateLeagueSeason(season);
        yield SingleLeagueOrTournamentSeasonLoaded(
            leagueOrTournamentSeason: state.leagueOrTournamentSeason,
            leagueOrTournamentDivisons: state.leagueOrTournamentDivisons,
            loadedDivisons: state.loadedDivisons);
      } catch (e) {
        yield SingleLeagueOrTournamentSeasonSaveFailed(
            leagueOrTournament: state, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentSeasonSaveFailed(
          leagueOrTournament: state,
          error: ArgumentError("season uids don't match"));
    }
  }

  @override
  Stream<SingleLeagueOrTournamentSeasonState> mapEventToState(
      SingleLeagueOrTournamentSeasonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueSeasonLoaded) {
      yield SingleLeagueOrTournamentSeasonLoaded(
          leagueOrTournamentSeason: event.league,
          leagueOrTournamentDivisons: state.leagueOrTournamentDivisons,
          loadedDivisons: state.loadedDivisons);
    }

    if (event is _SingleLeagueOrTournamentEventSeasonDeleted) {
      yield SingleLeagueOrTournamentSeasonDeleted.empty();
    }

    if (event is SingleLeagueOrTournamentSeasonLoadDivisions) {
      if (!state.loadedDivisons) {
        _leagueOrTournamentSnapshot = singleLeagueOrTournamentBloc
            .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .getLeagueDivisonsForSeason(
                leagueSeasonUid: leagueSeasonUid,
                memberUid: singleLeagueOrTournamentBloc.leagueOrTournamentBloc
                    .coordinationBloc.authenticationBloc.currentUser.uid)
            .listen((Iterable<LeagueOrTournamentDivison> divisons) =>
                _updateDivisons(divisons));
      }
    }

    if (event is _SingleLeagueOrTournamentEventSeasonDivisons) {
      Map<String, LeagueOrTournamentDivison> newDivisons = {};
      for (LeagueOrTournamentDivison season in event.divisons) {
        newDivisons[season.uid] = season;
      }
      yield SingleLeagueOrTournamentSeasonLoaded(
          leagueOrTournamentSeason: state.leagueOrTournamentSeason,
          leagueOrTournamentDivisons: BuiltMap.from(newDivisons),
          loadedDivisons: true);
    }

    if (event is SingleLeagueOrTournamentSeasonUpdate) {
      yield* _updateLeagueOrTournamentSeason(season: event.season);
    }

    if (event is _SingleLeagueOrTournamentEventSeasonSaveFailed) {
      yield SingleLeagueOrTournamentSeasonSaveFailed(
          leagueOrTournament: state, error: event.error);
    }

    if (event is SingleLeagueOrTournamentSeasonAddDivision) {
      LeagueOrTournamentDivison divison = LeagueOrTournamentDivison((b) => b
        ..name = event.name
        ..leagueOrTournmentSeasonUid = leagueSeasonUid);
      singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .updateLeagueDivison(divison)
          .then((void a) => null,
              onError: (Error error) => add(
                  _SingleLeagueOrTournamentEventSeasonSaveFailed(
                      error: error)));
    }
  }
}
