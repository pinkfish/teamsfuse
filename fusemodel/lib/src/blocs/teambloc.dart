import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'clubbloc.dart';
import 'coordinationbloc.dart';
import 'data/clubblocstate.dart';
import 'data/teamblocstate.dart';
import 'internal/blocstoload.dart';

abstract class TeamEvent extends Equatable {}

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

class _TeamLoggedOut extends TeamEvent {
  @override
  List<Object> get props => [];
}

class _TeamAdminUpdated extends TeamEvent {
  final BuiltMap<String, Team> adminTeams;

  _TeamAdminUpdated({@required this.adminTeams});

  @override
  List<Object> get props => [adminTeams];
}

class _TeamUserUpdated extends TeamEvent {
  final BuiltMap<String, Team> userTeams;

  _TeamUserUpdated({@required this.userTeams});

  @override
  List<Object> get props => [userTeams];
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
/// Team bloc handles the teams flow.  Loading all the teams from
/// firestore.
///
class TeamBloc extends HydratedBloc<TeamEvent, TeamState> {
  final CoordinationBloc coordinationBloc;
  final ClubBloc clubBloc;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<Team>> _adminTeamSub;
  StreamSubscription<Iterable<Team>> _userTeamSub;

  bool _loadingFirestore = false;

  TeamBloc({@required this.coordinationBloc, @required this.clubBloc})
      : super(TeamUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Team));
    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_TeamLoggedOut());
      } else if (state is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;
          _startLoadingFirestore(coordState);
        }
      }
    });
    _clubSub = clubBloc.listen((ClubState state) {
      if (state is ClubLoaded) {
        add(_NewClubTeams(teams: state.teams));
      }
    });
  }

  void _startLoadingFirestore(CoordinationState state) {
    add(_TeamFirestoreStart(uid: state.uid));
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
            adminTeams: BuiltMap.of(
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t))));
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
            userTeams: BuiltMap.of(
                Map.fromIterable(data, key: (t) => t.uid, value: (t) => t))));
      });
      Iterable<Team> userStartStuff = await userData.future;

      print("TeamBlock loaded");

      yield (TeamLoaded.fromState(state)
            ..loadedFirestore = true
            ..playerTeams = MapBuilder(Map.fromIterable(userStartStuff,
                key: (t) => t.uid, value: (t) => t))
            ..adminTeams = MapBuilder(Map.fromIterable(adminStartStuff,
                key: (t) => t.uid, value: (t) => t)))
          .build();
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
      yield (TeamLoaded.fromState(state)
            ..adminTeams = event.adminTeams.toBuilder())
          .build();
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

      yield (TeamLoaded.fromState(state)
            ..playerTeams = event.userTeams.toBuilder())
          .build();
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
      yield (TeamLoaded.fromState(state)..clubTeams = clubTeams).build();
    }

    if (event is TeamLoadPublicTeam) {
      if (state.getPublicTeam(event.teamUid) == null) {
        Team t = await coordinationBloc.databaseUpdateModel
            .getPublicTeamDetails(
                userUid: coordinationBloc.authenticationBloc.currentUser.uid,
                teamUid: event.teamUid);
        MapBuilder<String, Team> publicStuff = state.publicTeams.toBuilder();
        publicStuff[event.teamUid] = t;
        yield (TeamLoaded.fromState(state)..publicTeams = publicStuff).build();
      }
    }
  }

  @override
  TeamState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return TeamUninitialized();
    }

    TeamBlocStateType type = TeamBlocStateType.valueOf(json["type"]);
    switch (type) {
      case TeamBlocStateType.Uninitialized:
        return TeamUninitialized();
      case TeamBlocStateType.Loaded:
        // Starting, nothing loaded yet.
        TraceProxy teamsTrace =
            coordinationBloc.analyticsSubsystem.newTrace("teamData");
        teamsTrace.start();
        print(
            'Start teams ${coordinationBloc.start.difference(new DateTime.now())}');
        coordinationBloc.add(
            CoordinationEventLoadedData(loaded: BlocsToLoad.Team, sql: true));
        var loaded = TeamLoaded.fromMap(json);
        teamsTrace.stop();
        return loaded;
      default:
        return TeamUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(TeamState state) {
    return state.toMap();
  }
}
