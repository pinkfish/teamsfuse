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
    _coordSub = coordinationBloc.stream.listen((CoordinationState coordState) {
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
    _clubSub = clubBloc.stream.listen((ClubState state) {
      if (state is ClubLoaded) {
        add(_NewClubTeams(teams: state.teams));
      }
    });
  }

  ///
  /// Get the team from the team bloc.
  ///
  Team getTeam(String uid) {
    return state.getTeam(uid);
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
    await _coordSub?.cancel();
    await _clubSub?.cancel();
  }

  @override
  Stream<TeamState> mapEventToState(TeamEvent event) async* {
    // Start the firestore loading.
    if (event is _TeamFirestoreStart) {
      // Do the admin team loading thing.
      var adminTrace = coordinationBloc.analytics.newTrace('adminTeams');
      var adminTeamStream =
          coordinationBloc.databaseUpdateModel.getTeamAdmins();

      var adminData = Completer<Iterable<Team>>();
      await _adminTeamSub?.cancel();
      _adminTeamSub = adminTeamStream.listen((Iterable<Team> data) {
        if (!adminData.isCompleted) {
          adminData.complete(data);
        }
        add(_TeamAdminUpdated(
            adminTeams: BuiltMap.of({for (var t in data) t.uid: t})));
      });
      _adminTeamSub.onError((error, stack) {
        crashes.recordException(error, stack);
      });
      coordinationBloc.loadingTrace?.incrementCounter('teamAdmin');
      var adminStartStuff = await adminData.future;

      var userTeamStream = coordinationBloc.databaseUpdateModel.getTeams();

      var userData = Completer<Iterable<Team>>();
      await _userTeamSub?.cancel();
      _userTeamSub = userTeamStream.listen((Iterable<Team> data) {
        if (!userData.isCompleted) {
          userData.complete(data);
        }
        add(_TeamUserUpdated(
            userTeams: BuiltMap.of({for (var t in data) t.uid: t})));
      });
      var userStartStuff = await userData.future;

      yield (TeamLoaded.fromState(state)
            ..loadedFirestore = true
            ..playerTeams = MapBuilder({for (var t in userStartStuff) t.uid: t})
            ..adminTeams =
                MapBuilder({for (var t in adminStartStuff) t.uid: t}))
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
      var clubTeams = MapBuilder<String, BuiltMap<String, Team>>();
      for (var club in event.teams.entries) {
        var teams = MapBuilder<String, Team>();
        for (var t in club.value) {
          teams[t.uid] = t;
        }
        clubTeams[club.key] = teams.build();
      }
      yield (TeamLoaded.fromState(state)..clubTeams = clubTeams).build();
    }

    if (event is TeamLoadPublicTeam) {
      if (state.getPublicTeam(event.teamUid) == null) {
        var t = await coordinationBloc.databaseUpdateModel
            .getPublicTeamDetails(teamUid: event.teamUid)
            .first;
        var publicStuff = state.publicTeams.toBuilder();
        publicStuff[event.teamUid] = t;
        yield (TeamLoaded.fromState(state)..publicTeams = publicStuff).build();
      }
    }
  }

  @override
  TeamState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey('type')) {
      return TeamUninitialized();
    }

    var type = TeamBlocStateType.valueOf(json['type']);
    switch (type) {
      case TeamBlocStateType.Uninitialized:
        return TeamUninitialized();
      case TeamBlocStateType.Loaded:
        try {
          // Starting, nothing loaded yet.
          var teamsTrace = coordinationBloc.analytics.newTrace('teamData');
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
