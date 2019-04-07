import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'teambloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'dart:io';

abstract class SingleTeamState extends Equatable {
  final String teamUid;
  final Team team;
  final List<InviteAsAdmin> invites;
  final List<Season> fullSeason;
  final Map<String, Iterable<Game>> allGames;
  final Map<String, Opponent> opponents;

  SingleTeamState(
      {@required this.teamUid,
      @required this.team,
      @required this.invites,
      this.fullSeason,
      this.allGames,
      this.opponents});
}

///
/// Nothing happened for this team yet.
///
class SingleTeamUninitalized extends SingleTeamState {
  SingleTeamUninitalized({@required String teamUid})
      : super(teamUid: teamUid, team: null);
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamState {
  SingleTeamLoaded(
      {@required String teamUid,
      @required Team team,
      @required List<InviteAsAdmin> invites})
      : super(teamUid: teamUid, team: team, invites: invites);

  @override
  String toString() {
    return 'SingleTeamLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSaving extends SingleTeamState {
  SingleTeamSaving(
      {@required String teamUid,
      @required Team team,
      @required List<InviteAsAdmin> invites})
      : super(teamUid: teamUid, team: team, invites: invites);

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

  SingleTeamSaveFailed(
      {@required String teamUid,
      @required Team team,
      this.error,
      @required List<InviteAsAdmin> invites})
      : super(teamUid: teamUid, team: team, invites: invites);

  @override
  String toString() {
    return 'SingleTeamSaveFailed{}';
  }
}

///
/// Team got deleted.
///
class SingleTeamDeleted extends SingleTeamState {
  SingleTeamDeleted(
      {@required String teamUid,
      @required Team team,
      @required List<InviteAsAdmin> invites})
      : super(teamUid: teamUid, team: team, invites: invites);

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

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteSub;

  SingleTeamBloc(this.teamBloc, this.teamUid) {
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
  SingleTeamState get initialState => SingleTeamUninitalized(teamUid: teamUid);

  @override
  Stream<SingleTeamState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      yield SingleTeamLoaded(
          teamUid: teamUid, team: event.newTeam, invites: currentState.invites);
    }

    // The team is deleted.
    if (event is _SingleTeamDeleted) {
      yield SingleTeamDeleted(
          teamUid: teamUid,
          team: currentState.team,
          invites: currentState.invites);
    }

    // Save the team.
    if (event is SingleTeamUpdate) {
      yield SingleTeamSaving(
          teamUid: currentState.teamUid, team: currentState.team);
      if (currentState.team.publicOnly) {
        yield SingleTeamSaveFailed(
            teamUid: currentState.teamUid,
            team: currentState.team,
            invites: currentState.invites,
            error: ArgumentError("Cannot save a public team"));
      } else {
        try {
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateFirestoreTeam(event.team.build());
          yield SingleTeamLoaded(
              teamUid: teamUid,
              team: event.team.build(),
              invites: currentState.invites);
        } catch (e) {
          yield SingleTeamSaveFailed(
              teamUid: currentState.teamUid,
              team: currentState.team,
              invites: currentState.invites,
              error: e);
        }
      }
    }

    // Create a new team.
    if (event is SingleTeamAdd) {
      yield SingleTeamSaving(
          teamUid: currentState.teamUid, team: currentState.team);
      if (currentState.team.publicOnly) {
        yield SingleTeamSaveFailed(
            teamUid: currentState.teamUid,
            team: currentState.team,
            invites: currentState.invites,
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
              teamUid: updatedTeam.uid,
              team: updatedTeam,
              invites: currentState.invites);
        } catch (e) {
          yield SingleTeamSaveFailed(
              teamUid: currentState.teamUid,
              team: currentState.team,
              invites: currentState.invites,
              error: e);
        }
      }
    }

    if (event is SingleTeamAddAdmin) {
      yield SingleTeamSaving(
          teamUid: currentState.teamUid,
          team: currentState.team,
          invites: currentState.invites);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .addAdmin(currentState.teamUid, event.adminUid);
        yield SingleTeamLoaded(
            teamUid: teamUid,
            team: currentState.team,
            invites: currentState.invites);
      } catch (e) {
        yield SingleTeamSaveFailed(
            teamUid: currentState.teamUid,
            team: currentState.team,
            invites: currentState.invites,
            error: e);
      }
    }

    if (event is SingleTeamDeleteAdmin) {
      yield SingleTeamSaving(
          teamUid: currentState.teamUid,
          team: currentState.team,
          invites: currentState.invites);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .deleteAdmin(currentState.team, event.adminUid);
        yield SingleTeamLoaded(
            teamUid: teamUid,
            team: currentState.team,
            invites: currentState.invites);
      } catch (e) {
        yield SingleTeamSaveFailed(
            teamUid: currentState.teamUid,
            team: currentState.team,
            invites: currentState.invites,
            error: e);
      }
    }

    if (event is SingleTeamInviteAdmin) {
      yield SingleTeamSaving(
          teamUid: currentState.teamUid,
          team: currentState.team,
          invites: currentState.invites);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .inviteAdminToTeam(currentState.team, event.email);
        yield SingleTeamLoaded(
            teamUid: teamUid,
            team: currentState.team,
            invites: currentState.invites);
      } catch (e) {
        yield SingleTeamSaveFailed(
            teamUid: currentState.teamUid,
            team: currentState.team,
            invites: currentState.invites,
            error: e);
      }
    }

    if (event is _SingleTeamInvitesAdded) {
      yield SingleTeamLoaded(
          teamUid: currentState.teamUid,
          team: currentState.team,
          invites: event.invites);
    }

    if (event is SingleTeamLoadInvites) {
      _inviteSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getInvitesForTeam(currentState.teamUid)
          .listen((Iterable<InviteAsAdmin> invites) {
        dispatch(_SingleTeamInvitesAdded(invites: invites));
      });
    }
  }
}
