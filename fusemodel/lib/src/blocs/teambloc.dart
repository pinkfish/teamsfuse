import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'authenticationbloc.dart';
import 'playerbloc.dart';

class TeamEvent extends Equatable {}

class _TeamUserLoaded extends TeamEvent {
  final String uid;

  _TeamUserLoaded({@required this.uid});

  @override
  String toString() {
    return 'PlayerDataUpdates{}';
  }
}

class _TeamPlayersLoaded extends TeamEvent {
  final List<Player> players;

  _TeamPlayersLoaded({@required this.players});

  @override
  String toString() {
    return 'PlayerDataUpdates{}';
  }
}

class _TeamLoggedOut extends TeamEvent {}

class _OpponentsUpdated extends TeamEvent {
  final String teamUid;
  final List<FirestoreWrappedData> data;

  _OpponentsUpdated({@required this.teamUid, @required this.data});
}

class _SeasonsUpdated extends TeamEvent {
  final String teamUid;
  final String seasonUid;
  final Map<String, dynamic> data;

  _SeasonsUpdated(
      {@required this.teamUid, @required this.seasonUid, @required this.data});
}

class _SeasonRemoved extends TeamEvent {
  final String teamUid;
  final String seasonUid;

  _SeasonRemoved({@required this.teamUid, @required this.seasonUid});
}

class _TeamUpdated extends TeamEvent {
  final String teamUid;
  final Map<String, dynamic> data;

  _TeamUpdated({@required this.teamUid, @required this.data});
}

class _TeamDeleted extends TeamEvent {
  final String teamUid;

  _TeamDeleted({@required this.teamUid});
}

class _TeamAdminUpdated extends TeamEvent {
  final Map<String, Team> adminTeams;

  _TeamAdminUpdated({@required this.adminTeams});
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
  final Map<String, Team> adminTeams;
  final Map<String, Team> teams;
  final Map<String, Map<String, Team>> clubTeams;
  final bool onlySql;

  TeamState(
      {@required this.teams,
      @required this.onlySql,
      @required this.adminTeams,
      @required this.clubTeams});

  ///
  /// Get the team from the various places it could exist.
  ///
  Team getTeam(String uid) {
    if (teams.containsKey(uid)) {
      return teams[uid];
    }
    if (adminTeams.containsKey(uid)) {
      return adminTeams[uid];
    }
    return null;
  }

  Set<String> get allTeamUids {
    Set<String> set = Set.from(adminTeams.keys);
    clubTeams.forEach(
        (String clubUid, Map<String, Team> data) => set.addAll(data.keys));
    set.addAll(clubTeams.keys);
    set.addAll(teams.keys);
    return set;
  }
}

///
/// No data at all, we are uninitialized.
///
class TeamUninitialized extends TeamState {
  TeamUninitialized()
      : super(teams: {}, adminTeams: {}, clubTeams: {}, onlySql: true);

  @override
  String toString() {
    return 'TeamUninitialized{players: ${teams.length}, onlySql: $onlySql}';
  }
}

///
/// Player data is loaded and everything is fluffy.
///
class TeamLoaded extends TeamState {
  TeamLoaded(
      {@required Map<String, Team> teams,
      @required Map<String, Team> adminTeams,
      @required Map<String, Map<String, Team>> clubTeams,
      @required bool onlySql})
      : super(
            teams: teams,
            clubTeams: clubTeams,
            onlySql: onlySql,
            adminTeams: adminTeams);

  @override
  String toString() {
    return 'PlayerData{players: ${teams.length}, onlySql: $onlySql}';
  }
}

///
/// Team bloc handles the teams flow.  Loading all the teams from
/// firestore.
///
class TeamBloc extends Bloc<TeamEvent, TeamState>
    implements TeamSnapshotCallback {
  final AuthenticationBloc authenticationBloc;
  final PlayerBloc playerBloc;

  StreamSubscription<AuthenticationState> _authSub;
  StreamSubscription<PlayerState> _playerSub;
  StreamSubscription<FirestoreChangedData> _adminTeamSub;
  Map<String, List<StreamSubscription<dynamic>>> _teamSubscriuption = {};
  Map<String, List<StreamSubscription<dynamic>>> _playerSubscriptions = {};

  TeamBloc({@required this.authenticationBloc, @required this.playerBloc}) {
    _authSub = authenticationBloc.state.listen((AuthenticationState state) {
      if (state is AuthenticationLoggedIn) {
        _startAdminLoading(state);
      } else {
        dispatch(_TeamLoggedOut());
      }
    });
    if (authenticationBloc.currentState is AuthenticationLoggedIn) {
      _startAdminLoading(authenticationBloc.currentState);
    }
    _playerSub = playerBloc.state.listen((PlayerState state) {
      if (state is PlayerLoaded) {
        _startLoading(state);
      }
    });
  }

  void _startLoading(PlayerState state) {
    dispatch(_TeamPlayersLoaded(players: state.players.values));
  }

  void _startAdminLoading(AuthenticationLoggedIn state) {
    dispatch(_TeamUserLoaded(uid: state.user.uid));
  }

  // This is called when the player seasons are updated.  Runs the rest of the
  // update stuff from in here.
  void _onPlayerSeasonUpdated(
      String playerUid, List<FirestoreWrappedData> query) async {
    Set<String> toDeleteSeasons = new Set<String>();
    Map<String, String> seasonToTeam = {};
    String teamUid;

    for (Team t in currentState.teams.values) {
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

    for (FirestoreWrappedData doc in query) {
      playerBloc.loadingTrace?.incrementCounter("team");
      // Get the team from the season.
      teamUid = doc.data[Season.TEAMUID];
      Team team;
      bool snapping = false;
      if (currentState.teams.containsKey(teamUid)) {
        team = currentState.teams[teamUid];
        team.uid = teamUid;
      } else {
        team = new Team();
        team.uid = teamUid;
      }

      team.onSeasonUpdated(team.uid, doc.id, doc.data);
      toDeleteSeasons.remove(doc.id);
      if (!_teamSubscriuption.containsKey(team.uid)) {
        _teamSubscriuption[team.uid] =
            await playerBloc.databaseUpdateModel.setupSnapForTeam(team, this);
      }
      playerBloc.persistentData
          .updateElement(PersistenData.teamsTable, team.uid, team.toJSON());
    }

    for (String deleteUid in toDeleteSeasons) {
      // Check and see if any current players need to be setup in here.
      Team team = currentState.getTeam(seasonToTeam[deleteUid]);
      if (team != null) {
        bool overFound = false;
        for (String playerUid in playerBloc.currentState.players.keys) {
          overFound = overFound ||
              team.seasons[deleteUid].players
                  .any((SeasonPlayer p) => p.playerUid == playerUid);
        }
        if (!overFound) {
          onSeasonRemoved(seasonToTeam[deleteUid], deleteUid);
        }
      }
    }
  }

  @override
  TeamState get initialState {
    return new TeamUninitialized();
  }

  void _cleanupSnaps() {
    _adminTeamSub?.cancel();
    for (String playerUid in _playerSubscriptions.keys) {
      // Remove the updates in here...
      for (StreamSubscription<dynamic> s in _playerSubscriptions[playerUid]) {
        s.cancel();
      }
    }
    _playerSubscriptions = {};
    for (String t in _teamSubscriuption.keys) {
      for (StreamSubscription<dynamic> s in _teamSubscriuption[t]) {
        s.cancel();
      }
    }
    _teamSubscriuption = {};
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupSnaps();
    _playerSub?.cancel();
    _authSub?.cancel();
  }

  @override
  void onClubUpdated(FirestoreWrappedData data) {}

  void _onTeamAdminsUpdate(FirestoreChangedData change) {
    print('onTeamAdminsUpdated');
    Map<String, Team> newAdminTeams = {};

    for (FirestoreWrappedData doc in change.newList) {
      playerBloc.loadingTrace?.incrementCounter("adminTeam");
      if (currentState.adminTeams.containsKey(doc.id)) {
        newAdminTeams[doc.id] = currentState.adminTeams[doc.id];
        newAdminTeams[doc.id].onTeamUpdated(doc.id, doc.data);
        playerBloc.persistentData.updateElement(
            PersistenData.teamsTable, doc.id, newAdminTeams[doc.id].toJSON());
      } else {
        Team team = new Team.fromJSON(doc.id, doc.data);
        newAdminTeams[team.uid] = team;
        playerBloc.persistentData
            .updateElement(PersistenData.teamsTable, team.uid, team.toJSON());
      }
    }
    for (FirestoreWrappedData doc in change.removed) {
      if (newAdminTeams[doc.id].seasons.length == 0) {
        newAdminTeams.remove(doc.id);
        playerBloc.persistentData
            .deleteElement(PersistenData.teamsTable, doc.id);
      }
    }
    dispatch(_TeamAdminUpdated(adminTeams: newAdminTeams));
  }

  @override
  Stream<TeamState> mapEventToState(TeamEvent event) async* {
    if (event is _TeamUserLoaded) {
      // Starting, nothing loaded yet.
      yield TeamUninitialized();
      TraceProxy teamsTrace =
          playerBloc.analyticsSubsystem.newTrace("teamData");
      teamsTrace.start();
      Map<String, Map<String, dynamic>> data = await playerBloc.persistentData
          .getAllElements(PersistenData.teamsTable);
      Map<String, Team> newTeams = new Map<String, Team>();
      Map<String, Team> newAdminTeams = new Map<String, Team>();
      print('Start teams ${playerBloc.start.difference(new DateTime.now())}');
      for (String uid in data.keys) {
        playerBloc.sqlTrace?.incrementCounter("team");
        teamsTrace.incrementCounter("team");
        Map<String, dynamic> input = data[uid];
        Team team = new Team.fromJSON(uid, input);
        if (team.isAdmin()) {
          newAdminTeams[uid] = team;
        } else {
          newTeams[uid] = team;
        }

        // Load opponents.
        Map<String, Map<String, dynamic>> opponentData = await playerBloc
            .persistentData
            .getAllTeamElements(PersistenData.opponentsTable, uid);
        for (String key in opponentData.keys) {
          playerBloc.sqlTrace?.incrementCounter("opponent");
          teamsTrace.incrementCounter("opponent");
          Map<String, dynamic> innerData = opponentData[key];
          Opponent op = new Opponent();
          op.fromJSON(key, uid, innerData);
          team.opponents[key] = op;
        }
      }
      yield TeamLoaded(
          teams: newTeams,
          clubTeams: currentState.clubTeams,
          adminTeams: newAdminTeams,
          onlySql: true);

      // Do the admin team loading thing.
      InitialSubscription initialState =
          playerBloc.databaseUpdateModel.getTeamAdmins(event.uid);
      List<FirestoreWrappedData> adminData = await initialState.startData;
      playerBloc.loadingTrace?.incrementCounter("teamAdmin");

      this._onTeamAdminsUpdate(
          FirestoreChangedData(newList: adminData, removed: []));
      // Cleanup.
      currentState.adminTeams.removeWhere((String key, Team t) {
        if (t.seasons.length == 0 && !t.isAdmin()) {
          dispatch(_SeasonRemoved(teamUid: t.uid, seasonUid: "None"));
        }
      });

      _adminTeamSub = initialState.stream.listen((FirestoreChangedData data) {
        print('team admin $data');
        this._onTeamAdminsUpdate(data);
      });
    }

    // Unload everything.
    if (event is _TeamLoggedOut) {
      yield TeamUninitialized();
      _cleanupSnaps();
    }

    // Hpdate just the admins.
    if (event is _TeamAdminUpdated) {
      // Remove any admin teams in the non-admin set.
      Map<String, Team> nonAdminTeams = currentState.teams;
      for (String uid in event.adminTeams.keys) {
        nonAdminTeams.remove(uid);
      }
      yield TeamLoaded(
          teams: nonAdminTeams,
          adminTeams: event.adminTeams,
          clubTeams: currentState.clubTeams,
          onlySql: currentState.onlySql);
    }

    // Update the data based on the loaded players.
    if (event is _TeamPlayersLoaded) {
      Set<String> toDelete = Set.from(_playerSubscriptions.keys);
      // For each player grab a snapper.
      for (Player p in event.players) {
        toDelete.remove(p.uid);
        if (!_playerSubscriptions.containsKey(p.uid)) {
          _playerSubscriptions[p.uid] = playerBloc.databaseUpdateModel
              .setupPlayerSnap(p.uid, _onPlayerSeasonUpdated);
        }
      }
      for (String deleteUid in toDelete) {
        // Remove the updates in here...
        for (StreamSubscription<dynamic> s in _playerSubscriptions[deleteUid]) {
          s.cancel();
        }
        _playerSubscriptions.remove(deleteUid);
      }
    }

    if (event is _OpponentsUpdated) {
      Team team = currentState.getTeam(event.teamUid);
      if (team != null) {
        team.onOpponentUpdated(team.uid, event.data);
        yield TeamLoaded(
            teams: currentState.teams,
            adminTeams: currentState.adminTeams,
            clubTeams: currentState.clubTeams,
            onlySql: currentState.onlySql);
      } else {
        print('No team to update ${event.teamUid}');
      }
    }

    if (event is _SeasonsUpdated) {
      Team team = currentState.getTeam(event.teamUid);
      if (team != null) {
        team.onSeasonUpdated(team.uid, event.seasonUid, event.data);
        yield TeamLoaded(
            teams: currentState.teams,
            adminTeams: currentState.adminTeams,
            clubTeams: currentState.clubTeams,
            onlySql: currentState.onlySql);
      } else {
        print('No team to update ${event.teamUid}');
      }
    }

    if (event is _SeasonRemoved) {
      // Check and see if we should really remove it first.
      Team team = currentState.getTeam(event.teamUid);
      if (team != null && !team.isAdmin()) {
        bool overFound = false;
        for (String playerUid in playerBloc.currentState.players.keys) {
          overFound = overFound ||
              team.seasons[event.seasonUid].players
                  .any((SeasonPlayer p) => p.playerUid == playerUid);
        }
        if (!overFound) {
          team.seasons.remove(event.seasonUid);
          yield TeamLoaded(
              teams: currentState.teams,
              adminTeams: currentState.adminTeams,
              clubTeams: currentState.clubTeams,
              onlySql: currentState.onlySql);
        }
      }
    }

    if (event is _TeamUpdated) {
      Team team = currentState.getTeam(event.teamUid);
      if (team != null) {
        team.onTeamUpdated(event.teamUid, event.data);
        yield TeamLoaded(
            teams: currentState.teams,
            adminTeams: currentState.adminTeams,
            clubTeams: currentState.clubTeams,
            onlySql: currentState.onlySql);
      }
    }
  }

  @override
  void onOpponentUpdated(String teamUid, List<FirestoreWrappedData> data) {
    dispatch(_OpponentsUpdated(teamUid: teamUid, data: data));
  }

  @override
  void onSeasonUpdated(
      String teamUid, String seasonUid, Map<String, dynamic> data) {
    dispatch(
        _SeasonsUpdated(teamUid: teamUid, seasonUid: seasonUid, data: data));
  }

  @override
  void onSeasonRemoved(String teamUid, String seasonUid) {
    dispatch(_SeasonRemoved(teamUid: teamUid, seasonUid: seasonUid));
  }

  @override
  void onTeamUpdated(String teamUid, Map<String, dynamic> data) {
    dispatch(_TeamUpdated(teamUid: teamUid, data: data));
  }

  @override
  void onTeamDeleted(String teamUid) {
    dispatch(_TeamDeleted(teamUid: teamUid));
  }
}
