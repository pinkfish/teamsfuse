import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../clubbloc.dart';
import '../seasonbloc.dart';
import '../teambloc.dart';

///
/// The basic team state for this team.
///
abstract class SingleTeamState extends Equatable {
  final Team team;
  final Club club;
  final BuiltList<InviteAsAdmin> invitesAsAdmin;
  final BuiltList<Season> fullSeason;
  final BuiltMap<String, Opponent> opponents;

  SingleTeamState(
      {@required this.team,
      @required this.club,
      @required this.invitesAsAdmin,
      @required this.fullSeason,
      @required this.opponents})
      : super([team, club, invitesAsAdmin, fullSeason, opponents]);

  ///
  /// Gets the specified sweason.
  ///
  Season getSeason(String uid) {
    return fullSeason.firstWhere((Season s) => s.uid == uid,
        orElse: () => null);
  }

  ///
  /// Checks to see if the user is an admin for this team.
  ///
  bool isAdmin() {
    return team.isAdmin(club);
  }
}

///
/// We have a team, default state.
///
class SingleTeamLoaded extends SingleTeamState {
  SingleTeamLoaded(
      {@required SingleTeamState state,
      Team team,
      Club club,
      BuiltList<InviteAsAdmin> invitesAsAdmin,
      BuiltList<Season> fullSeason,
      BuiltMap<String, Opponent> opponents})
      : super(
            team: team ?? state.team,
            invitesAsAdmin: invitesAsAdmin ?? state.invitesAsAdmin,
            club: club ?? state?.club,
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
/// Saving operation is done.
///
class SingleTeamSaveDone extends SingleTeamState {
  SingleTeamSaveDone({@required SingleTeamState state})
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
            invitesAsAdmin: BuiltList(),
            fullSeason: BuiltList(),
            opponents: BuiltMap(),
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
  final File image;

  SingleTeamUpdate({@required this.team, this.image});
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

///
/// Change the archive bit for this team
///
class SingleTeamArchive extends SingleTeamEvent {
  final bool archive;

  SingleTeamArchive({@required this.archive});
}

class _SingleTeamNewTeam extends SingleTeamEvent {
  final Team newTeam;
  final BuiltMap<String, Opponent> opponents;
  final BuiltList<Season> seasons;

  _SingleTeamNewTeam(
      {@required this.newTeam,
      @required this.opponents,
      @required this.seasons});
}

class _SingleTeamNewSeasons extends SingleTeamEvent {
  final BuiltList<Season> seasons;

  _SingleTeamNewSeasons({@required this.seasons});
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

class _SingleTeamNoClub extends SingleTeamEvent {
  _SingleTeamNoClub();
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamBloc extends Bloc<SingleTeamEvent, SingleTeamState> {
  final TeamBloc teamBloc;
  final ClubBloc clubBloc;
  final SeasonBloc seasonBloc;
  final String teamUid;

  static String createNew = "new";

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<ClubState> _clubSub;
  StreamSubscription<SeasonState> _seasonStateSub;
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteAdminSub;
  StreamSubscription<Iterable<Season>> _seasonSub;

  SingleTeamBloc(
      {@required this.teamBloc,
      @required this.clubBloc,
      @required this.seasonBloc,
      @required this.teamUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null) {
        // Only send this if the team is not the same.
        var builder = MapBuilder<String, Opponent>();
        builder.addEntries(state.opponents.entries.where(
            (MapEntry<String, Opponent> op) => op.value.teamUid == team.uid));
        dispatch(
          _SingleTeamNewTeam(
            newTeam: team,
            opponents: builder.build(),
          ),
        );
        _setupClubSub();
      } else {
        print('Deleted team $teamUid');
        dispatch(_SingleTeamDeleted());
      }
    });
    _seasonStateSub = seasonBloc.state.listen(((SeasonState state) {
      dispatch(
        _SingleTeamNewSeasons(
          seasons: BuiltList.of(
              state.seasons.values.where((Season s) => s.teamUid == teamUid)),
        ),
      );
    }));
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
        Team t = teamBloc.currentState.getTeam(teamUid);
        if (t.clubUid != null &&
            clubBloc.currentState.clubs.containsKey(t.clubUid)) {
          dispatch(
              _SingleTeamNewClub(club: clubBloc.currentState.clubs[t.clubUid]));
        }
      }
      _clubSub = clubBloc.state.listen((ClubState state) {
        Team t = teamBloc.currentState.getTeam(teamUid);
        if (t.clubUid != null && state.clubs.containsKey(t.clubUid)) {
          Club club = state.clubs[t.clubUid];

          if (club != currentState.club) {
            dispatch(_SingleTeamNewClub(club: club));
          }
        } else {
          dispatch(_SingleTeamNoClub());
        }
      });
    }
  }

  @override
  SingleTeamState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null) {
      _setupClubSub();
      Club club = clubBloc.currentState.clubs[t.clubUid];

      return SingleTeamLoaded(
          team: t,
          club: club,
          fullSeason: BuiltList(),
          invitesAsAdmin: BuiltList(),
          opponents: BuiltMap(),
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
          if (event.image != null) {
            await teamBloc.coordinationBloc.databaseUpdateModel
                .updateTeamImage(teamUid, event.image);
          }
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateFirestoreTeam(event.team.build());
          yield SingleTeamSaveDone(state: currentState);
          yield SingleTeamLoaded(state: currentState, team: event.team.build());
        } catch (e) {
          yield SingleTeamSaveFailed(state: currentState, error: e);
        }
      }
    }

    // Save the team image.
    if (event is SingleTeamUpdateImage) {
      yield SingleTeamSaving(state: currentState);
      if (currentState.team.publicOnly) {
        yield SingleTeamSaveFailed(
            state: currentState,
            error: ArgumentError("Cannot save a public team"));
      } else {
        try {
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateTeamImage(teamUid, event.image);
          yield SingleTeamSaveDone(state: currentState);
          yield SingleTeamLoaded(state: currentState);
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
        yield SingleTeamSaveDone(state: currentState);
        yield SingleTeamLoaded(state: currentState);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamDeleteAdmin) {
      yield SingleTeamSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .deleteAdmin(currentState.team, event.adminUid);
        yield SingleTeamSaveDone(state: currentState);
        yield SingleTeamLoaded(state: currentState);
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
        yield SingleTeamSaveDone(state: currentState);
        yield SingleTeamLoaded(state: currentState);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is _SingleTeamInvitesAdminLoaded) {
      yield SingleTeamLoaded(
          state: currentState, invitesAsAdmin: BuiltList.from(event.invites));
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
          .getSeasonsForTeam(teamUid)
          .listen((Iterable<Season> seasons) {
        dispatch(_SingleTeamSeasonDataLoaded(seasons: seasons));
      });
    }

    if (event is _SingleTeamNewSeasons) {
      yield SingleTeamLoaded(fullSeason: event.seasons, state: currentState);
    }

    if (event is _SingleTeamSeasonDataLoaded) {
      yield SingleTeamLoaded(
          state: currentState, fullSeason: BuiltList.from(event.seasons));
    }

    if (event is _SingleTeamNewClub) {
      yield SingleTeamLoaded(state: currentState, club: event.club);
    }

    if (event is _SingleTeamNoClub) {
      yield SingleTeamLoaded(state: currentState, club: null);
    }

    if (event is SingleTeamUpdateClub) {
      try {
        Team myTeam =
            currentState.team.rebuild((b) => b..clubUid = event.clubUid);
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreTeam(myTeam);
        yield SingleTeamSaveDone(state: currentState);
        yield SingleTeamLoaded(state: currentState, team: myTeam);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamArchive) {
      try {
        Team myTeam =
            currentState.team.rebuild((b) => b..archived = event.archive);
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreTeam(myTeam);
        yield SingleTeamSaveDone(state: currentState);
        yield SingleTeamLoaded(state: currentState, team: myTeam);
      } catch (e) {
        yield SingleTeamSaveFailed(state: currentState, error: e);
      }
    }
  }
}
