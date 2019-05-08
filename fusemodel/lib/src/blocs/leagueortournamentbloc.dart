import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

///
/// Basic state for all the data in this system.
///
class LeagueOrTournamentState extends Equatable {
  final Map<String, LeagueOrTournament> leagueOrTournaments;
  final bool onlySql;

  LeagueOrTournamentState(
      {@required this.leagueOrTournaments, @required this.onlySql});

  LeagueOrTournamentLoaded rebuild(
      {Map<String, LeagueOrTournament> leagueOrTournamentsParam,
      @required bool onlySqlParam,
      Map<String, Iterable<LeagueOrTournamentSeason>>
          leagueOrTournamentSeasonsParam,
      Map<String, Iterable<LeagueOrTournamentDivison>>
          leagueOrTournamentDivisionsParam,
      Map<String, Iterable<LeagueOrTournamentTeam>>
          leagueOrTournamentTeamsParam}) {
    return LeagueOrTournamentLoaded(
        onlySql: onlySqlParam ?? onlySql,
        leagueOrTournaments:
            leagueOrTournamentsParam ?? this.leagueOrTournaments);
  }
}

///
/// No data at all yet.
///
class LeagueOrTournamentUninitialized extends LeagueOrTournamentState {
  LeagueOrTournamentUninitialized()
      : super(leagueOrTournaments: {}, onlySql: true);

  @override
  String toString() {
    return 'LeagueOrTournamentUninitialized{}';
  }
}

///
/// Doing something.
///
class LeagueOrTournamentLoaded extends LeagueOrTournamentState {
  LeagueOrTournamentLoaded(
      {@required Map<String, LeagueOrTournament> leagueOrTournaments,
      @required bool onlySql,
      Map<String, Iterable<LeagueOrTournamentSeason>> leagueOrTournamentSeasons,
      Map<String, Iterable<LeagueOrTournamentDivison>>
          leagueOrTournamentDivisions,
      Map<String, Iterable<LeagueOrTournamentTeam>> leagueOrTournamentTeams})
      : super(leagueOrTournaments: leagueOrTournaments, onlySql: onlySql);

  @override
  String toString() {
    return 'LeagueOrTournamentLoaded{}';
  }
}

class LeagueOrTournamentEvent extends Equatable {}

class _LeagueOrTournamentEventUserLoaded extends LeagueOrTournamentEvent {
  final String uid;

  _LeagueOrTournamentEventUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_LeagueOrTournamentEventUserLoaded{}';
  }
}

class _LeagueOrTournamentEventLogout extends LeagueOrTournamentEvent {}

class _LeagueOrTournamentEventNewDataLoaded extends LeagueOrTournamentEvent {
  final Map<String, LeagueOrTournament> leagueOrTournament;

  _LeagueOrTournamentEventNewDataLoaded({@required this.leagueOrTournament});
}

class _LeagueOrTournamentEventFirestore extends LeagueOrTournamentEvent {
  final String uid;

  _LeagueOrTournamentEventFirestore({@required this.uid});

  @override
  String toString() {
    return '_LeagueOrTournamentEventFirestore{}';
  }
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class LeagueOrTournamentBloc
    extends Bloc<LeagueOrTournamentEvent, LeagueOrTournamentState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournament>> _leagueOrTournamentSnapshot;

  LeagueOrTournamentBloc({@required this.coordinationBloc}) {
    _coordSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_LeagueOrTournamentEventLogout());
      } else if (state is CoordinationStateStartLoadingSql) {
        _startLoading(state);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(state);
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

  void _startLoading(CoordinationStateStartLoadingSql state) {
    dispatch(_LeagueOrTournamentEventUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    dispatch(_LeagueOrTournamentEventFirestore(uid: state.uid));
  }

  @override
  LeagueOrTournamentState get initialState => LeagueOrTournamentUninitialized();

  void _onLeagueOrTournamentsUpdated(Iterable<LeagueOrTournament> leagues) {
    Map<String, LeagueOrTournament> leagueOrTournsments;
    Set<String> toRemove = Set.from(currentState.leagueOrTournaments.keys);
    for (LeagueOrTournament league in leagues) {
      leagueOrTournsments[league.uid] = league;
      coordinationBloc.persistentData.updateElement(
          PersistenData.leagueOrTournamentTable,
          league.uid,
          league.toJson(includeMembers: true));
      toRemove.remove(league.uid);
    }
    for (String remove in toRemove) {
      coordinationBloc.persistentData
          .deleteElement(PersistenData.leagueOrTournamentTable, remove);
    }
    dispatch(_LeagueOrTournamentEventNewDataLoaded(
        leagueOrTournament: leagueOrTournsments));
  }

  @override
  Stream<LeagueOrTournamentState> mapEventToState(
      LeagueOrTournamentEvent event) async* {
    if (event is _LeagueOrTournamentEventUserLoaded) {
      TraceProxy leagueTrace = coordinationBloc.analyticsSubsystem
          .newTrace("leagueOrTournamentData");
      leagueTrace.start();
      Map<String, Map<String, dynamic>> leagueData = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.leagueOrTournamentTable);
      Map<String, LeagueOrTournament> newLeague =
          new Map<String, LeagueOrTournament>();
      leagueData.forEach((String uid, Map<String, dynamic> input) {
        coordinationBloc.sqlTrace?.incrementCounter("league");
        LeagueOrTournament league = LeagueOrTournament.fromJSON(
                myUid: uid,
                data: input,
                userUid: coordinationBloc.authenticationBloc.currentUser.uid)
            .build();
        newLeague[uid] = league;
      });
      print(
          'End LeagueOrTournament ${coordinationBloc.start.difference(new DateTime.now())} ${newLeague.length}');
      leagueTrace.stop();
      yield currentState.rebuild(
          onlySqlParam: true, leagueOrTournamentsParam: newLeague);
      coordinationBloc.dispatch(CoordinationEventLoadedData(
          loaded: BlocsToLoad.LeagueOrTournament, sql: true));
    }

    if (event is _LeagueOrTournamentEventFirestore) {
      _leagueOrTournamentSnapshot = coordinationBloc.databaseUpdateModel
          .getMainLeagueOrTournaments(event.uid)
          .listen((Iterable<LeagueOrTournament> leagues) =>
              this._onLeagueOrTournamentsUpdated(leagues));
    }

    // New data from above.  Mark ourselves as done.
    if (event is _LeagueOrTournamentEventNewDataLoaded) {
      yield currentState.rebuild(
          leagueOrTournamentsParam: event.leagueOrTournament,
          onlySqlParam: false);
      coordinationBloc.dispatch(CoordinationEventLoadedData(
          loaded: BlocsToLoad.LeagueOrTournament, sql: false));
    }

    // Unload everything.
    if (event is _LeagueOrTournamentEventLogout) {
      yield LeagueOrTournamentUninitialized();
      _cleanupStuff();
    }
  }
}
