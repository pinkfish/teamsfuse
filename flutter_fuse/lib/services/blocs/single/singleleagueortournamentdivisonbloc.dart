import 'dart:async';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

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
/// Loads the Teams for this league or tournament.  (sets up the firebase
/// callbacks).
///
class SingleLeagueOrTournamentDivisonLoadTeams
    extends SingleLeagueOrTournamentDivisonEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the Teams for this league or tournament. (sets up the firebase
/// callbacks).
///
class SingleLeagueOrTournamentDivisonLoadGames
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

class _SingleLeagueOrTournamentEventDivisonGamesLoaded
    extends SingleLeagueOrTournamentDivisonEvent {
  final BuiltList<GameSharedData> games;

  _SingleLeagueOrTournamentEventDivisonGamesLoaded({this.games});

  @override
  List<Object> get props => [games];
}

class _SingleLeagueOrTournamentEventDivisonTeamsLoaded
    extends SingleLeagueOrTournamentDivisonEvent {
  final BuiltList<LeagueOrTournamentTeam> teams;

  _SingleLeagueOrTournamentEventDivisonTeamsLoaded({this.teams});

  @override
  List<Object> get props => [teams];
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentDivisonBloc extends AsyncHydratedBloc<
    SingleLeagueOrTournamentDivisonEvent,
    SingleLeagueOrTournamentDivisonState> {
  final DatabaseUpdateModel db;
  final String leagueDivisonUid;
  final AnalyticsSubsystem crashes;

  StreamSubscription<LeagueOrTournamentDivison> _divSub;
  StreamSubscription<Iterable<GameSharedData>> _leagueOrTournamentSnapshot;
  StreamSubscription<Iterable<LeagueOrTournamentTeam>>
      _leagueOrTournamentTeamSnapshot;

  SingleLeagueOrTournamentDivisonBloc(
      {@required this.db,
      @required this.leagueDivisonUid,
      @required this.crashes})
      : super(SingleLeagueOrTournamentDivisonUninitialized(),
            "LeagueDivison.$leagueDivisonUid}") {
    assert(this.db != null);
    _divSub = db
        .getLeagueDivisionData(
            leagueDivisionUid: leagueDivisonUid, memberUid: db.currentUser.uid)
        .listen((LeagueOrTournamentDivison div) {
      if (div == null) {
        add(_SingleLeagueOrTournamentEventDivisonDeleted());
      } else {
        add(_SingleLeagueOrTournamentEventLeagueDivisonLoaded(
            leagueDivision: div));
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
    _divSub?.cancel();
    _divSub = null;
    _leagueOrTournamentSnapshot?.cancel();
    _leagueOrTournamentSnapshot = null;
    _leagueOrTournamentTeamSnapshot?.cancel();
    _leagueOrTournamentTeamSnapshot = null;
  }

  void _cleanupStuff() {}

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentDivisonState> _updateLeagueOrTournamentDivison(
      {LeagueOrTournamentDivison divison}) async* {
    if (divison.uid == leagueDivisonUid) {
      yield SingleLeagueOrTournamentDivisonSaving.fromState(state).build();
      try {
        await db.updateLeagueDivison(divison);
        yield SingleLeagueOrTournamentDivisonSaveDone.fromState(state).build();
        yield SingleLeagueOrTournamentDivisonLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleLeagueOrTournamentDivisonSaveFailed.fromState(state)
              ..error = RemoteError(e.messages, stack.toString()))
            .build();
        yield SingleLeagueOrTournamentDivisonLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    } else {
      var e = ArgumentError("league uids don't match");
      yield (SingleLeagueOrTournamentDivisonSaveFailed.fromState(state)
            ..error = e)
          .build();
      yield SingleLeagueOrTournamentDivisonLoaded.fromState(state).build();
      crashes.recordError(e, StackTrace.current);
    }
  }

  Stream<SingleLeagueOrTournamentDivisonState> _addTeam(
      {String teamName}) async* {
    yield SingleLeagueOrTournamentDivisonSaving.fromState(state).build();
    try {
      LeagueOrTournamentTeam teamData = new LeagueOrTournamentTeam((b) => b
        ..leagueOrTournamentDivisonUid = state.divison.uid
        ..leagueOrTournamentUid = state.divison.leagueOrTournamentUid
        ..name = teamName);
      await db.updateLeagueTeam(teamData);
      yield SingleLeagueOrTournamentDivisonSaveDone.fromState(state).build();
      yield SingleLeagueOrTournamentDivisonLoaded.fromState(state).build();
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentDivisonSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentDivisonLoaded.fromState(state).build();
      crashes.recordException(e, stack);
    }
  }

  void _updateGames(Iterable<GameSharedData> games) {
    add(_SingleLeagueOrTournamentEventDivisonGamesLoaded(games: games));
  }

  @override
  Stream<SingleLeagueOrTournamentDivisonState> mapEventToState(
      SingleLeagueOrTournamentDivisonEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueDivisonLoaded) {
      yield (SingleLeagueOrTournamentDivisonLoaded.fromState(state)
            ..divison = event.leagueDivision.toBuilder())
          .build();
    }

    // Unload everything.
    if (event is _SingleLeagueOrTournamentEventDivisonDeleted) {
      yield SingleLeagueOrTournamentDivisonDeleted();
      _cleanupStuff();
    }

    if (event is SingleLeagueOrTournamentDivisonUpdate) {
      yield* _updateLeagueOrTournamentDivison(
          divison: event.leagueOrTournamentDivison);
    }

    if (event is SingleLeagueOrTournamentDivisonAddTeam) {
      yield* _addTeam(teamName: event.teamName);
    }

    if (event is _SingleLeagueOrTournamentEventDivisonGamesLoaded) {
      var builder = MapBuilder<String, GameSharedData>();
      for (var t in event.games) {
        builder[t.uid] = t;
      }
      yield (SingleLeagueOrTournamentDivisonLoaded.fromState(state)
            ..games = builder)
          .build();
    }

    if (event is _SingleLeagueOrTournamentEventDivisonTeamsLoaded) {
      var builder = MapBuilder<String, LeagueOrTournamentTeam>();
      for (var t in event.teams) {
        builder[t.uid] = t;
      }
      yield (SingleLeagueOrTournamentDivisonLoaded.fromState(state)
            ..teams = builder)
          .build();
    }

    if (event is SingleLeagueOrTournamentDivisonLoadGames) {
      if (_leagueOrTournamentTeamSnapshot != null) {
        _leagueOrTournamentSnapshot = db
            .getLeagueGamesForDivison(leagueDivisonUid)
            .listen((Iterable<GameSharedData> games) => _updateGames(games));
      }
    }

    if (event is SingleLeagueOrTournamentDivisonLoadTeams) {
      if (_leagueOrTournamentTeamSnapshot != null) {
        _leagueOrTournamentTeamSnapshot =
            db.getLeagueDivisionTeams(leagueDivisonUid).listen((event) {
          add(_SingleLeagueOrTournamentEventDivisonTeamsLoaded(teams: event));
        });
      }
    }
  }

  @override
  SingleLeagueOrTournamentDivisonState fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson(SingleLeagueOrTournamentDivisonState state) {
    return state.toMap();
  }
}
