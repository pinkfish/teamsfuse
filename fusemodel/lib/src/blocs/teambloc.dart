import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'clubbloc.dart';
import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

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

class _TeamUserUpdated extends TeamEvent {
  final Map<String, Team> userTeams;

  _TeamUserUpdated({@required this.userTeams});
}

class _TeamOpponentsUpdate extends TeamEvent {
  final String teamUid;
  final Iterable<Opponent> newOpponents;

  _TeamOpponentsUpdate({@required this.teamUid, @required this.newOpponents});
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
  final BuiltMap<String, Team> playerTeams;
  final BuiltMap<String, BuiltMap<String, Team>> clubTeams;
  final BuiltMap<String, Team> publicTeams;
  final BuiltMap<String, Opponent> opponents;
  final bool onlySql;

  TeamState(
      {@required this.playerTeams,
      @required this.onlySql,
      @required this.opponents,
      @required this.adminTeams,
      @required this.clubTeams,
      @required this.publicTeams})
      : super([
          adminTeams,
          playerTeams,
          clubTeams,
          publicTeams,
          onlySql,
          opponents
        ]);

  ///
  /// Get the team from the various places it could exist.
  ///
  Team getTeam(String uid) {
    if (playerTeams.containsKey(uid)) {
      return playerTeams[uid];
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
    set.addAll(playerTeams.keys);
    return set;
  }
}

///
/// No data at all, we are uninitialized.
///
class TeamUninitialized extends TeamState {
  TeamUninitialized()
      : super(
            playerTeams: BuiltMap(),
            adminTeams: BuiltMap(),
            clubTeams: BuiltMap(),
            publicTeams: BuiltMap(),
            onlySql: true);

  @override
  String toString() {
    return 'TeamUninitialized{players: ${playerTeams.length}, onlySql: $onlySql}';
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
      BuiltMap<String, Opponent> opponents,
      bool onlySql})
      : super(
            playerTeams: teamsByPlayer ?? state.playerTeams,
            clubTeams: clubTeams ?? state.clubTeams,
            onlySql: onlySql ?? state.onlySql,
            publicTeams: publicTeams ?? state.publicTeams,
            adminTeams: adminTeams ?? state.adminTeams,
            opponents: opponents ?? state.opponents);

  @override
  String toString() {
    return 'TeamLoaded{playerTeams: ${playerTeams.length}, adminTeams: ${adminTeams.length}, clubTeams: ${clubTeams.length}, publicTeams: ${publicTeams}, onlySql: $onlySql} opponents: ${opponents.length}';
  }
}

///
/// Team bloc handles the teams flow.  Loading all the teams from
/// firestore.
///
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final CoordinationBloc coordinationBloc;
  final ClubBloc clubBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<Team>> _adminTeamSub;
  StreamSubscription<Iterable<Team>> _userTeamSub;
  Map<String, StreamSubscription<Iterable<Opponent>>>
      _teamOpponentSubscriuption = {};
  Map<String, StreamSubscription<TeamBuilder>> _teammDetailsSubscription = {};
  TraceProxy _teamByPlayerTrace;

  TeamBloc({@required this.coordinationBloc, @required this.clubBloc}) {
    _coordSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_TeamLoggedOut());
      } else if (state is CoordinationStateStartLoadingSql) {
        _startSqLoading(state);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(state);
      }
    });
    _clubSub = clubBloc.state.listen((ClubState state) {
      if (state is ClubLoaded) {
        dispatch(_NewClubTeams(teams: state.teams));
      }
    });
  }

  void _startSqLoading(CoordinationStateStartLoadingSql state) {
    dispatch(_TeamUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    dispatch(_TeamFirestoreStart(uid: state.uid));
  }

  @override
  TeamState get initialState {
    return new TeamUninitialized();
  }

  void _cleanupSnaps() {
    _adminTeamSub?.cancel();
    // Remove the updates in here...
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
    _userTeamSub?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupSnaps();
    _coordSub?.cancel();
    _clubSub?.cancel();
  }

  @override
  void onClubUpdated(FirestoreWrappedData data) {}

  void _onTeamAdminsUpdatePeristentData(
      {BuiltMap<String, Team> oldTeams,
      BuiltMap<String, Team> oldTeamsByPlayer,
      Iterable<Team> newAdminTeams,
      Iterable<Team> newPlayerTeam}) {
    Set<String> toRemove;
    if (newAdminTeams != null) {
      toRemove = Set.of(oldTeams.keys);
      toRemove.removeAll(oldTeamsByPlayer.keys);
    } else {
      toRemove = Set.of(oldTeamsByPlayer.keys);
      toRemove.removeAll(oldTeams.keys);
    }
    print('onTeamAdminsUpdated');

    for (Team doc in newAdminTeams) {
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
      Stream<Iterable<Team>> adminTeamStream =
          coordinationBloc.databaseUpdateModel.getTeamAdmins(event.uid);

      Completer<Iterable<Team>> adminData = Completer();
      _adminTeamSub?.cancel();
      _adminTeamSub = adminTeamStream.listen((Iterable<Team> data) {
        if (!adminData.isCompleted) {
          adminData.complete(data);
        }
        dispatch(_TeamAdminUpdated(
            adminTeams:
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t)));
      });
      coordinationBloc.loadingTrace?.incrementCounter("teamAdmin");
      BuiltMap<String, Team> oldAdminTeams = currentState.adminTeams;
      BuiltMap<String, Team> oldUserTeams = currentState.playerTeams;
      Iterable<Team> adminStartStuff = await adminData.future;

      Stream<Iterable<Team>> userTeamStream =
          coordinationBloc.databaseUpdateModel.getTeams(event.uid);

      Completer<Iterable<Team>> userData = Completer();
      _userTeamSub?.cancel();
      _userTeamSub = userTeamStream.listen((Iterable<Team> data) {
        if (!userData.isCompleted) {
          userData.complete(data);
        }
        dispatch(_TeamUserUpdated(
            userTeams:
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t)));
      });
      Iterable<Team> userStartStuff = await userData.future;

      print("TeamBlock loaded");

      yield TeamLoaded(
          state: currentState,
          onlySql: false,
          teamsByPlayer: BuiltMap.from(Map.fromIterable(userStartStuff,
              key: (t) => t.uid, value: (t) => t)),
          adminTeams: BuiltMap.from(Map.fromIterable(adminStartStuff,
              key: (t) => t.uid, value: (t) => t)));
      _onTeamAdminsUpdatePeristentData(
          oldTeams: oldAdminTeams,
          oldTeamsByPlayer: oldUserTeams,
          newAdminTeams: adminStartStuff);

      adminTrace.stop();
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: false));
    }

    // Unload everything.
    if (event is _TeamLoggedOut) {
      yield TeamUninitialized();
      _cleanupSnaps();
    }

    // Update just the admins.
    if (event is _TeamAdminUpdated) {
      BuiltMap<String, Team> oldAdminTeams = currentState.adminTeams;
      yield TeamLoaded(
          state: currentState, adminTeams: BuiltMap.from(event.adminTeams));
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: true));
      _onTeamAdminsUpdatePeristentData(
          oldTeams: oldAdminTeams,
          oldTeamsByPlayer: currentState.playerTeams,
          newAdminTeams: event.adminTeams.values);
    }

    if (event is _TeamUserUpdated) {
      _onTeamAdminsUpdatePeristentData(
          oldTeams: currentState.playerTeams,
          oldTeamsByPlayer: currentState.playerTeams,
          newPlayerTeam: event.userTeams.values);

      yield TeamLoaded(
          state: currentState, teamsByPlayer: BuiltMap.from(event.userTeams));
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
