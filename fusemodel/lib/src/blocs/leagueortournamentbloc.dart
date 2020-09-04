import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'data/leagueortournamentblocstate.dart';
import 'internal/blocstoload.dart';

abstract class LeagueOrTournamentEvent extends Equatable {}

class _LeagueOrTournamentEventLogout extends LeagueOrTournamentEvent {
  @override
  List<Object> get props => [];
}

class _LeagueOrTournamentEventNewDataLoaded extends LeagueOrTournamentEvent {
  final BuiltMap<String, LeagueOrTournament> leagueOrTournament;

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
    extends HydratedBloc<LeagueOrTournamentEvent, LeagueOrTournamentState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournament>> _leagueOrTournamentSnapshot;

  bool _loadingFirestore = false;

  LeagueOrTournamentBloc({@required this.coordinationBloc})
      : super(LeagueOrTournamentUninitialized()) {
    coordinationBloc.add(
        CoordinationEventTrackLoading(toLoad: BlocsToLoad.LeagueOrTournament));

    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_LeagueOrTournamentEventLogout());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;

          _startLoadingFirestore(coordState);
        }
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

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    add(_LeagueOrTournamentEventFirestore(uid: state.uid));
  }

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
        leagueOrTournament: BuiltMap.of(leagueOrTournsments)));
  }

  @override
  Stream<LeagueOrTournamentState> mapEventToState(
      LeagueOrTournamentEvent event) async* {
    if (event is _LeagueOrTournamentEventFirestore) {
      _leagueOrTournamentSnapshot = coordinationBloc.databaseUpdateModel
          .getMainLeagueOrTournaments(event.uid)
          .listen((Iterable<LeagueOrTournament> leagues) =>
              this._onLeagueOrTournamentsUpdated(leagues));
    }

    // New data from above.  Mark ourselves as done.
    if (event is _LeagueOrTournamentEventNewDataLoaded) {
      yield (LeagueOrTournamentLoaded.fromState(state)
            ..leagueOrTournaments = event.leagueOrTournament.toBuilder()
            ..loadedFirestore = true)
          .build();
      coordinationBloc.add(CoordinationEventLoadedData(
          loaded: BlocsToLoad.LeagueOrTournament, sql: false));
    }

    // New data from above.  Mark ourselves as done.
    if (event is _LeagueOrTournamentEventAddFailed) {
      yield (LeagueOrTournamentLoaded.fromState(state)..adding = event.adding)
          .build();
    }

    if (event is LeagueOrTournamentEventAddLeague) {
      add(_LeagueOrTournamentEventAddFailed(adding: AddingState.Success));
      yield (LeagueOrTournamentLoaded.fromState(state)
            ..adding = AddingState.Adding)
          .build();
      coordinationBloc.databaseUpdateModel
          .updateLeague(event.league.build())
          .then((String uid) {
        add(_LeagueOrTournamentEventAddFailed(adding: AddingState.Success));
      }, onError: (e, stacktrace) {
        add(_LeagueOrTournamentEventAddFailed(adding: AddingState.Failed));
      });
    }

    if (event is LeagueOrTournamentEventReset) {
      yield (LeagueOrTournamentLoaded.fromState(state)
            ..adding = AddingState.None)
          .build();
    }

    // Unload everything.
    if (event is _LeagueOrTournamentEventLogout) {
      yield LeagueOrTournamentUninitialized();
      _cleanupStuff();
    }
  }

  @override
  LeagueOrTournamentState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return LeagueOrTournamentUninitialized();
    }
    LeagueOrTournamentBlocStateType type =
        LeagueOrTournamentBlocStateType.valueOf(json["type"]);
    switch (type) {
      case LeagueOrTournamentBlocStateType.Uninitialized:
        return LeagueOrTournamentUninitialized();
      case LeagueOrTournamentBlocStateType.Loaded:
        print("LeagueOrTournament start");
        TraceProxy leagueTrace = coordinationBloc.analyticsSubsystem
            .newTrace("leagueOrTournamentData");
        leagueTrace.start();
        var loaded = LeagueOrTournamentLoaded.fromMap(json);
        print(
            'End LeagueOrTournament ${coordinationBloc.start.difference(new DateTime.now())} ${loaded.leagueOrTournaments.length}');
        leagueTrace.stop();
        coordinationBloc.add(CoordinationEventLoadedData(
            loaded: BlocsToLoad.LeagueOrTournament, sql: true));
        return loaded;
      default:
        return LeagueOrTournamentUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(LeagueOrTournamentState state) {
    return state.toMap();
  }
}
