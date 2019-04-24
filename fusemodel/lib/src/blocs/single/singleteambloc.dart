import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'teambloc.dart';

abstract class SingleTeamState extends Equatable {
  final Team team;
  final List<InviteAsAdmin> invites;
  final List<Season> fullSeason;
  final Map<String, Iterable<Game>> allGames;
  final Map<String, Opponent> opponents;

  SingleTeamState(
      {@required this.team,
      @required this.invites,
      @required this.fullSeason,
      @required this.allGames,
      @required this.opponents});
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamState {
  SingleTeamLoaded(
      {@required SingleTeamState state,
      Team team,
      List<InviteAsAdmin> invites,
      List<Season> fullSeason,
      Map<String, Iterable<Game>> allGames,
      Map<String, Opponent> opponents})
      : super(
            team: team ?? state.team,
            invites: invites ?? state.invites,
            fullSeason: fullSeason ?? state.fullSeason,
            allGames: allGames ?? state.allGames,
            opponents: opponents ?? state.opponents);

  @override
  String toString() {
    return 'SingleTeamLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSaving extends SingleTeamState {
  SingleTeamSaving({@required SingleTeamState state})
      : super(
            team: state.team,
            invites: state.invites,
            fullSeason: state.fullSeason,
            allGames: state.allGames,
            opponents: state.opponents);

  @override
  String toString() {
    return 'SingleTeamSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSaveFailed extends SingleTeamState {
  final Error error;

  SingleTeamSaveFailed({@required SingleTeamState state, @required this.error})
      : super(
            team: state.team,
            invites: state.invites,
            fullSeason: state.fullSeason,
            allGames: state.allGames,
            opponents: state.opponents);

  @override
  String toString() {
    return 'SingleTeamSaveFailed{}';
  }
}

///
/// Team got deleted.
///
class SingleTeamDeleted extends SingleTeamState {
  SingleTeamDeleted()
      : super(
            team: null,
            invites: [],
            fullSeason: [],
            allGames: {},
            opponents: {});

  @override
  String toString() {
    return 'SingleTeamDeleted{}';
  }
}

abstract class SingleTeamEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamUpdate extends SingleTeamEvent {
  final TeamBuilder team;

  SingleTeamUpdate({@required this.team});
}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamAdd extends SingleTeamEvent {
  final TeamBuilder newTeam;
  final SeasonBuilder newSeason;

  SingleTeamAdd({@required this.newTeam, @required this.newSeason});
}

///
/// Updates the image for the team.
///
class SingleTeamUpdateImage extends SingleTeamEvent {
  final File image;

  SingleTeamUpdateImage({@required this.image});
}

///
/// Adds an admin to the team.
///
class SingleTeamAddAdmin extends SingleTeamEvent {
  final String adminUid;

  SingleTeamAddAdmin({@required this.adminUid});
}

///
/// Deletes an admin from the team.
///
class SingleTeamDeleteAdmin extends SingleTeamEvent {
  final String adminUid;

  SingleTeamDeleteAdmin({@required this.adminUid});
}

///
/// Invites someone to be an admin for this team.
///
class SingleTeamInviteAdmin extends SingleTeamEvent {
  final String email;

  SingleTeamInviteAdmin({@required this.email});
}

///
/// Delete this team from the world.
///
class SingleTeamDelete extends SingleTeamEvent {
  SingleTeamDelete();
}

///
/// Loads the invites from firebase.
///
class SingleTeamLoadInvites extends SingleTeamEvent {
  SingleTeamLoadInvites();
}

class _SingleTeamNewTeam extends SingleTeamEvent {
  final Team newTeam;

  _SingleTeamNewTeam({@required this.newTeam});
}

class _SingleTeamDeleted extends SingleTeamEvent {
  _SingleTeamDeleted();
}

class _SingleTeamInvitesAdded extends SingleTeamEvent {
  final Iterable<InviteAsAdmin> invites;

  _SingleTeamInvitesAdded({@required this.invites});
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamBloc extends Bloc<SingleTeamEvent, SingleTeamState> {
  final TeamBloc teamBloc;
  final String teamUid;

  static String createNew = "new";

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteSub;

  SingleTeamBloc({@required this.teamBloc, @required this.teamUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null) {
        // Only send this if the team is not the same.
        if (team != currentState.team) {
          dispatch(_SingleTeamNewTeam(newTeam: team));
        }
      } else {
        dispatch(_SingleTeamDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _teamSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  SingleTeamState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null) {
      return SingleTeamLoaded(
          team: t,
          allGames: {},
          fullSeason: [],
          invites: [],
          opponents: {},
          state: null);
    } else {
      return SingleTeamDeleted();
    }
  }

  @override
  Stream<SingleTeamState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      yield SingleTeamLoaded(
          state: currentState,
          team: event.newTeam,
          invites: currentState.invites);
    }

    // The team is deleted.
    if (event is _SingleTeamDeleted) {
      yield SingleTeamDeleted();
    }

    // Save the team.
    if (event is SingleTeamUpdate) {
      yield SingleTeamSaving(state: currentState);
      if (currentState.team.publicOnly) {
        yield SingleTeamSaveFailed(
            state: currentState,
            error: ArgumentError("Cannot save a public team"));
      } else {
        try {
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateFirestoreTeam(event.team.build());
          yield SingleTeamLoaded(
              state: currentState,
              team: event.team.build(),
              invites: currentState.invites);
        } catch (e) {
          yield SingleTeamSaveFailed(state: currentState, error: e);
        }
      }
    }

    // Create a new team.
    if (event is SingleTeamAdd) {
      yield SingleTeamSaving(state: currentState);
      if (currentState.team.publicOnly) {
        yield SingleTeamSaveFailed(
            state: currentState,
            error: ArgumentError("Cannot save a public team"));
      } else {
        try {
          var pregenTeam =
              teamBloc.coordinationBloc.databaseUpdateModel.precreateTeamUid();
          var pregenSeason = teamBloc.coordinationBloc.databaseUpdateModel
              .precreateUidSeason();
          event.newSeason.uid = pregenSeason.documentID;
          event.newSeason.teamUid = pregenTeam.documentID;
          event.newTeam.uid = pregenTeam.documentID;
          event.newTeam.currentSeason = pregenSeason.documentID;
          event.newTeam.seasons[pregenSeason.documentID] =
              event.newSeason.build();

          Team updatedTeam = event.newTeam.build();
          await teamBloc.coordinationBloc.databaseUpdateModel
              .addFirestoreTeam(event.newTeam.build(), pregenTeam);
          await teamBloc.coordinationBloc.databaseUpdateModel
              .addFirestoreSeason(event.newSeason.build(), pregenSeason);
          yield SingleTeamLoaded(
              state: currentState,
              team: updatedTeam,
              invites: currentState.invites);
        } catch (e) {
          yield SingleTeamSaveFailed(state: currentState, error: e);
        }
      }
    }

    if (event is SingleTeamAddAdmin) {
      yield SingleTeamSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .addAdmin(teamUid, event.adminUid);
        yield SingleTeamLoaded(
            state: currentState,
            team: currentState.team,
            invites: currentState.invites);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamDeleteAdmin) {
      yield SingleTeamSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .deleteAdmin(currentState.team, event.adminUid);
        yield SingleTeamLoaded(
            state: currentState,
            team: currentState.team,
            invites: currentState.invites);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamInviteAdmin) {
      yield SingleTeamSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel.inviteAdminToTeam(
            teamUid: currentState.team.uid,
            email: event.email,
            teamName: currentState.team.name);
        yield SingleTeamLoaded(
            state: currentState,
            team: currentState.team,
            invites: currentState.invites);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is _SingleTeamInvitesAdded) {
      yield SingleTeamLoaded(
          state: currentState, team: currentState.team, invites: event.invites);
    }

    if (event is SingleTeamLoadInvites) {
      _inviteSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getInvitesForTeam(teamUid)
          .listen((Iterable<InviteAsAdmin> invites) {
        dispatch(_SingleTeamInvitesAdded(invites: invites));
      });
    }
  }
}
