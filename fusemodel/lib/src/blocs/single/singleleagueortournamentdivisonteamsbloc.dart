import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentdivisonbloc.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentDivisonTeamsState extends Equatable {
  final Map<String, LeagueOrTournamentTeam> leagueOrTournamentTeams;
  final bool loadedTeams;

  SingleLeagueOrTournamentDivisonTeamsState(
      {@required this.leagueOrTournamentTeams, @required this.loadedTeams});
}

///
/// Doing something.
///
class SingleLeagueOrTournamentDivisonTeamsLoaded
    extends SingleLeagueOrTournamentDivisonTeamsState {
  SingleLeagueOrTournamentDivisonTeamsLoaded(
      SingleLeagueOrTournamentDivisonTeamsState state,
      {Map<String, LeagueOrTournamentTeam> leagueOrTournamentTeams,
      bool loadedTeams})
      : super(
            leagueOrTournamentTeams:
                leagueOrTournamentTeams ?? state.leagueOrTournamentTeams,
            loadedTeams: loadedTeams ?? state.loadedTeams);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonTeamsLoaded{}';
  }
}

///
/// Saveing failed, with an specified error.
///
class SingleLeagueOrTournamentDivisonTeamsSaveFailed
    extends SingleLeagueOrTournamentDivisonTeamsState {
  final Error error;

  SingleLeagueOrTournamentDivisonTeamsSaveFailed(
      {@required SingleLeagueOrTournamentDivisonTeamsState leagueOrTournament,
      @required this.error})
      : super(
            leagueOrTournamentTeams: leagueOrTournament.leagueOrTournamentTeams,
            loadedTeams: leagueOrTournament.loadedTeams);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonTeamsSaveFailed{}';
  }
}

///
/// In the process of saving.
///
class SingleLeagueOrTournamentDivisonTeamsSaving
    extends SingleLeagueOrTournamentDivisonTeamsState {
  SingleLeagueOrTournamentDivisonTeamsSaving(
      {@required SingleLeagueOrTournamentDivisonTeamsState leagueOrTournament})
      : super(
            leagueOrTournamentTeams: leagueOrTournament.leagueOrTournamentTeams,
            loadedTeams: leagueOrTournament.loadedTeams);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonTeamsSaving{}';
  }
}

///
/// Deleted
///
class SingleLeagueOrTournamentDivisonTeamsLoading
    extends SingleLeagueOrTournamentDivisonTeamsState {
  SingleLeagueOrTournamentDivisonTeamsLoading(
      {@required SingleLeagueOrTournamentDivisonTeamsState leagueOrTournament})
      : super(
            leagueOrTournamentTeams: leagueOrTournament.leagueOrTournamentTeams,
            loadedTeams: leagueOrTournament.loadedTeams);
  SingleLeagueOrTournamentDivisonTeamsLoading.empty()
      : super(leagueOrTournamentTeams: {}, loadedTeams: false);
  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonLoading{}';
  }
}

abstract class SingleLeagueOrTournamentDivisonTeamsEvent extends Equatable {}

class _SingleLeagueOrTournamentEventDivisonTeamsLoaded
    extends SingleLeagueOrTournamentDivisonTeamsEvent {
  Iterable<LeagueOrTournamentTeam> teams;

  _SingleLeagueOrTournamentEventDivisonTeamsLoaded({this.teams});
}

//
/// Add a team to this division.
///
class SingleLeagueOrTournamentDivisonTeamsAddTeam
    extends SingleLeagueOrTournamentDivisonTeamsEvent {
  final String teamName;

  SingleLeagueOrTournamentDivisonTeamsAddTeam({@required this.teamName});
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentDivisonTeamsBloc extends Bloc<
    SingleLeagueOrTournamentDivisonTeamsEvent,
    SingleLeagueOrTournamentDivisonTeamsState> {
  final SingleLeagueOrTournamentDivisonBloc singleLeagueOrTournamentDivisonBloc;

  StreamSubscription<Iterable<LeagueOrTournamentTeam>>
      _leagueOrTournamentSnapshot;

  SingleLeagueOrTournamentDivisonTeamsBloc(
      {@required this.singleLeagueOrTournamentDivisonBloc}) {
    _leagueOrTournamentSnapshot = singleLeagueOrTournamentDivisonBloc
        .singleLeagueOrTournamentSeasonBloc
        .singleLeagueOrTournamentBloc
        .leagueOrTournamentBloc
        .coordinationBloc
        .databaseUpdateModel
        .getLeagueDivisionTeams(singleLeagueOrTournamentDivisonBloc
            .currentState.leagueOrTournamentDivison.uid)
        .listen((Iterable<LeagueOrTournamentTeam> divisons) =>
            _updateTeams(divisons));
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
  SingleLeagueOrTournamentDivisonTeamsState get initialState {
    return SingleLeagueOrTournamentDivisonTeamsLoading.empty();
  }

  void _updateTeams(Iterable<LeagueOrTournamentTeam> teams) {
    dispatch(_SingleLeagueOrTournamentEventDivisonTeamsLoaded(teams: teams));
  }

  Stream<SingleLeagueOrTournamentDivisonTeamsState> _addTeam(
      {String teamName}) async* {
    yield SingleLeagueOrTournamentDivisonTeamsSaving(
        leagueOrTournament: currentState);
    try {
      LeagueOrTournamentTeam teamData = new LeagueOrTournamentTeam((b) => b
        ..leagueOrTournamentDivisonUid = singleLeagueOrTournamentDivisonBloc
            .currentState.leagueOrTournamentDivison.uid
        ..name = teamName);
      await singleLeagueOrTournamentDivisonBloc
          .singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .updateLeagueTeam(teamData);
      yield SingleLeagueOrTournamentDivisonTeamsLoaded(currentState);
    } catch (e) {
      yield SingleLeagueOrTournamentDivisonTeamsSaveFailed(
          leagueOrTournament: currentState, error: e);
    }
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonTeamsState> mapEventToState(
      SingleLeagueOrTournamentDivisonTeamsEvent event) async* {
    if (event is SingleLeagueOrTournamentDivisonLoadTeams) {
      if (!currentState.loadedTeams) {}
    }

    if (event is _SingleLeagueOrTournamentEventDivisonTeamsLoaded) {
      Map<String, LeagueOrTournamentTeam> newTeams = {};
      for (LeagueOrTournamentTeam team in event.teams) {
        newTeams[team.uid] = team;
      }
      yield SingleLeagueOrTournamentDivisonTeamsLoaded(currentState,
          leagueOrTournamentTeams: newTeams, loadedTeams: true);
    }

    if (event is SingleLeagueOrTournamentDivisonTeamsAddTeam) {
      yield* _addTeam(teamName: event.teamName);
    }
  }
}
