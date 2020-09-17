import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import 'data/singleleagueortournamentseasonbloc.dart';

abstract class SingleLeagueOrTournamentSeasonEvent extends Equatable {}

class _SingleLeagueOrTournamentEventLeagueSeasonLoaded
    extends SingleLeagueOrTournamentSeasonEvent {
  final LeagueOrTournamentSeason season;

  _SingleLeagueOrTournamentEventLeagueSeasonLoaded({@required this.season});

  @override
  String toString() {
    return '_SingleLeagueOrTournamentEventLeagueLoaded{}';
  }

  @override
  List<Object> get props => [season];
}

class _SingleLeagueOrTournamentEventSeasonDeleted
    extends SingleLeagueOrTournamentSeasonEvent {
  @override
  List<Object> get props => [];
}

class _SingleLeagueOrTournamentEventSeasonDivisons
    extends SingleLeagueOrTournamentSeasonEvent {
  final Iterable<LeagueOrTournamentDivison> divisons;

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
class SingleLeagueOrTournamentSeasonBloc extends AsyncHydratedBloc<
    SingleLeagueOrTournamentSeasonEvent, SingleLeagueOrTournamentSeasonState> {
  final DatabaseUpdateModel db;
  final String leagueSeasonUid;

  StreamSubscription<LeagueOrTournamentSeason> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournamentDivison>>
      _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentSeasonBloc(
      {@required this.db, @required this.leagueSeasonUid})
      : super(SingleLeagueOrTournamentSeasonUninitialized(), leagueSeasonUid) {
    _coordSub = db.getLeagueSeasonData(leagueSeasonUid).listen((season) {
      if (season != null) {
        add(_SingleLeagueOrTournamentEventLeagueSeasonLoaded(season: season));
      } else {
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

  void _updateDivisons(Iterable<LeagueOrTournamentDivison> divisons) {
    add(_SingleLeagueOrTournamentEventSeasonDivisons(divisons: divisons));
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentSeasonState> _updateLeagueOrTournamentSeason(
      {LeagueOrTournamentSeason season}) async* {
    if (season.uid == leagueSeasonUid) {
      yield SingleLeagueOrTournamentSeasonSaving.fromState(state).build();
      try {
        await db.updateLeagueSeason(season);
        yield SingleLeagueOrTournamentSeasonLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleLeagueOrTournamentSeasonSaveFailed.fromState(state)
              ..error = e)
            .build();
      }
    } else {
      yield (SingleLeagueOrTournamentSeasonSaveFailed.fromState(state)
            ..error = ArgumentError("season uids don't match"))
          .build();
    }
  }

  @override
  Stream<SingleLeagueOrTournamentSeasonState> mapEventToState(
      SingleLeagueOrTournamentSeasonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueSeasonLoaded) {
      yield (SingleLeagueOrTournamentSeasonLoaded.fromState(state)
            ..season = event.season.toBuilder())
          .build();
    }

    if (event is _SingleLeagueOrTournamentEventSeasonDeleted) {
      yield SingleLeagueOrTournamentSeasonDeleted();
    }

    if (event is SingleLeagueOrTournamentSeasonLoadDivisions) {
      if (!state.loadedDivisons) {
        _leagueOrTournamentSnapshot = db
            .getLeagueDivisonsForSeason(
                leagueSeasonUid: leagueSeasonUid, memberUid: db.currentUser.uid)
            .listen((Iterable<LeagueOrTournamentDivison> divisons) =>
                _updateDivisons(divisons));
      }
    }

    if (event is _SingleLeagueOrTournamentEventSeasonDivisons) {
      var newDivisons = MapBuilder<String, LeagueOrTournamentDivison>();
      for (LeagueOrTournamentDivison season in event.divisons) {
        newDivisons[season.uid] = season;
      }
      yield (SingleLeagueOrTournamentSeasonLoaded.fromState(state)
            ..divisons = newDivisons
            ..loadedDivisons = true)
          .build();
    }

    if (event is SingleLeagueOrTournamentSeasonUpdate) {
      yield* _updateLeagueOrTournamentSeason(season: event.season);
    }

    if (event is _SingleLeagueOrTournamentEventSeasonSaveFailed) {
      yield (SingleLeagueOrTournamentSeasonSaveFailed.fromState(state)
            ..error = event.error)
          .build();
    }

    if (event is SingleLeagueOrTournamentSeasonAddDivision) {
      LeagueOrTournamentDivison divison = LeagueOrTournamentDivison((b) => b
        ..name = event.name
        ..leagueOrTournmentSeasonUid = leagueSeasonUid);
      db.updateLeagueDivison(divison).then((void a) => null,
          onError: (Error error) => add(
              _SingleLeagueOrTournamentEventSeasonSaveFailed(error: error)));
    }
  }

  @override
  SingleLeagueOrTournamentSeasonState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleLeagueOrTournamentSeasonUninitialized();
    }

    SingleLeagueOrTournamentSeasonBlocStateType type =
        SingleLeagueOrTournamentSeasonBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleLeagueOrTournamentSeasonBlocStateType.Uninitialized:
        return SingleLeagueOrTournamentSeasonUninitialized();
      case SingleLeagueOrTournamentSeasonBlocStateType.Loaded:
        var ret = SingleLeagueOrTournamentSeasonLoaded.fromMap(json);
        return ret;
      case SingleLeagueOrTournamentSeasonBlocStateType.Deleted:
        return SingleLeagueOrTournamentSeasonDeleted.fromMap(json);
      case SingleLeagueOrTournamentSeasonBlocStateType.SaveFailed:
        return SingleLeagueOrTournamentSeasonSaveFailed.fromMap(json);
      case SingleLeagueOrTournamentSeasonBlocStateType.Saving:
        return SingleLeagueOrTournamentSeasonSaving.fromMap(json);
      case SingleLeagueOrTournamentSeasonBlocStateType.SaveDone:
        return SingleLeagueOrTournamentSeasonSaveDone.fromMap(json);
    }
    return SingleLeagueOrTournamentSeasonUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleLeagueOrTournamentSeasonState state) {
    return state.toMap();
  }
}
