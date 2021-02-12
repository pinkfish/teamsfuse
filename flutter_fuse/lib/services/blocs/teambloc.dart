import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'clubbloc.dart';
import 'coordinationbloc.dart';
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
  final AnalyticsSubsystem crashes;

  StreamSubscription<CoordinationState> _coordSub;
  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<Team>> _adminTeamSub;
  StreamSubscription<Iterable<Team>> _userTeamSub;

  bool _loadingFirestore = false;

  TeamBloc(
      {@required this.coordinationBloc,
      @required this.clubBloc,
      @required this.crashes})
      : super(TeamUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Team));
    _coordSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_TeamLoggedOut());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
    _clubSub = clubBloc.listen((ClubState state) {
      if (state is ClubLoaded) {
        add(_NewClubTeams(teams: state.teams));
      }
    });
  }

  void _startLoadingFirestore(CoordinationState state) {
    if (!_loadingFirestore) {
      _loadingFirestore = true;
      add(_TeamFirestoreStart(uid: state.uid));
    }
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
  Stream<TeamState> mapEventToState(TeamEvent event) async* {
    // Start the firestore loading.
    if (event is _TeamFirestoreStart) {
      // Do the admin team loading thing.
      TraceProxy adminTrace = coordinationBloc.analytics.newTrace('adminTeams');
      Stream<Iterable<Team>> adminTeamStream =
          coordinationBloc.databaseUpdateModel.getTeamAdmins();

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
      _adminTeamSub.onError((e) {
        print("Failed to get teams $e");
      });
      coordinationBloc.loadingTrace?.incrementCounter("teamAdmin");
      Iterable<Team> adminStartStuff = await adminData.future;

      Stream<Iterable<Team>> userTeamStream =
          coordinationBloc.databaseUpdateModel.getTeams();

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


      yield (TeamLoaded.fromState(state)
            ..loadedFirestore = true
            ..playerTeams = MapBuilder(Map.fromIterable(userStartStuff,
                key: (t) => t.uid, value: (t) => t))
            ..adminTeams = MapBuilder(Map.fromIterable(adminStartStuff,
                key: (t) => t.uid, value: (t) => t)))
          .build();

      adminTrace.stop();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Team));
    }

    // Unload everything.
    if (event is _TeamLoggedOut) {
      yield TeamUninitialized();
      _cleanupSnaps();
    }

    // Update just the admins.
    if (event is _TeamAdminUpdated) {
      yield (TeamLoaded.fromState(state)
            ..adminTeams = event.adminTeams.toBuilder())
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Team));
    }

    if (event is _TeamUserUpdated) {
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
            .getPublicTeamDetails(teamUid: event.teamUid)
            .first;
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
        try {
          // Starting, nothing loaded yet.
          TraceProxy teamsTrace =
              coordinationBloc.analyticsSubsystem.newTrace("teamData");
          teamsTrace.start();
           var loaded = TeamLoaded.fromMap(json);
          teamsTrace.stop();
          return loaded;
        } catch (e, stack) {
          if (e is Error) {
            crashes.recordError(e, stack);
          } else {
            crashes.recordException(e, stack);
          }
        }
        return TeamUninitialized();
      default:
        return TeamUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(TeamState state) {
    return state.toMap();
  }
}
