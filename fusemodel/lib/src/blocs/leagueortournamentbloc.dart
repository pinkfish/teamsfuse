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
      toRemove.remove(league.uid);
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
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.LeagueOrTournament));
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
