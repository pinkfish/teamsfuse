import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'teambloc.dart';

///
/// The basic state for all the bits of the single team bloc.
///
abstract class SingleTeamSeaonState extends Equatable {
  final Season season;

  SingleTeamSeaonState({@required this.season});
}

///
/// We have a team, default state.
///
class SingleTeamSeasonLoaded extends SingleTeamSeaonState {
  SingleTeamSeasonLoaded({@required Season season}) : super(season: season);

  @override
  String toString() {
    return 'SingleTeamSeasonLoaded{season: $season}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSeasonSaving extends SingleTeamSeaonState {
  SingleTeamSeasonSaving({@required SingleTeamSeaonState state})
      : super(season: state.season);

  @override
  String toString() {
    return 'SingleTeamSeasonSaving{season: $season}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSeasonSaveFailed extends SingleTeamSeaonState {
  final Error error;

  SingleTeamSeasonSaveFailed({@required SingleTeamSeaonState state, this.error})
      : super(season: state.season);

  @override
  String toString() {
    return 'SingleTeamSeasonSaveFailed{season: $season}';
  }
}

///
/// Team got deleted.
///
class SingleTeamSeasonDeleted extends SingleTeamSeaonState {
  SingleTeamSeasonDeleted() : super(season: null);

  @override
  String toString() {
    return 'SingleTeamSeasonDeleted{season: $season}';
  }
}

abstract class SingleTeamSeasonEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamSeasonUpdate extends SingleTeamSeasonEvent {
  final SeasonBuilder season;

  SingleTeamSeasonUpdate({@required this.season});
}

class _SingleTeamNewTeamSeason extends SingleTeamSeasonEvent {
  final Season newSeason;

  _SingleTeamNewTeamSeason({@required this.newSeason});
}

class _SingleTeamSeasonDeleted extends SingleTeamSeasonEvent {
  _SingleTeamSeasonDeleted();
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamSeasonBloc
    extends Bloc<SingleTeamSeasonEvent, SingleTeamSeaonState> {
  final TeamBloc teamBloc;
  final String teamUid;
  final String seasonUid;

  StreamSubscription<TeamState> _teamSub;

  SingleTeamSeasonBloc({this.teamBloc, this.teamUid, this.seasonUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null && team.seasons.containsKey(seasonUid)) {
        Season season = team.seasons[seasonUid];

        // Only send this if the team is not the same.
        if (season != currentState.season) {
          dispatch(_SingleTeamNewTeamSeason(newSeason: season));
        }
      } else {
        dispatch(_SingleTeamSeasonDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _teamSub?.cancel();
    _teamSub = null;
  }

  @override
  SingleTeamSeaonState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null && t.seasons.containsKey(seasonUid)) {
      return SingleTeamSeasonLoaded(season: t.seasons[seasonUid]);
    } else {
      return SingleTeamSeasonDeleted();
    }
  }

  @override
  Stream<SingleTeamSeaonState> mapEventToState(
      SingleTeamSeasonEvent event) async* {
    if (event is _SingleTeamNewTeamSeason) {
      yield SingleTeamSeasonLoaded(season: event.newSeason);
    }

    // The team is deleted.
    if (event is _SingleTeamSeasonDeleted) {
      yield SingleTeamSeasonDeleted();
    }

    // Save the team.
    if (event is SingleTeamSeasonUpdate) {
      yield SingleTeamSeasonSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSeason(event.season.build(), false);
        yield SingleTeamSeasonLoaded(season: event.season.build());
      } catch (e) {
        yield SingleTeamSeasonSaveFailed(state: currentState, error: e);
      }
    }
  }
}
