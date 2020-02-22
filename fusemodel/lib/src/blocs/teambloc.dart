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

  @override
  List<Object> get props => [uid];
}

class _TeamFirestoreStart extends TeamEvent {
  final String uid;

  _TeamFirestoreStart({@required this.uid});

  @override
  String toString() {
    return '_TeamFirestoreStart{}';
  }

  @override
  List<Object> get props => [uid];
}

class _TeamPlayersLoaded extends TeamEvent {
  final Iterable<Player> players;
  final bool onlySql;

  _TeamPlayersLoaded({@required this.players, @required this.onlySql});

  @override
  String toString() {
    return '_TeamPlayersLoaded{}';
  }

  @override
  List<Object> get props => [players, onlySql];
}

class _TeamLoggedOut extends TeamEvent {
  @override
  List<Object> get props => [];
}

class _TeamAdminUpdated extends TeamEvent {
  final Map<String, Team> adminTeams;

  _TeamAdminUpdated({@required this.adminTeams});

  @override
  List<Object> get props => [adminTeams];
}

class _TeamUserUpdated extends TeamEvent {
  final Map<String, Team> userTeams;

  _TeamUserUpdated({@required this.userTeams});

  @override
  List<Object> get props => [userTeams];
}

class _TeamOpponentsUpdate extends TeamEvent {
  final String teamUid;
  final Iterable<Opponent> newOpponents;

  _TeamOpponentsUpdate({@required this.teamUid, @required this.newOpponents});

  @override
  List<Object> get props => [teamUid, newOpponents];
}

class _NewClubTeams extends TeamEvent {
  final BuiltMap<String, Iterable<Team>> teams;

  _NewClubTeams({@required this.teams});

  @override
  List<Object> get props => [teams];
}

///
/// Loads the public details of this team.
///
class TeamLoadPublicTeam extends TeamEvent {
  final String teamUid;

  TeamLoadPublicTeam({@required this.teamUid});

  @override
  List<Object> get props => [teamUid];
}

///
/// Basic state for all the player states.
///
abstract class TeamState extends Equatable {
  final BuiltMap<String, Team> adminTeams;
  final BuiltMap<String, Team> playerTeams;
  final BuiltMap<String, BuiltMap<String, Team>> clubTeams;
  final BuiltMap<String, Team> publicTeams;
  final bool onlySql;

  TeamState(
      {@required this.playerTeams,
      @required this.onlySql,
      @required this.adminTeams,
      @required this.clubTeams,
      @required this.publicTeams});

  @override
  List<Object> get props =>
      [playerTeams, adminTeams, clubTeams, publicTeams, onlySql];

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
      bool onlySql})
      : super(
            playerTeams: teamsByPlayer ?? state.playerTeams,
            clubTeams: clubTeams ?? state.clubTeams,
            onlySql: onlySql ?? state.onlySql,
            publicTeams: publicTeams ?? state.publicTeams,
            adminTeams: adminTeams ?? state.adminTeams);

  @override
  String toString() {
    return 'TeamLoaded{playerTeams: ${playerTeams.length}, adminTeams: ${adminTeams.length}, clubTeams: ${clubTeams.length}, publicTeams: ${publicTeams}, onlySql: $onlySql}';
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

  TeamBloc({@required this.coordinationBloc, @required this.clubBloc}) {
    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        add(_TeamLoggedOut());
      } else if (coordState is CoordinationStateStartLoadingSql) {
        _startSqLoading(coordState);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    _clubSub = clubBloc.listen((ClubState state) {
      if (state is ClubLoaded) {
        add(_NewClubTeams(teams: state.teams));
      }
    });
  }

  void _startSqLoading(CoordinationStateStartLoadingSql state) {
    add(_TeamUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    add(_TeamFirestoreStart(uid: state.uid));
  }

  @override
  TeamState get initialState {
    return new TeamUninitialized();
  }

  void _cleanupSnaps() {
    _adminTeamSub?.cancel();
    _userTeamSub?.cancel();
  }

  @override
  Future<void> close() async {
    await super.close();
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
    if (newAdminTeams != null) {
      for (Team doc in newAdminTeams) {
        coordinationBloc.loadingTrace?.incrementCounter("adminTeam");
        coordinationBloc.persistentData
            .updateElement(PersistenData.teamsTable, doc.uid, doc.toJSON());
        toRemove.remove(doc.uid);
      }
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
        TeamBuilder team = Team.fromJSON(
            coordinationBloc.authenticationBloc.currentUser.uid, uid, input);

        Team realTeam = team.build();
        Club club;
        if (clubBloc.state.clubs.containsKey(realTeam.clubUid)) {
          club = clubBloc.state.clubs[realTeam.clubUid];
        }
        if (realTeam.isAdmin(club)) {
          newAdminTeams[uid] = realTeam;
        } else {
          newTeams[uid] = realTeam;
        }
      }
      yield TeamLoaded(
          state: state,
          teamsByPlayer: BuiltMap.from(newTeams),
          adminTeams: BuiltMap.from(newAdminTeams),
          onlySql: true);
      coordinationBloc.add(
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
        add(_TeamAdminUpdated(
            adminTeams:
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t)));
      });
      coordinationBloc.loadingTrace?.incrementCounter("teamAdmin");
      BuiltMap<String, Team> oldAdminTeams = state.adminTeams;
      BuiltMap<String, Team> oldUserTeams = state.playerTeams;
      Iterable<Team> adminStartStuff = await adminData.future;

      Stream<Iterable<Team>> userTeamStream =
          coordinationBloc.databaseUpdateModel.getTeams(event.uid);

      Completer<Iterable<Team>> userData = Completer();
      _userTeamSub?.cancel();
      _userTeamSub = userTeamStream.listen((Iterable<Team> data) {
        if (!userData.isCompleted) {
          userData.complete(data);
        }
        add(_TeamUserUpdated(
            userTeams:
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t)));
      });
      Iterable<Team> userStartStuff = await userData.future;

      print("TeamBlock loaded");

      yield TeamLoaded(
          state: state,
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
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: false));
    }

    // Unload everything.
    if (event is _TeamLoggedOut) {
      yield TeamUninitialized();
      _cleanupSnaps();
    }

    // Update just the admins.
    if (event is _TeamAdminUpdated) {
      BuiltMap<String, Team> oldAdminTeams = state.adminTeams;
      yield TeamLoaded(
          state: state, adminTeams: BuiltMap.from(event.adminTeams));
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: true));
      _onTeamAdminsUpdatePeristentData(
          oldTeams: oldAdminTeams,
          oldTeamsByPlayer: state.playerTeams,
          newAdminTeams: event.adminTeams.values);
    }

    if (event is _TeamUserUpdated) {
      _onTeamAdminsUpdatePeristentData(
          oldTeams: state.playerTeams,
          oldTeamsByPlayer: state.playerTeams,
          newPlayerTeam: event.userTeams.values);

      yield TeamLoaded(
          state: state, teamsByPlayer: BuiltMap.from(event.userTeams));
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
      yield TeamLoaded(state: state, clubTeams: clubTeams.build());
    }

    if (event is TeamLoadPublicTeam) {
      if (state.getPublicTeam(event.teamUid) == null) {
        Team t = await coordinationBloc.databaseUpdateModel
            .getPublicTeamDetails(
                userUid: coordinationBloc.authenticationBloc.currentUser.uid,
                teamUid: event.teamUid);
        MapBuilder<String, Team> publicStuff = state.publicTeams.toBuilder();
        publicStuff[event.teamUid] = t;
        yield TeamLoaded(state: state, publicTeams: publicStuff.build());
      }
    }
  }
}
