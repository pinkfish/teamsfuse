import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentseasonbloc.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentDivisonState extends Equatable {
  final LeagueOrTournamentDivison leagueOrTournamentDivison;

  SingleLeagueOrTournamentDivisonState(
      {@required this.leagueOrTournamentDivison})
      : super([leagueOrTournamentDivison]);
}

///
/// Doing something.
///
class SingleLeagueOrTournamentDivisonLoaded
    extends SingleLeagueOrTournamentDivisonState {
  SingleLeagueOrTournamentDivisonLoaded(
      SingleLeagueOrTournamentDivisonState state,
      {LeagueOrTournamentDivison leagueOrTournamentDivison})
      : super(
            leagueOrTournamentDivison:
                leagueOrTournamentDivison ?? state.leagueOrTournamentDivison);

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
                leagueOrTournament.leagueOrTournamentDivison);

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
                leagueOrTournament.leagueOrTournamentDivison);

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
                leagueOrTournament.leagueOrTournamentDivison);
  SingleLeagueOrTournamentDivisonDeleted.empty()
      : super(leagueOrTournamentDivison: null);
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

///
/// Loads the Teams for this league or tournament.
///
class SingleLeagueOrTournamentDivisonLoadTeams
    extends SingleLeagueOrTournamentDivisonEvent {}

///
/// Add a team to this division.
///
class SingleLeagueOrTournamentDivisonUpdate
    extends SingleLeagueOrTournamentDivisonEvent {
  final LeagueOrTournamentDivison leagueOrTournamentDivison;

  SingleLeagueOrTournamentDivisonUpdate(
      {@required this.leagueOrTournamentDivison});
}

//
/// Writes the updated data out to the database.
///
class SingleLeagueOrTournamentDivisonAddTeam
    extends SingleLeagueOrTournamentDivisonEvent {
  final String teamName;

  SingleLeagueOrTournamentDivisonAddTeam({@required this.teamName});
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentDivisonBloc extends Bloc<
    SingleLeagueOrTournamentDivisonEvent,
    SingleLeagueOrTournamentDivisonState> {
  final CoordinationBloc coordinationBloc;
  final SingleLeagueOrTournamentSeasonBloc singleLeagueOrTournamentSeasonBloc;
  final String leagueDivisonUid;

  StreamSubscription<SingleLeagueOrTournamentSeasonState> _coordSub;
  StreamSubscription<LeagueOrTournamentDivison> _divSub;

  SingleLeagueOrTournamentDivisonBloc(
      {this.coordinationBloc,
      @required this.leagueDivisonUid,
      this.singleLeagueOrTournamentSeasonBloc}) {
    assert(this.coordinationBloc != null ||
        this.singleLeagueOrTournamentSeasonBloc != null);
    if (coordinationBloc != null) {
      _divSub = coordinationBloc.databaseUpdateModel
          .getLeagueDivisionData(
              leagueDivisionUid: leagueDivisonUid,
              memberUid: coordinationBloc.authenticationBloc.currentUser.uid)
          .listen((LeagueOrTournamentDivison div) {
        if (div == null) {
          dispatch(_SingleLeagueOrTournamentEventDivisonDeleted());
        } else {
          dispatch(_SingleLeagueOrTournamentEventLeagueDivisonLoaded(
              leagueDivision: div));
        }
      });
    } else {
      _coordSub = singleLeagueOrTournamentSeasonBloc.state
          .listen((SingleLeagueOrTournamentSeasonState state) {
        if (state is SingleLeagueOrTournamentSeasonLoaded) {
          if (state.leagueOrTournamentDivisons.containsKey(leagueDivisonUid)) {
          } else {}
        }
        if (state is SingleLeagueOrTournamentSeasonDeleted) {
          dispatch(_SingleLeagueOrTournamentEventDivisonDeleted());
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _coordSub?.cancel();
    _divSub?.cancel();
    _coordSub = null;
    _divSub = null;
  }

  void _cleanupStuff() {}

  @override
  SingleLeagueOrTournamentDivisonState get initialState {
    if (singleLeagueOrTournamentSeasonBloc
        .currentState.leagueOrTournamentDivisons
        .containsKey(leagueDivisonUid)) {
      return SingleLeagueOrTournamentDivisonLoaded(null,
          leagueOrTournamentDivison: singleLeagueOrTournamentSeasonBloc
              .currentState.leagueOrTournamentDivisons[leagueDivisonUid]);
    } else {
      return SingleLeagueOrTournamentDivisonDeleted.empty();
    }
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
        yield SingleLeagueOrTournamentDivisonLoaded(currentState,
            leagueOrTournamentDivison: currentState.leagueOrTournamentDivison);
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

  Stream<SingleLeagueOrTournamentDivisonState> _addTeam(
      {String teamName}) async* {
    yield SingleLeagueOrTournamentDivisonSaving(
        leagueOrTournament: currentState);
    try {
      LeagueOrTournamentTeam teamData = new LeagueOrTournamentTeam((b) => b
        ..leagueOrTournamentDivisonUid =
            currentState.leagueOrTournamentDivison.uid
        ..name = teamName);
      await singleLeagueOrTournamentSeasonBloc.singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .updateLeagueTeam(teamData);
      yield SingleLeagueOrTournamentDivisonLoaded(currentState,
          leagueOrTournamentDivison: currentState.leagueOrTournamentDivison);
    } catch (e) {
      yield SingleLeagueOrTournamentDivisonSaveFailed(
          leagueOrTournament: currentState, error: e);
    }
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonState> mapEventToState(
      SingleLeagueOrTournamentDivisonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueDivisonLoaded) {
      yield SingleLeagueOrTournamentDivisonLoaded(currentState,
          leagueOrTournamentDivison: event.leagueDivision);
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

    if (event is SingleLeagueOrTournamentDivisonAddTeam) {
      yield* _addTeam(teamName: event.teamName);
    }
  }
}
