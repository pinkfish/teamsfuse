import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
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
  final AnalyticsSubsystem crashes;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<Iterable<LeagueOrTournament>> _leagueOrTournamentSnapshot;

  bool _loadingFirestore = false;

  LeagueOrTournamentBloc(
      {@required this.coordinationBloc, @required this.crashes})
      : super(LeagueOrTournamentUninitialized()) {
    coordinationBloc.add(
        CoordinationEventTrackLoading(toLoad: BlocsToLoad.LeagueOrTournament));

    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_LeagueOrTournamentEventLogout());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    await _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
  }

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    if (!_loadingFirestore) {
      _loadingFirestore = true;

      add(_LeagueOrTournamentEventFirestore(uid: state.uid));
    }
  }

  void _onLeagueOrTournamentsUpdated(Iterable<LeagueOrTournament> leagues) {
    var leagueOrTournsments = <String, LeagueOrTournament>{};
    var toRemove = Set<String>.from(state.leagueOrTournaments.keys);
    for (var league in leagues) {
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
          .getMainLeagueOrTournaments()
          .listen((Iterable<LeagueOrTournament> leagues) =>
              _onLeagueOrTournamentsUpdated(leagues));
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
    if (json == null || !json.containsKey('type')) {
      return LeagueOrTournamentUninitialized();
    }
    var type = LeagueOrTournamentBlocStateType.valueOf(json['type']);
    switch (type) {
      case LeagueOrTournamentBlocStateType.Uninitialized:
        return LeagueOrTournamentUninitialized();
      case LeagueOrTournamentBlocStateType.Loaded:
        try {
          var leagueTrace =
              coordinationBloc.analytics.newTrace('leagueOrTournamentData');
          leagueTrace.start();
          var loaded = LeagueOrTournamentLoaded.fromMap(json);
          leagueTrace.stop();
          return loaded;
        } catch (e, stack) {
          if (e is Error) {
            crashes.recordError(e, stack);
          } else {
            crashes.recordException(e, stack);
          }
        }
        return LeagueOrTournamentUninitialized();
      default:
        return LeagueOrTournamentUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(LeagueOrTournamentState state) {
    return state.toMap();
  }
}
