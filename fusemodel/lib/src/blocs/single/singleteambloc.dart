import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../clubbloc.dart';
import '../teambloc.dart';

abstract class SingleTeamState extends Equatable {
  final Team team;
  final Club club;
  final List<InviteAsAdmin> invitesAsAdmin;
  final List<Season> fullSeason;
  final Map<String, Opponent> opponents;

  SingleTeamState(
      {@required this.team,
      @required this.club,
      @required this.invitesAsAdmin,
      @required this.fullSeason,
      @required this.opponents});
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamState {
  SingleTeamLoaded(
      {@required SingleTeamState state,
      Team team,
      Club club,
      List<InviteAsAdmin> invitesAsAdmin,
      List<Season> fullSeason,
      Map<String, Opponent> opponents})
      : super(
            team: team ?? state.team,
            invitesAsAdmin: invitesAsAdmin ?? state.invitesAsAdmin,
            club: club ?? state.club,
            fullSeason: fullSeason ?? state.fullSeason,
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
            club: state.club,
            invitesAsAdmin: state.invitesAsAdmin,
            fullSeason: state.fullSeason,
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
            club: state.club,
            invitesAsAdmin: state.invitesAsAdmin,
            fullSeason: state.fullSeason,
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
            invitesAsAdmin: [],
            fullSeason: [],
            opponents: {},
            club: null);

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
/// Updates the club with this team.
///
class SingleTeamUpdateClub extends SingleTeamEvent {
  final String clubUid;

  SingleTeamUpdateClub({@required this.clubUid});
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

///
/// Loads the seasons from firebase.
///
class SingleTeamLoadAllSeasons extends SingleTeamEvent {
  SingleTeamLoadAllSeasons();
}

class _SingleTeamNewTeam extends SingleTeamEvent {
  final Team newTeam;

  _SingleTeamNewTeam({@required this.newTeam});
}

class _SingleTeamDeleted extends SingleTeamEvent {
  _SingleTeamDeleted();
}

class _SingleTeamInvitesAdminLoaded extends SingleTeamEvent {
  final Iterable<InviteAsAdmin> invites;

  _SingleTeamInvitesAdminLoaded({@required this.invites});
}

class _SingleTeamSeasonDataLoaded extends SingleTeamEvent {
  final Iterable<Season> seasons;

  _SingleTeamSeasonDataLoaded({@required this.seasons});
}

class _SingleTeamNewClub extends SingleTeamEvent {
  final Club club;

  _SingleTeamNewClub({@required this.club});
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamBloc extends Bloc<SingleTeamEvent, SingleTeamState> {
  final TeamBloc teamBloc;
  final ClubBloc clubBloc;
  final String teamUid;

  static String createNew = "new";

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteAdminSub;
  StreamSubscription<Iterable<Season>> _seasonSub;

  SingleTeamBloc(
      {@required this.teamBloc,
      @required this.clubBloc,
      @required this.teamUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null) {
        // Only send this if the team is not the same.
        if (team != currentState.team) {
          dispatch(_SingleTeamNewTeam(newTeam: team));
          _setupClubSub();
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
    _inviteAdminSub?.cancel();
    _seasonSub?.cancel();
    _clubSub?.cancel();
    _clubSub = null;
  }

  void _setupClubSub() {
    if (_clubSub == null) {
      if (clubBloc.currentState is ClubLoaded) {
        if (clubBloc.currentState.clubs
            .containsKey(currentState.team.clubUid)) {
          dispatch(_SingleTeamNewClub(
              club: clubBloc.currentState.clubs[currentState.team.clubUid]));
        }
      }
      _clubSub = clubBloc.state.listen((ClubState state) {
        if (state.clubs.containsKey(currentState.team.clubUid)) {
          Club club = state.clubs[currentState.team.clubUid];

          if (club != currentState.club) {
            dispatch(_SingleTeamNewClub(club: club));
          }
        } else {
          dispatch(_SingleTeamDeleted());
        }
      });
    }
  }

  @override
  SingleTeamState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null) {
      _setupClubSub();
      return SingleTeamLoaded(
          team: t,
          fullSeason: [],
          invitesAsAdmin: [],
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
          invitesAsAdmin: currentState.invitesAsAdmin);
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
              invitesAsAdmin: currentState.invitesAsAdmin);
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
              invitesAsAdmin: currentState.invitesAsAdmin);
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
            invitesAsAdmin: currentState.invitesAsAdmin);
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
            invitesAsAdmin: currentState.invitesAsAdmin);
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
            invitesAsAdmin: currentState.invitesAsAdmin);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is _SingleTeamInvitesAdminLoaded) {
      yield SingleTeamLoaded(
          state: currentState,
          team: currentState.team,
          invitesAsAdmin: event.invites);
    }

    if (event is SingleTeamLoadInvites) {
      if (_inviteAdminSub != null) {
        _inviteAdminSub = teamBloc.coordinationBloc.databaseUpdateModel
            .getInvitesForTeam(teamUid)
            .listen((Iterable<InviteAsAdmin> invites) {
          dispatch(_SingleTeamInvitesAdminLoaded(invites: invites));
        });
      }
    }

    if (event is SingleTeamLoadAllSeasons) {
      _seasonSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getAllSeasons(teamUid)
          .listen((Iterable<Season> seasons) {
        dispatch(_SingleTeamSeasonDataLoaded(seasons: seasons));
      });
    }

    if (event is _SingleTeamSeasonDataLoaded) {
      yield SingleTeamLoaded(state: currentState, fullSeason: event.seasons);
    }

    if (event is _SingleTeamNewClub) {
      yield SingleTeamLoaded(state: currentState, club: event.club);
    }

    if (event is SingleTeamUpdateClub) {
      Team myTeam =
          currentState.team.rebuild((b) => b..clubUid = event.clubUid);
      await teamBloc.coordinationBloc.databaseUpdateModel
          .updateFirestoreTeam(myTeam);
      yield SingleTeamLoaded(state: currentState, team: myTeam);
    }
  }
}
