import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

enum AddingState { None, Adding, Failed, Success }

///
/// Basic state for all the data in this system.
///
class LeagueOrTournamentState extends Equatable {
  final Map<String, LeagueOrTournament> leagueOrTournaments;
  final bool onlySql;
  final AddingState adding;

  LeagueOrTournamentState(
      {@required this.leagueOrTournaments,
      @required this.onlySql,
      @required this.adding});

  LeagueOrTournamentLoaded rebuild(
      {Map<String, LeagueOrTournament> leagueOrTournamentsParam,
      @required bool onlySqlParam,
      AddingState adding}) {
    return LeagueOrTournamentLoaded(
        onlySql: onlySqlParam ?? onlySql,
        leagueOrTournaments:
            leagueOrTournamentsParam ?? this.leagueOrTournaments,
        adding: adding ?? false);
  }

  @override
  List<Object> get props => [leagueOrTournaments, onlySql, adding];
}

///
/// No data at all yet.
///
class LeagueOrTournamentUninitialized extends LeagueOrTournamentState {
  LeagueOrTournamentUninitialized()
      : super(leagueOrTournaments: {}, onlySql: true, adding: AddingState.None);

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
      AddingState adding})
      : super(
            leagueOrTournaments: leagueOrTournaments,
            onlySql: onlySql,
            adding: adding);

  @override
  String toString() {
    return 'LeagueOrTournamentLoaded{}';
  }
}

abstract class LeagueOrTournamentEvent extends Equatable {}

class _LeagueOrTournamentEventUserLoaded extends LeagueOrTournamentEvent {
  final String uid;

  _LeagueOrTournamentEventUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_LeagueOrTournamentEventUserLoaded{}';
  }

  @override
  List<Object> get props => [uid];
}

class _LeagueOrTournamentEventLogout extends LeagueOrTournamentEvent {
  @override
  List<Object> get props => [];
}

class _LeagueOrTournamentEventNewDataLoaded extends LeagueOrTournamentEvent {
  final Map<String, LeagueOrTournament> leagueOrTournament;

  _LeagueOrTournamentEventNewDataLoaded({@required this.leagueOrTournament});

  @override
  List<Object> get props => [leagueOrTournament];
}

class _LeagueOrTournamentEventAddFailed extends LeagueOrTournamentEvent {
  final AddingState adding;

  _LeagueOrTournamentEventAddFailed({@required this.adding});

  @override
  List<Object> get props => [adding];
}

///
/// Adds a league or a tournament to the system.
///
class LeagueOrTournamentEventAddLeague extends LeagueOrTournamentEvent {
  LeagueOrTournamentBuilder league;

  LeagueOrTournamentEventAddLeague({this.league});

  @override
  List<Object> get props => [league];
}

///
/// Resets the adding state of the bloc.
///
class LeagueOrTournamentEventReset extends LeagueOrTournamentEvent {
  LeagueOrTournamentEventReset();

  @override
  List<Object> get props => [];
}

class _LeagueOrTournamentEventFirestore extends LeagueOrTournamentEvent {
  final String uid;

  _LeagueOrTournamentEventFirestore({@required this.uid});

  @override
  String toString() {
    return '_LeagueOrTournamentEventFirestore{}';
  }

  @override
  List<Object> get props => [uid];
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
    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        add(_LeagueOrTournamentEventLogout());
      } else if (state is CoordinationStateStartLoadingSql) {
        _startLoading(coordState);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(coordState);
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

  void _startLoading(CoordinationStateStartLoadingSql state) {
    add(_LeagueOrTournamentEventUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    add(_LeagueOrTournamentEventFirestore(uid: state.uid));
  }

  @override
  LeagueOrTournamentState get initialState => LeagueOrTournamentUninitialized();

  void _onLeagueOrTournamentsUpdated(Iterable<LeagueOrTournament> leagues) {
    Map<String, LeagueOrTournament> leagueOrTournsments = {};
    Set<String> toRemove = Set.from(state.leagueOrTournaments.keys);
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
    add(_LeagueOrTournamentEventNewDataLoaded(
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
      yield state.rebuild(
          adding: state.adding,
          onlySqlParam: true,
          leagueOrTournamentsParam: newLeague);
      coordinationBloc.add(CoordinationEventLoadedData(
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
      yield state.rebuild(
          leagueOrTournamentsParam: event.leagueOrTournament,
          adding: state.adding,
          onlySqlParam: false);
      coordinationBloc.add(CoordinationEventLoadedData(
          loaded: BlocsToLoad.LeagueOrTournament, sql: false));
    }

    // New data from above.  Mark ourselves as done.
    if (event is _LeagueOrTournamentEventAddFailed) {
      yield state.rebuild(
          leagueOrTournamentsParam: state.leagueOrTournaments,
          adding: event.adding,
          onlySqlParam: false);
    }

    if (event is LeagueOrTournamentEventAddLeague) {
      add(_LeagueOrTournamentEventAddFailed(adding: AddingState.Success));
      yield state.rebuild(
          leagueOrTournamentsParam: state.leagueOrTournaments,
          adding: AddingState.Adding,
          onlySqlParam: state.onlySql);
      coordinationBloc.databaseUpdateModel
          .updateLeague(event.league.build())
          .then((String uid) {
        add(_LeagueOrTournamentEventAddFailed(adding: AddingState.Success));
      }, onError: (e, stacktrace) {
        add(_LeagueOrTournamentEventAddFailed(adding: AddingState.Failed));
      });
    }

    if (event is LeagueOrTournamentEventReset) {
      yield state.rebuild(
          leagueOrTournamentsParam: state.leagueOrTournaments,
          adding: AddingState.None,
          onlySqlParam: state.onlySql);
    }

    // Unload everything.
    if (event is _LeagueOrTournamentEventLogout) {
      yield LeagueOrTournamentUninitialized();
      _cleanupStuff();
    }
  }
}
