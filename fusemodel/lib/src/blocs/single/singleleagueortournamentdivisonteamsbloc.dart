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
abstract class SingleLeagueOrTournamentDivisonTeamsState extends Equatable {
  final BuiltMap<String, LeagueOrTournamentTeam> leagueOrTournamentTeams;
  final bool loadedTeams;

  SingleLeagueOrTournamentDivisonTeamsState(
      {@required this.leagueOrTournamentTeams, @required this.loadedTeams});

  @override
  List<Object> get props => [leagueOrTournamentTeams, loadedTeams];
}

///
/// Loaded.
///
class SingleLeagueOrTournamentDivisonTeamsLoaded
    extends SingleLeagueOrTournamentDivisonTeamsState {
  SingleLeagueOrTournamentDivisonTeamsLoaded(
      SingleLeagueOrTournamentDivisonTeamsState state,
      {BuiltMap<String, LeagueOrTournamentTeam> leagueOrTournamentTeams,
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
/// Loading...
///
class SingleLeagueOrTournamentDivisonTeamsLoading
    extends SingleLeagueOrTournamentDivisonTeamsState {
  SingleLeagueOrTournamentDivisonTeamsLoading(
      {@required SingleLeagueOrTournamentDivisonTeamsState leagueOrTournament})
      : super(
            leagueOrTournamentTeams: leagueOrTournament.leagueOrTournamentTeams,
            loadedTeams: leagueOrTournament.loadedTeams);
  SingleLeagueOrTournamentDivisonTeamsLoading.empty()
      : super(leagueOrTournamentTeams: BuiltMap(), loadedTeams: false);
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
  @override
  List<Object> get props => [teams];
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
        .getLeagueDivisionTeams(
            singleLeagueOrTournamentDivisonBloc.leagueDivisonUid)
        .listen((Iterable<LeagueOrTournamentTeam> divisons) =>
            _updateTeams(divisons));
  }

  @override
  Future<void> close() async {
    await super.close();
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
    add(_SingleLeagueOrTournamentEventDivisonTeamsLoaded(teams: teams));
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonTeamsState> mapEventToState(
      SingleLeagueOrTournamentDivisonTeamsEvent event) async* {
    if (event is SingleLeagueOrTournamentDivisonLoadTeams) {
      if (!state.loadedTeams) {}
    }

    if (event is _SingleLeagueOrTournamentEventDivisonTeamsLoaded) {
      Map<String, LeagueOrTournamentTeam> newTeams = {};
      for (LeagueOrTournamentTeam team in event.teams) {
        newTeams[team.uid] = team;
      }
      yield SingleLeagueOrTournamentDivisonTeamsLoaded(state,
          leagueOrTournamentTeams: BuiltMap.from(newTeams), loadedTeams: true);
    }
  }
}
