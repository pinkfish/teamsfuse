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
      {@required this.leagueOrTournamentDivison});

  @override
  List<Object> get props => [leagueOrTournamentDivison];
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

  @override
  List<Object> get props => [leagueDivision];
}

class _SingleLeagueOrTournamentEventDivisonDeleted
    extends SingleLeagueOrTournamentDivisonEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the Teams for this league or tournament.
///
class SingleLeagueOrTournamentDivisonLoadTeams
    extends SingleLeagueOrTournamentDivisonEvent {
  @override
  List<Object> get props => [];
}

///
/// Add a team to this division.
///
class SingleLeagueOrTournamentDivisonUpdate
    extends SingleLeagueOrTournamentDivisonEvent {
  final LeagueOrTournamentDivison leagueOrTournamentDivison;

  SingleLeagueOrTournamentDivisonUpdate(
      {@required this.leagueOrTournamentDivison});
  @override
  List<Object> get props => [leagueOrTournamentDivison];
}

//
/// Writes the updated data out to the database.
///
class SingleLeagueOrTournamentDivisonAddTeam
    extends SingleLeagueOrTournamentDivisonEvent {
  final String teamName;

  SingleLeagueOrTournamentDivisonAddTeam({@required this.teamName});
  @override
  List<Object> get props => [teamName];
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
      this.singleLeagueOrTournamentSeasonBloc})
      : super(singleLeagueOrTournamentSeasonBloc
                .state.leagueOrTournamentDivisons
                .containsKey(leagueDivisonUid)
            ? SingleLeagueOrTournamentDivisonLoaded(null,
                leagueOrTournamentDivison: singleLeagueOrTournamentSeasonBloc
                    .state.leagueOrTournamentDivisons[leagueDivisonUid])
            : SingleLeagueOrTournamentDivisonDeleted.empty()) {
    assert(this.coordinationBloc != null ||
        this.singleLeagueOrTournamentSeasonBloc != null);
    if (coordinationBloc != null) {
      _divSub = coordinationBloc.databaseUpdateModel
          .getLeagueDivisionData(
              leagueDivisionUid: leagueDivisonUid,
              memberUid: coordinationBloc.authenticationBloc.currentUser.uid)
          .listen((LeagueOrTournamentDivison div) {
        if (div == null) {
          add(_SingleLeagueOrTournamentEventDivisonDeleted());
        } else {
          add(_SingleLeagueOrTournamentEventLeagueDivisonLoaded(
              leagueDivision: div));
        }
      });
    } else {
      _coordSub = singleLeagueOrTournamentSeasonBloc
          .listen((SingleLeagueOrTournamentSeasonState state) {
        if (state is SingleLeagueOrTournamentSeasonLoaded) {
          if (state.leagueOrTournamentDivisons.containsKey(leagueDivisonUid)) {
          } else {}
        }
        if (state is SingleLeagueOrTournamentSeasonDeleted) {
          add(_SingleLeagueOrTournamentEventDivisonDeleted());
        }
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _coordSub?.cancel();
    _divSub?.cancel();
    _coordSub = null;
    _divSub = null;
  }

  void _cleanupStuff() {}

  @override
  SingleLeagueOrTournamentDivisonState get initialState {
    if (singleLeagueOrTournamentSeasonBloc.state.leagueOrTournamentDivisons
        .containsKey(leagueDivisonUid)) {
      return SingleLeagueOrTournamentDivisonLoaded(null,
          leagueOrTournamentDivison: singleLeagueOrTournamentSeasonBloc
              .state.leagueOrTournamentDivisons[leagueDivisonUid]);
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
      yield SingleLeagueOrTournamentDivisonSaving(leagueOrTournament: state);
      try {
        await singleLeagueOrTournamentSeasonBloc.singleLeagueOrTournamentBloc
            .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
            .updateLeagueDivison(divison);
        yield SingleLeagueOrTournamentDivisonLoaded(state,
            leagueOrTournamentDivison: state.leagueOrTournamentDivison);
      } catch (e) {
        yield SingleLeagueOrTournamentDivisonSaveFailed(
            leagueOrTournament: state, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentDivisonSaveFailed(
          leagueOrTournament: state,
          error: ArgumentError("league uids don't match"));
    }
  }

  Stream<SingleLeagueOrTournamentDivisonState> _addTeam(
      {String teamName}) async* {
    yield SingleLeagueOrTournamentDivisonSaving(leagueOrTournament: state);
    try {
      LeagueOrTournamentTeam teamData = new LeagueOrTournamentTeam((b) => b
        ..leagueOrTournamentDivisonUid = state.leagueOrTournamentDivison.uid
        ..name = teamName);
      await singleLeagueOrTournamentSeasonBloc.singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc.coordinationBloc.databaseUpdateModel
          .updateLeagueTeam(teamData);
      yield SingleLeagueOrTournamentDivisonLoaded(state,
          leagueOrTournamentDivison: state.leagueOrTournamentDivison);
    } catch (e) {
      yield SingleLeagueOrTournamentDivisonSaveFailed(
          leagueOrTournament: state, error: e);
    }
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonState> mapEventToState(
      SingleLeagueOrTournamentDivisonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueDivisonLoaded) {
      yield SingleLeagueOrTournamentDivisonLoaded(state,
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
