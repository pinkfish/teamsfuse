import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'clubbloc.dart';
import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';
import 'playerbloc.dart';

abstract class TeamEvent extends Equatable {}

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
  final Iterable<Player> players;
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
  final BuiltMap<String, Team> teamsByPlayer;
  final String playerUid;
  final BuiltMap<String, Season> seasons;

  _TeamPlayerSeasonUpdates(
      {@required this.playerUid,
      @required this.teamsByPlayer,
      @required this.seasons});
}

class _NewClubTeams extends TeamEvent {
  final BuiltMap<String, Iterable<Team>> teams;

  _NewClubTeams({@required this.teams});
}

///
/// Loads the public details of this team.
///
class TeamLoadPublicTeam extends TeamEvent {
  final String teamUid;

  TeamLoadPublicTeam({@required this.teamUid});
}

///
/// Basic state for all the player states.
///
abstract class TeamState extends Equatable {
  final BuiltMap<String, Team> adminTeams;
  final BuiltMap<String, Team> teamsByPlayer;
  final BuiltMap<String, BuiltMap<String, Team>> clubTeams;
  final BuiltMap<String, Team> publicTeams;
  final BuiltMap<String, Season> seasons;
  final BuiltMap<String, Opponent> opponents;
  final bool onlySql;

  TeamState(
      {@required this.teamsByPlayer,
      @required this.onlySql,
      @required this.seasons,
      @required this.opponents,
      @required this.adminTeams,
      @required this.clubTeams,
      @required this.publicTeams})
      : super([
          adminTeams,
          teamsByPlayer,
          clubTeams,
          publicTeams,
          onlySql,
          seasons,
          opponents
        ]);

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
    if (publicTeams.containsKey(uid)) {
      return publicTeams[uid];
    }

    return null;
  }

  ///
  /// Gets the public details for the team.
  ///
  Team getPublicTeam(String uid) {
    Team t = getTeam(uid);
    if (t == null && publicTeams.containsKey(uid)) {
      return publicTeams[uid];
    }
    return t;
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
            publicTeams: BuiltMap(),
            seasons: BuiltMap(),
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
      {@required TeamState state,
      BuiltMap<String, Team> teamsByPlayer,
      BuiltMap<String, Team> adminTeams,
      BuiltMap<String, BuiltMap<String, Team>> clubTeams,
      BuiltMap<String, Team> publicTeams,
      BuiltMap<String, Season> seasons,
      BuiltMap<String, Opponent> opponents,
      bool onlySql})
      : super(
            teamsByPlayer: teamsByPlayer ?? state.teamsByPlayer,
            clubTeams: clubTeams ?? state.clubTeams,
            onlySql: onlySql ?? state.onlySql,
            publicTeams: publicTeams ?? state.publicTeams,
            adminTeams: adminTeams ?? state.adminTeams,
            opponents: opponents ?? state.opponents,
            seasons: seasons ?? state.seasons);

  @override
  String toString() {
    return 'TeamLoaded{teamsByPlayer: ${teamsByPlayer.length}, onlySql: $onlySql} seasons: ${seasons.length} opponents: ${opponents.length}';
  }
}

///
/// Team bloc handles the teams flow.  Loading all the teams from
/// firestore.
///
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final CoordinationBloc coordinationBloc;
  final PlayerBloc playerBloc;
  final ClubBloc clubBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<PlayerState> _playerSub;
  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<Team>> _adminTeamSub;
  Map<String, StreamSubscription<Iterable<Opponent>>>
      _teamOpponentSubscriuption = {};
  Map<String, StreamSubscription<TeamBuilder>> _teammDetailsSubscription = {};
  Map<String, StreamSubscription<Iterable<Season>>> _playerSeasonSubscriuption =
      {};
  TraceProxy _teamByPlayerTrace;

  TeamBloc(
      {@required this.coordinationBloc,
      @required this.playerBloc,
      @required this.clubBloc}) {
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
    _clubSub = clubBloc.state.listen((ClubState state) {
      if (state is ClubLoaded) {
        dispatch(_NewClubTeams(teams: state.teams));
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
  Future<void> _onPlayerSeasonUpdated(
      String playerUid, Iterable<Season> seasons) async {
    Set<String> toDeleteSeasons = new Set<String>();
    Map<String, String> seasonToTeam = {};

    _teamByPlayerTrace?.incrementCounter('season');

    // Build up the season to team mapping and the set to check for deletions.
    for (Team t in currentState.teamsByPlayer.values) {
      Club club;
      if (clubBloc.currentState.clubs.containsKey(t.clubUid)) {
        club = clubBloc.currentState.clubs[t.clubUid];
      }
      if (!t.isAdmin(club)) {
        Iterable<String> playerSeasons = currentState.seasons.keys.where(
            (String seasonUid) =>
                currentState.seasons[seasonUid].players
                    .any((SeasonPlayer p) => p.playerUid == playerUid) ||
                currentState.seasons[seasonUid].teamUid == t.uid);
        toDeleteSeasons.addAll(playerSeasons);
      }
    }

    // Create the new set.
    MapBuilder<String, Season> seasonMap = currentState.seasons.toBuilder();
    Map<String, TeamBuilder> teams = Map.fromEntries(
        currentState.teamsByPlayer.entries.map((MapEntry<String, Team> entry) =>
            MapEntry(entry.key, entry.value.toBuilder())));
    // Run through the seasons and update stuff.
    for (Season doc in seasons) {
      coordinationBloc.loadingTrace?.incrementCounter("team");
      _teamByPlayerTrace?.incrementCounter('team');
      // Get the team from the season.
      String teamUid = doc.teamUid;
      TeamBuilder tBuilder;
      if (teams.containsKey(teamUid)) {
        tBuilder = teams[teamUid];
        tBuilder.uid = teamUid;
      } else {
        // Get the data for the team itself.
        Stream<TeamBuilder> tb = coordinationBloc.databaseUpdateModel
            .getTeamDetails(
                teamUid: teamUid, userUid: coordinationBloc.currentState.uid);
        var first = Completer<TeamBuilder>();
        _teammDetailsSubscription[teamUid] = tb.listen((TeamBuilder b) {
          if (!first.isCompleted) {
            first.complete(b);
          } else {
            dispatch(_TeamBuilderUpdate(teamUid: teamUid, teamBuilder: b));
          }
        });
        tBuilder = await first.future;
      }

      teams[teamUid] = tBuilder;
      coordinationBloc.persistentData.updateElement(
          PersistenData.teamsTable, teamUid, tBuilder.build().toJSON());
      toDeleteSeasons.remove(doc.uid);
      if (!_teamOpponentSubscriuption.containsKey(teamUid)) {
        Stream<Iterable<Opponent>> str =
            coordinationBloc.databaseUpdateModel.getTeamOpponents(teamUid);
        _teamOpponentSubscriuption[teamUid] =
            str.listen((Iterable<Opponent> ops) {
          dispatch(_TeamOpponentsUpdate(teamUid: teamUid, newOpponents: ops));
        });
      }
      coordinationBloc.loadingTrace?.incrementCounter("playerTeam");
      seasonMap[doc.uid] = doc;
    }

    for (String deleteUid in toDeleteSeasons) {
      // Check and see if any current players need to be setup in here.
      TeamBuilder team = teams[seasonToTeam[deleteUid]];
      if (team != null) {
        bool overFound = false;
        for (String playerUid in playerBloc.currentState.players.keys) {
          overFound = overFound ||
              currentState.seasons[deleteUid].players
                  .any((SeasonPlayer p) => p.playerUid == playerUid);
        }
        if (!overFound) {
          _teamByPlayerTrace?.incrementCounter('deleteseason');
          // Remove the season.
          seasonMap.remove(deleteUid);
          coordinationBloc.persistentData
              .deleteElement(PersistenData.teamsTable, deleteUid);
        }
      }
    }

    var ret = MapBuilder<String, Team>();
    ret.addEntries(teams.entries.map((MapEntry<String, TeamBuilder> entry) =>
        MapEntry(entry.key, entry.value.build())));
    dispatch(_TeamPlayerSeasonUpdates(
        teamsByPlayer: ret.build(),
        playerUid: playerUid,
        seasons: seasonMap.build()));
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
    _clubSub?.cancel();
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
      MapBuilder<String, Opponent> opponents = MapBuilder();
      print(
          'Start teams ${coordinationBloc.start.difference(new DateTime.now())}');
      for (String uid in data.keys) {
        coordinationBloc.sqlTrace?.incrementCounter("team");
        teamsTrace.incrementCounter("team");
        Map<String, dynamic> input = data[uid];
        TeamBuilder team = Team.fromJSON(
            coordinationBloc.authenticationBloc.currentUser.uid, uid, input);

        // Load opponents.
        Map<String, Map<String, dynamic>> opponentData = await coordinationBloc
            .persistentData
            .getAllTeamElements(PersistenData.opponentsTable, uid);
        for (String key in opponentData.keys) {
          coordinationBloc.sqlTrace?.incrementCounter("opponent");
          teamsTrace.incrementCounter("opponent");
          Map<String, dynamic> innerData = opponentData[key];
          Opponent op = Opponent.fromJSON(key, uid, innerData).build();
          opponents[key] = op;
        }
        Team realTeam = team.build();
        Club club;
        if (clubBloc.currentState.clubs.containsKey(realTeam.clubUid)) {
          club = clubBloc.currentState.clubs[realTeam.clubUid];
        }
        if (realTeam.isAdmin(club)) {
          newAdminTeams[uid] = realTeam;
        } else {
          newTeams[uid] = realTeam;
        }
      }
      yield TeamLoaded(
          state: currentState,
          teamsByPlayer: BuiltMap.from(newTeams),
          adminTeams: BuiltMap.from(newAdminTeams),
          opponents: opponents.build(),
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
      Completer<Iterable<Team>> adminData = Completer();
      _adminTeamSub = initialState.listen((Iterable<Team> data) {
        if (!adminData.isCompleted) {
          adminData.complete(data);
        }
        dispatch(_TeamAdminUpdated(
            adminTeams:
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t)));
      });
      coordinationBloc.loadingTrace?.incrementCounter("teamAdmin");
      BuiltMap<String, Team> oldAdminTeams = currentState.adminTeams;
      Iterable<Team> startStuff = await adminData.future;
      yield TeamLoaded(
          state: currentState,
          adminTeams: BuiltMap.from(Map.fromIterable(startStuff,
              key: (t) => t.uid, value: (t) => t)));
      _onTeamAdminsUpdatePeristentData(oldAdminTeams, startStuff);

      adminTrace.stop();
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: false));
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
          state: currentState, adminTeams: BuiltMap.from(event.adminTeams));
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
            _playerSeasonSubscriuption[myUid] = coordinationBloc
                .databaseUpdateModel
                .getPlayerSeasons(myUid)
                .listen((Iterable<Season> seasons) async {
              _onPlayerSeasonUpdated(myUid, seasons);
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
          state: currentState,
          teamsByPlayer: event.teamsByPlayer,
          seasons: event.seasons,
          onlySql: false);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: false));
    }

    if (event is _TeamBuilderUpdate) {
      Team team = currentState.getTeam(event.teamUid);
      if (team != null) {
        // This is not an admin team, so keep the seasons and opponents.
        Map<String, Team> newTeams =
            Map.fromEntries(currentState.teamsByPlayer.entries);
        newTeams[event.teamUid] = event.teamBuilder.build();

        yield TeamLoaded(
            state: currentState, teamsByPlayer: BuiltMap.from(newTeams));
      }
    }

    if (event is _NewClubTeams) {
      // Loop ovewer the teams and do stuff.
      MapBuilder<String, BuiltMap<String, Team>> clubTeams = MapBuilder();
      for (MapEntry<String, Iterable<Team>> club in event.teams.entries) {
        MapBuilder<String, Team> teams = MapBuilder();
        for (Team t in club.value) {
          teams[t.uid] = t;
        }
        clubTeams[club.key] = teams.build();
      }
      yield TeamLoaded(state: currentState, clubTeams: clubTeams.build());
    }

    if (event is TeamLoadPublicTeam) {
      if (currentState.getPublicTeam(event.teamUid) == null) {
        Team t = await coordinationBloc.databaseUpdateModel
            .getPublicTeamDetails(
                userUid: coordinationBloc.authenticationBloc.currentUser.uid,
                teamUid: event.teamUid);
        MapBuilder<String, Team> publicStuff =
            currentState.publicTeams.toBuilder();
        publicStuff[event.teamUid] = t;
        yield TeamLoaded(state: currentState, publicTeams: publicStuff.build());
      }
    }
  }
}
