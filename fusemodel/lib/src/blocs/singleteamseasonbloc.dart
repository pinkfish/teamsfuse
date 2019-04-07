import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'teambloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';

///
/// The basic state for all the bits of the single team bloc.
///
abstract class SingleTeamSeaonState extends Equatable {
  final String teamUid;
  final String seasonUid;
  final Season season;

  SingleTeamSeaonState(
      {@required this.teamUid,
      @required this.season,
      @required this.seasonUid});
}

///
/// Nothing happened for this team yet.
///
class SingleTeamSeasonUninitalized extends SingleTeamSeaonState {
  SingleTeamSeasonUninitalized(
      {@required String teamUid, @required String seasonUid})
      : super(teamUid: teamUid, seasonUid: seasonUid, season: null);
}

///
/// We have a team, default state.
///
class SingleTeamSeasonLoaded extends SingleTeamSeaonState {
  SingleTeamSeasonLoaded(
      {@required String teamUid,
      @required Season season,
      @required String seasonUid})
      : super(teamUid: teamUid, season: season, seasonUid: seasonUid);

  @override
  String toString() {
    return 'SingleTeamSeasonLoaded{teamUid: $teamUid, opponentUid: $seasonUid}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSeasonSaving extends SingleTeamSeaonState {
  SingleTeamSeasonSaving(
      {@required String teamUid,
      @required Season season,
      @required String seasonUid})
      : super(teamUid: teamUid, season: season, seasonUid: seasonUid);

  @override
  String toString() {
    return 'SingleTeamSeasonSaving{teamUid: $teamUid, opponentUid: $seasonUid}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSeasonSaveFailed extends SingleTeamSeaonState {
  final Error error;

  SingleTeamSeasonSaveFailed(
      {@required String teamUid,
      @required Season season,
      @required String seasonUid,
      this.error})
      : super(teamUid: teamUid, season: season, seasonUid: seasonUid);

  @override
  String toString() {
    return 'SingleTeamSeasonSaveFailed{teamUid: $teamUid, opponentUid: $seasonUid}';
  }
}

///
/// Team got deleted.
///
class SingleTeamSeasonDeleted extends SingleTeamSeaonState {
  SingleTeamSeasonDeleted(
      {@required String teamUid,
      @required Season season,
      @required String seasonUid})
      : super(teamUid: teamUid, season: season, seasonUid: seasonUid);

  @override
  String toString() {
    return 'SingleTeamSeasonDeleted{teamUid: $teamUid, opponentUid: $seasonUid}';
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

///
/// Delete this team from the world.
///
class SingleTeamSeasonDelete extends SingleTeamSeasonEvent {
  SingleTeamSeasonDelete();
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
  SingleTeamSeaonState get initialState =>
      SingleTeamSeasonUninitalized(teamUid: teamUid);

  @override
  Stream<SingleTeamSeaonState> mapEventToState(
      SingleTeamSeasonEvent event) async* {
    if (event is _SingleTeamNewTeamSeason) {
      yield SingleTeamSeasonLoaded(
          teamUid: teamUid, season: event.newSeason, seasonUid: seasonUid);
    }

    // The team is deleted.
    if (event is _SingleTeamSeasonDeleted) {
      yield SingleTeamSeasonDeleted(
          teamUid: teamUid, season: currentState.season, seasonUid: seasonUid);
    }

    // Save the team.
    if (event is SingleTeamSeasonUpdate) {
      yield SingleTeamSeasonSaving(
          teamUid: currentState.teamUid,
          season: currentState.season,
          seasonUid: seasonUid);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSeason(event.season.build(), false);
        yield SingleTeamSeasonLoaded(
            teamUid: teamUid,
            season: event.season.build(),
            seasonUid: seasonUid);
      } catch (e) {
        yield SingleTeamSeasonSaveFailed(
            teamUid: currentState.teamUid,
            season: currentState.season,
            seasonUid: currentState.seasonUid,
            error: e);
      }
    }
  }
}
