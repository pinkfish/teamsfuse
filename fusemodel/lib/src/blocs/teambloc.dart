import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';
import 'package:built_collection/built_collection.dart';

import 'coordinationbloc.dart';
import 'playerbloc.dart';
import 'internal/blocstoload.dart';

class TeamEvent extends Equatable {}

class _TeamUserLoaded extends TeamEvent {
  final String uid;

  _TeamUserLoaded({@required this.uid});

  @override
  String toString() {
    return '_TeamUserLoaded{}';
  }
}

class _TeamFirestoreStart extends TeamEvent {
  final String uid;

  _TeamFirestoreStart({@required this.uid});

  @override
  String toString() {
    return '_TeamFirestoreStart{}';
  }
}

class _TeamPlayersLoaded extends TeamEvent {
  final List<Player> players;
  final bool onlySql;

  _TeamPlayersLoaded({@required this.players, @required this.onlySql});

  @override
  String toString() {
    return '_TeamPlayersLoaded{}';
  }
}

class _TeamLoggedOut extends TeamEvent {}

class _TeamAdminUpdated extends TeamEvent {
  final Map<String, Team> adminTeams;

  _TeamAdminUpdated({@required this.adminTeams});
}

class _TeamBuilderUpdate extends TeamEvent {
  final TeamBuilder teamBuilder;
  final String teamUid;

  _TeamBuilderUpdate({@required this.teamUid, @required this.teamBuilder});
}

class _TeamOpponentsUpdate extends TeamEvent {
  final String teamUid;
  final Iterable<Opponent> newOpponents;

  _TeamOpponentsUpdate({@required this.teamUid, @required this.newOpponents});
}

class _TeamPlayerSeasonUpdates extends TeamEvent {
  final Iterable<Season> seasons;
  final String playerUid;

  _TeamPlayerSeasonUpdates({@required this.playerUid, @required this.seasons});
}

///
/// This event will update the current set of club teams.
///
class TeamClubTeams extends TeamEvent {
  final Map<String, Team> clubTeams;
  final String clubUid;

  TeamClubTeams({@required this.clubTeams, @required this.clubUid});
}

///
/// Basic state for all the player states.
///
class TeamState extends Equatable {
  final BuiltMap<String, Team> adminTeams;
  final BuiltMap<String, Team> teamsByPlayer;
  final BuiltMap<String, BuiltMap<String, Team>> clubTeams;
  final bool onlySql;

  TeamState(
      {@required this.teamsByPlayer,
      @required this.onlySql,
      @required this.adminTeams,
      @required this.clubTeams});

  ///
  /// Get the team from the various places it could exist.
  ///
  Team getTeam(String uid) {
    if (teamsByPlayer.containsKey(uid)) {
      return teamsByPlayer[uid];
    }

    if (adminTeams.containsKey(uid)) {
      return adminTeams[uid];
    }
    for (BuiltMap<String, Team> ts in clubTeams.values) {
      if (ts.containsKey(uid)) {
        return ts[uid];
      }
    }
    return null;
  }

  Set<String> get allTeamUids {
    Set<String> set = Set.from(adminTeams.keys);
    clubTeams.forEach(
        (String clubUid, BuiltMap<String, Team> data) => set.addAll(data.keys));
    set.addAll(clubTeams.keys);
    set.addAll(teamsByPlayer.keys);
    return set;
  }
}

///
/// No data at all, we are uninitialized.
///
class TeamUninitialized extends TeamState {
  TeamUninitialized()
      : super(
            teamsByPlayer: BuiltMap(),
            adminTeams: BuiltMap(),
            clubTeams: BuiltMap(),
            onlySql: true);

  @override
  String toString() {
    return 'TeamUninitialized{players: ${teamsByPlayer.length}, onlySql: $onlySql}';
  }
}

///
/// Player data is loaded and everything is fluffy.
///
class TeamLoaded extends TeamState {
  TeamLoaded(
      {@required BuiltMap<String, Team> teamsByPlayer,
      @required BuiltMap<String, Team> adminTeams,
      @required BuiltMap<String, BuiltMap<String, Team>> clubTeams,
      @required bool onlySql})
      : super(
            teamsByPlayer: teamsByPlayer,
            clubTeams: clubTeams,
            onlySql: onlySql,
            adminTeams: adminTeams);

  @override
  String toString() {
    return 'PlayerData{players: ${teamsByPlayer.length}, onlySql: $onlySql}';
  }
}

///
/// Team bloc handles the teams flow.  Loading all the teams from
/// firestore.
///
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final CoordinationBloc coordinationBloc;
  final PlayerBloc playerBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<PlayerState> _playerSub;
  StreamSubscription<Iterable<Team>> _adminTeamSub;
  Map<String, StreamSubscription<Iterable<Opponent>>>
      _teamOpponentSubscriuption = {};
  Map<String, StreamSubscription<TeamBuilder>> _teammDetailsSubscription = {};
  Map<String, StreamSubscription<Iterable<Season>>> _playerSeasonSubscriuption =
      {};
  TraceProxy _teamByPlayerTrace;

  TeamBloc({@required this.coordinationBloc, @required this.playerBloc}) {
    _coordSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_TeamLoggedOut());
      } else if (state is CoordinationStateStartLoadingSql) {
        _startAdminLoading(state);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startAdminLoadingFirestore(state);
      }
    });
    _playerSub = playerBloc.state.listen((PlayerState state) {
      if (state is PlayerLoaded) {
        _startLoading(state);
      }
    });
  }

  void _startLoading(PlayerState state) {
    dispatch(_TeamPlayersLoaded(
        players: state.players.values, onlySql: state.onlySql));
  }

  void _startAdminLoading(CoordinationStateStartLoadingSql state) {
    dispatch(_TeamUserLoaded(uid: state.uid));
  }

  void _startAdminLoadingFirestore(
      CoordinationStateStartLoadingFirestore state) {
    dispatch(_TeamFirestoreStart(uid: state.uid));
  }

  // This is called when the player seasons are updated.  Runs the rest of the
  // update stuff from in here.
  Future<Map<String, Team>> _onPlayerSeasonUpdated(
      String playerUid, Iterable<Season> seasons) async {
    Set<String> toDeleteSeasons = new Set<String>();
    Map<String, String> seasonToTeam = {};

    _teamByPlayerTrace?.incrementCounter('season');

    for (Team t in currentState.teamsByPlayer.values) {
      if (!t.isAdmin()) {
        Iterable<String> playerSeasons = t.seasons.keys.where(
            (String seasonUid) => t.seasons[seasonUid].players
                .any((SeasonPlayer p) => p.playerUid == playerUid));
        toDeleteSeasons.addAll(playerSeasons);
        for (String s in t.seasons.keys) {
          seasonToTeam[s] = t.uid;
        }
      }
    }

    Map<String, Team> teams =
        Map.fromEntries(currentState.teamsByPlayer.entries);
    for (Season doc in seasons) {
      coordinationBloc.loadingTrace?.incrementCounter("team");
      _teamByPlayerTrace?.incrementCounter('team');
      // Get the team from the season.
      String teamUid = doc.teamUid;
      TeamBuilder tBuilder;
      if (teams.containsKey(teamUid)) {
        tBuilder = teams[teamUid].toBuilder();
      } else {
        // Get the data for the team itself.
        Stream<TeamBuilder> tb =
            coordinationBloc.databaseUpdateModel.getTeamDetails(tBuilder.uid);
        tBuilder = await tb.first;
        _teammDetailsSubscription[teamUid] = tb.listen((TeamBuilder b) {
          dispatch(_TeamBuilderUpdate(teamUid: teamUid, teamBuilder: b));
        });
      }
      tBuilder.seasons[doc.uid] = doc;
      toDeleteSeasons.remove(doc.uid);
      if (!_teamOpponentSubscriuption.containsKey(teamUid)) {
        Stream<Iterable<Opponent>> str =
            coordinationBloc.databaseUpdateModel.getTeamOpponents(teamUid);
        Iterable<Opponent> ops = await str.first;
        for (Opponent op in ops) {
          _teamByPlayerTrace?.incrementCounter('opponent');
          tBuilder.opponents[op.uid] = op;
        }
        _teamOpponentSubscriuption[teamUid] =
            str.listen((Iterable<Opponent> ops) {
          dispatch(
              _TeamOpponentsUpdate(teamUid: tBuilder.uid, newOpponents: ops));
        });
      }
      Team t = tBuilder.build();
      coordinationBloc.loadingTrace?.incrementCounter("playerTeam");
      coordinationBloc.persistentData
          .updateElement(PersistenData.teamsTable, teamUid, t.toJSON());
      teams[teamUid] = t;
    }

    for (String deleteUid in toDeleteSeasons) {
      // Check and see if any current players need to be setup in here.
      Team team = teams[seasonToTeam[deleteUid]];
      if (team != null) {
        bool overFound = false;
        for (String playerUid in playerBloc.currentState.players.keys) {
          overFound = overFound ||
              team.seasons[deleteUid].players
                  .any((SeasonPlayer p) => p.playerUid == playerUid);
        }
        if (!overFound) {
          _teamByPlayerTrace?.incrementCounter('deleteseason');
          // Remove the season.
          teams[seasonToTeam[deleteUid]] =
              team.rebuild((b) => b.seasons.remove(deleteUid));
          coordinationBloc.persistentData
              .deleteElement(PersistenData.teamsTable, deleteUid);
        }
      }
    }

    return teams;
  }

  @override
  TeamState get initialState {
    return new TeamUninitialized();
  }

  void _cleanupSnaps() {
    _adminTeamSub?.cancel();
    // Remove the updates in here...
    for (StreamSubscription<Iterable<Season>> s
        in _playerSeasonSubscriuption.values) {
      s.cancel();
    }
    _playerSeasonSubscriuption.clear();
    for (StreamSubscription<Iterable<Opponent>> s
        in _teamOpponentSubscriuption.values) {
      s.cancel();
    }
    _teamOpponentSubscriuption.clear();

    for (StreamSubscription<TeamBuilder> tb
        in _teammDetailsSubscription.values) {
      tb.cancel();
    }
    _teammDetailsSubscription.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupSnaps();
    _playerSub?.cancel();
    _coordSub?.cancel();
  }

  @override
  void onClubUpdated(FirestoreWrappedData data) {}

  void _onTeamAdminsUpdatePeristentData(
      BuiltMap<String, Team> oldTeams, Iterable<Team> newTeams) {
    Set<String> toRemove = Set.of(oldTeams.keys);
    print('onTeamAdminsUpdated');

    for (Team doc in newTeams) {
      coordinationBloc.loadingTrace?.incrementCounter("adminTeam");
      coordinationBloc.persistentData
          .updateElement(PersistenData.teamsTable, doc.uid, doc.toJSON());
      toRemove.remove(doc.uid);
    }
    for (String teamId in toRemove) {
      coordinationBloc.persistentData
          .deleteElement(PersistenData.teamsTable, teamId);
    }
  }

  @override
  Stream<TeamState> mapEventToState(TeamEvent event) async* {
    if (event is _TeamUserLoaded) {
      // Starting, nothing loaded yet.
      yield TeamUninitialized();
      TraceProxy teamsTrace =
          coordinationBloc.analyticsSubsystem.newTrace("teamData");
      teamsTrace.start();
      Map<String, Map<String, dynamic>> data = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.teamsTable);
      Map<String, Team> newTeams = new Map<String, Team>();
      Map<String, Team> newAdminTeams = new Map<String, Team>();
      print(
          'Start teams ${coordinationBloc.start.difference(new DateTime.now())}');
      for (String uid in data.keys) {
        coordinationBloc.sqlTrace?.incrementCounter("team");
        teamsTrace.incrementCounter("team");
        Map<String, dynamic> input = data[uid];
        TeamBuilder team = Team.fromJSON(uid, input);

        // Load opponents.
        Map<String, Map<String, dynamic>> opponentData = await coordinationBloc
            .persistentData
            .getAllTeamElements(PersistenData.opponentsTable, uid);
        for (String key in opponentData.keys) {
          coordinationBloc.sqlTrace?.incrementCounter("opponent");
          teamsTrace.incrementCounter("opponent");
          Map<String, dynamic> innerData = opponentData[key];
          Opponent op = Opponent.fromJSON(key, uid, innerData).build();
          team.opponents[key] = op;
        }
        Team realTeam = team.build();
        if (realTeam.isAdmin()) {
          newAdminTeams[uid] = realTeam;
        } else {
          newTeams[uid] = realTeam;
        }
      }
      yield TeamLoaded(
          teamsByPlayer: BuiltMap.from(newTeams),
          clubTeams: currentState.clubTeams,
          adminTeams: BuiltMap.from(newAdminTeams),
          onlySql: true);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: true));
    }

    // Start the firestore loading.
    if (event is _TeamFirestoreStart) {
      // Do the admin team loading thing.
      TraceProxy adminTrace = coordinationBloc.analytics.newTrace('adminTeams');
      Stream<Iterable<Team>> initialState =
          coordinationBloc.databaseUpdateModel.getTeamAdmins(event.uid);
      Iterable<Team> adminData = await initialState.first;
      coordinationBloc.loadingTrace?.incrementCounter("teamAdmin");
      BuiltMap<String, Team> oldAdminTeams = currentState.adminTeams;
      yield TeamLoaded(
          teamsByPlayer: currentState.teamsByPlayer,
          adminTeams: BuiltMap.from(
              Map.fromIterable(adminData, key: (t) => t.uid, value: (t) => t)),
          clubTeams: currentState.clubTeams,
          onlySql: currentState.onlySql);
      _onTeamAdminsUpdatePeristentData(oldAdminTeams, adminData);

      _adminTeamSub = initialState.listen((Iterable<Team> data) {
        print('team admin $data');
        dispatch(_TeamAdminUpdated(
            adminTeams: Map.fromIterable(adminData,
                key: (t) => t.uid, value: (t) => t)));
      });
      adminTrace.stop();
    }

    // Unload everything.
    if (event is _TeamLoggedOut) {
      yield TeamUninitialized();
      _cleanupSnaps();
    }

    // Hpdate just the admins.
    if (event is _TeamAdminUpdated) {
      BuiltMap<String, Team> oldAdminTeams = currentState.adminTeams;
      yield TeamLoaded(
          teamsByPlayer: currentState.teamsByPlayer,
          adminTeams: BuiltMap.from(event.adminTeams),
          clubTeams: currentState.clubTeams,
          onlySql: currentState.onlySql);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: true));
      _onTeamAdminsUpdatePeristentData(oldAdminTeams, event.adminTeams.values);
    }

    // Update the data based on the loaded players.
    if (event is _TeamPlayersLoaded) {
      // onluy dpo this once we jhabve real data

      if (!event.onlySql) {
        if (_playerSeasonSubscriuption.isEmpty) {
          _teamByPlayerTrace =
              coordinationBloc.analytics.newTrace('teamsByPlayer');
        }

        Set<String> toDelete = Set.from(_playerSeasonSubscriuption.keys);
        // For each player grab a snapper.
        for (Player p in event.players) {
          toDelete.remove(p.uid);
          if (!_playerSeasonSubscriuption.containsKey(p.uid)) {
            String myUid = p.uid;
            _playerSeasonSubscriuption[p.uid] = coordinationBloc
                .databaseUpdateModel
                .getPlayerSeasons(p.uid)
                .listen((Iterable<Season> seasons) {
              dispatch(
                  _TeamPlayerSeasonUpdates(seasons: seasons, playerUid: myUid));
            });
          }
        }
        for (String deleteUid in toDelete) {
          // Remove the updates in here...
          if (_playerSeasonSubscriuption.containsKey(deleteUid)) {
            _playerSeasonSubscriuption[deleteUid].cancel();
          }
          _playerSeasonSubscriuption.remove(deleteUid);
        }
      }
    }

    if (event is _TeamPlayerSeasonUpdates) {
      if (_playerSeasonSubscriuption.length ==
          playerBloc.currentState.players.length) {
        _teamByPlayerTrace?.stop();
        _teamByPlayerTrace = null;
      }
      yield TeamLoaded(
          teamsByPlayer: BuiltMap.from(
              await _onPlayerSeasonUpdated(event.playerUid, event.seasons)),
          clubTeams: currentState.clubTeams,
          adminTeams: currentState.adminTeams,
          onlySql: false);
    }

    if (event is _TeamBuilderUpdate) {
      Team team = currentState.getTeam(event.teamUid);
      if (team != null) {
        // This is not an admin team, so keep the seasons and opponents.
        event.teamBuilder.seasons.addEntries(team.seasons.entries);
        event.teamBuilder.opponents.addEntries(team.opponents.entries);
        Map<String, Team> newTeams =
            Map.fromEntries(currentState.teamsByPlayer.entries);
        newTeams[event.teamUid] = event.teamBuilder.build();

        yield TeamLoaded(
            teamsByPlayer: BuiltMap.from(newTeams),
            adminTeams: currentState.adminTeams,
            clubTeams: currentState.clubTeams,
            onlySql: currentState.onlySql);
      }
    }
  }
}
