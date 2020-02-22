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
  final bool loadedOpponents;
  final bool loadedSeasons;

  SingleTeamState(
      {@required this.team,
      @required this.club,
      @required this.invitesAsAdmin,
      @required this.fullSeason,
      @required this.opponents,
      @required this.loadedOpponents,
      @required this.loadedSeasons});

  @override
  List<Object> get props => [
        team,
        club,
        invitesAsAdmin,
        fullSeason,
        opponents,
        loadedOpponents,
        loadedSeasons,
      ];

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
      BuiltMap<String, Opponent> opponents,
      bool loadedOpponents,
      bool loadedSeasons})
      : super(
            team: team ?? state.team,
            invitesAsAdmin: invitesAsAdmin ?? state.invitesAsAdmin,
            club: club ?? state?.club,
            fullSeason: fullSeason ?? state.fullSeason,
            opponents: opponents ?? state.opponents,
            loadedOpponents: loadedOpponents ?? state.loadedOpponents,
            loadedSeasons: loadedSeasons ?? state.loadedSeasons);

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
            opponents: state.opponents,
            loadedOpponents: state.loadedOpponents,
            loadedSeasons: state.loadedSeasons);

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
            opponents: state.opponents,
            loadedOpponents: state.loadedOpponents,
            loadedSeasons: state.loadedSeasons);

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
            opponents: state.opponents,
            loadedOpponents: state.loadedOpponents,
            loadedSeasons: state.loadedSeasons);

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
            club: null,
            loadedOpponents: false,
            loadedSeasons: false);

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

  @override
  List<Object> get props => [team, image];
}

///
/// Updates the image for the team.
///
class SingleTeamUpdateImage extends SingleTeamEvent {
  final File image;

  SingleTeamUpdateImage({@required this.image});

  @override
  List<Object> get props => [image];
}

///
/// Adds an admin to the team.
///
class SingleTeamAddAdmin extends SingleTeamEvent {
  final String adminUid;

  SingleTeamAddAdmin({@required this.adminUid});

  @override
  List<Object> get props => [adminUid];
}

///
/// Deletes an admin from the team.
///
class SingleTeamDeleteAdmin extends SingleTeamEvent {
  final String adminUid;

  SingleTeamDeleteAdmin({@required this.adminUid});

  @override
  List<Object> get props => [adminUid];
}

///
/// Updates the club with this team.
///
class SingleTeamUpdateClub extends SingleTeamEvent {
  final String clubUid;

  SingleTeamUpdateClub({@required this.clubUid});

  @override
  List<Object> get props => [clubUid];
}

///
/// Invites someone to be an admin for this team.
///
class SingleTeamInviteAdmin extends SingleTeamEvent {
  final String email;

  SingleTeamInviteAdmin({@required this.email});

  @override
  List<Object> get props => [email];
}

///
/// Delete this team from the world.
///
class SingleTeamDelete extends SingleTeamEvent {
  SingleTeamDelete();

  @override
  List<Object> get props => [];
}

///
/// Loads the invites from firebase.
///
class SingleTeamLoadInvites extends SingleTeamEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the seasons from firebase.
///
class SingleTeamLoadAllSeasons extends SingleTeamEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads all the opponents for this team.
///
class SingleTeamLoadOpponents extends SingleTeamEvent {
  @override
  List<Object> get props => [];
}

///
/// Change the archive bit for this team
///
class SingleTeamArchive extends SingleTeamEvent {
  final bool archive;

  SingleTeamArchive({@required this.archive});

  @override
  List<Object> get props => [archive];
}

///
/// Add an opponent to the team.
///
class SingleTeamAddOpponent extends SingleTeamEvent {
  final Opponent opponent;

  SingleTeamAddOpponent({this.opponent});

  @override
  List<Object> get props => [opponent];
}

class _SingleTeamNewTeam extends SingleTeamEvent {
  final Team newTeam;
  final BuiltMap<String, Opponent> opponents;
  final BuiltList<Season> seasons;

  _SingleTeamNewTeam(
      {@required this.newTeam,
      @required this.opponents,
      @required this.seasons});

  @override
  List<Object> get props => [newTeam, opponents, seasons];
}

class _SingleTeamNewSeasons extends SingleTeamEvent {
  final BuiltList<Season> seasons;

  _SingleTeamNewSeasons({@required this.seasons});

  @override
  List<Object> get props => [seasons];
}

class _SingleTeamDeleted extends SingleTeamEvent {
  @override
  List<Object> get props => [];
}

class _SingleTeamInvitesAdminLoaded extends SingleTeamEvent {
  final Iterable<InviteAsAdmin> invites;

  _SingleTeamInvitesAdminLoaded({@required this.invites});

  @override
  List<Object> get props => [invites];
}

class _SingleTeamSeasonDataLoaded extends SingleTeamEvent {
  final Iterable<Season> seasons;
  final bool fullUpdate;

  _SingleTeamSeasonDataLoaded(
      {@required this.seasons, @required this.fullUpdate});

  @override
  List<Object> get props => [seasons, fullUpdate];
}

class _SingleTeamNewClub extends SingleTeamEvent {
  final Club club;

  _SingleTeamNewClub({@required this.club});

  @override
  List<Object> get props => [club];
}

class _SingleTeamNoClub extends SingleTeamEvent {
  @override
  List<Object> get props => [];
}

class _SingleTeamLoadedOpponents extends SingleTeamEvent {
  final BuiltMap<String, Opponent> opponents;

  _SingleTeamLoadedOpponents({@required this.opponents});

  @override
  List<Object> get props => [opponents];
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
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteAdminSub;
  StreamSubscription<Iterable<Season>> _seasonSub;
  StreamSubscription<Iterable<Opponent>> _opponentSub;
  StreamSubscription<SeasonState> _seasonStateSub;

  bool _doingLoad = false;

  SingleTeamBloc(
      {@required this.teamBloc,
      @required this.clubBloc,
      @required this.seasonBloc,
      @required this.teamUid}) {
    _teamSub = teamBloc.listen((TeamState teamState) {
      Team team = teamState.getTeam(teamUid);
      if (team != null) {
        // Only send this if the team is not the same.
        var builder = MapBuilder<String, Opponent>();
        add(
          _SingleTeamNewTeam(
            newTeam: team,
            opponents: builder.build(),
            seasons: ListBuilder<Season>().build(),
          ),
        );
        _setupClubSub();
      } else {
        print('Deleted team $teamUid');
        add(_SingleTeamDeleted());
      }
    });
    _seasonStateSub = seasonBloc.listen((SeasonState seasonState) {
      Iterable<Season> seasons =
          seasonState.seasons.values.where((Season s) => s.teamUid == teamUid);
      if (!state.loadedSeasons) {
        // Update the season data.
        add(_SingleTeamSeasonDataLoaded(fullUpdate: false, seasons: seasons));
      }
    });
  }

  void _loadOpponents() async {
    print("Loading opponents");
    if (!_doingLoad) {
      _doingLoad = true;
      print("Loading opponents inside");
      Map<String, Map<String, dynamic>> opponentData = await teamBloc
          .coordinationBloc.persistentData
          .getAllTeamElements(PersistenData.opponentsTable, teamUid);
      MapBuilder<String, Opponent> opponents = MapBuilder<String, Opponent>();
      for (String key in opponentData.keys) {
        teamBloc.coordinationBloc.sqlTrace?.incrementCounter("opponent");
        Map<String, dynamic> innerData = opponentData[key];
        Opponent op = Opponent.fromJSON(key, teamUid, innerData).build();
        opponents[key] = op;
      }
      add(_SingleTeamLoadedOpponents(opponents: opponents.build()));
      print("Loading opponents sql $opponents");
      _opponentSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getTeamOpponents(teamUid)
          .listen((Iterable<Opponent> ops) {
        MapBuilder<String, Opponent> opponents = MapBuilder<String, Opponent>();
        for (Opponent op in ops) {
          opponents[op.uid] = op;
          // Write out to sql as well.
          teamBloc.coordinationBloc.persistentData.updateTeamElement(
              PersistenData.opponentsTable, op.uid, teamUid, op.toJSON());
        }
        add(_SingleTeamLoadedOpponents(opponents: opponents.build()));
        print("Loading opponents firestore $opponents");
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    _teamSub?.cancel();
    _inviteAdminSub?.cancel();
    _seasonSub?.cancel();
    _clubSub?.cancel();
    _clubSub = null;
    _opponentSub?.cancel();
    _opponentSub = null;
    _seasonStateSub?.cancel();
    _seasonStateSub = null;
  }

  void _setupClubSub() {
    if (_clubSub == null) {
      if (clubBloc.state is ClubLoaded) {
        Team t = teamBloc.state.getTeam(teamUid);
        if (t.clubUid != null && clubBloc.state.clubs.containsKey(t.clubUid)) {
          add(_SingleTeamNewClub(club: clubBloc.state.clubs[t.clubUid]));
        }
      }
      _clubSub = clubBloc.listen((ClubState clubState) {
        Team t = teamBloc.state.getTeam(teamUid);
        if (t.clubUid != null && clubState.clubs.containsKey(t.clubUid)) {
          Club club = clubState.clubs[t.clubUid];

          if (club != state.club) {
            add(_SingleTeamNewClub(club: club));
          }
        } else {
          add(_SingleTeamNoClub());
        }
      });
    }
  }

  @override
  SingleTeamState get initialState {
    Team t = teamBloc.state.getTeam(teamUid);
    if (t != null) {
      _setupClubSub();
      Club club = clubBloc.state.clubs[t.clubUid];

      return SingleTeamLoaded(
          team: t,
          club: club,
          fullSeason: BuiltList(),
          invitesAsAdmin: BuiltList(),
          opponents: BuiltMap(),
          state: null,
          loadedOpponents: false,
          loadedSeasons: false);
    } else {
      return SingleTeamDeleted();
    }
  }

  @override
  Stream<SingleTeamState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      yield SingleTeamLoaded(
          state: state,
          team: event.newTeam,
          invitesAsAdmin: state.invitesAsAdmin);
    }

    // The team is deleted.
    if (event is _SingleTeamDeleted) {
      yield SingleTeamDeleted();
    }

    // Save the team.
    if (event is SingleTeamUpdate) {
      yield SingleTeamSaving(state: state);
      if (state.team.publicOnly) {
        yield SingleTeamSaveFailed(
            state: state, error: ArgumentError("Cannot save a public team"));
      } else {
        try {
          if (event.image != null) {
            await teamBloc.coordinationBloc.databaseUpdateModel
                .updateTeamImage(teamUid, event.image);
          }
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateFirestoreTeam(event.team.build());
          yield SingleTeamSaveDone(state: state);
          yield SingleTeamLoaded(state: state, team: event.team.build());
        } catch (e) {
          yield SingleTeamSaveFailed(state: state, error: e);
          yield SingleTeamLoaded(state: state);
        }
      }
    }

    // Save the team image.
    if (event is SingleTeamUpdateImage) {
      yield SingleTeamSaving(state: state);
      if (state.team.publicOnly) {
        yield SingleTeamSaveFailed(
            state: state, error: ArgumentError("Cannot save a public team"));
      } else {
        try {
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateTeamImage(teamUid, event.image);
          yield SingleTeamSaveDone(state: state);
          yield SingleTeamLoaded(state: state);
        } catch (e) {
          yield SingleTeamSaveFailed(state: state, error: e);
          yield SingleTeamLoaded(state: state);
        }
      }
    }

    if (event is SingleTeamAddAdmin) {
      yield SingleTeamSaving(state: state);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .addAdmin(teamUid, event.adminUid);
        yield SingleTeamSaveDone(state: state);
        yield SingleTeamLoaded(state: state);
      } catch (e) {
        yield SingleTeamSaveFailed(state: state, error: e);
        yield SingleTeamLoaded(state: state);
      }
    }

    if (event is SingleTeamDeleteAdmin) {
      yield SingleTeamSaving(state: state);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .deleteAdmin(state.team, event.adminUid);
        yield SingleTeamSaveDone(state: state);
        yield SingleTeamLoaded(state: state);
      } catch (e) {
        yield SingleTeamSaveFailed(state: state, error: e);
        yield SingleTeamLoaded(state: state);
      }
    }

    if (event is SingleTeamInviteAdmin) {
      yield SingleTeamSaving(state: state);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel.inviteAdminToTeam(
            teamUid: state.team.uid,
            email: event.email,
            teamName: state.team.name,
            myUid: teamBloc.coordinationBloc.state.uid);
        yield SingleTeamSaveDone(state: state);
        yield SingleTeamLoaded(state: state);
      } catch (e) {
        yield SingleTeamSaveFailed(state: state, error: e);
        yield SingleTeamLoaded(state: state);
      }
    }

    if (event is SingleTeamAddOpponent) {
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .addFirestoreOpponent(
                event.opponent.rebuild((b) => b..teamUid = teamUid));
        yield SingleTeamSaveDone(state: state);
        yield SingleTeamLoaded(state: state);
      } catch (e) {
        yield SingleTeamSaveFailed(state: state, error: e);
        yield SingleTeamLoaded(state: state);
      }
    }

    if (event is _SingleTeamInvitesAdminLoaded) {
      yield SingleTeamLoaded(
          state: state, invitesAsAdmin: BuiltList.from(event.invites));
    }

    if (event is SingleTeamLoadInvites) {
      if (_inviteAdminSub != null) {
        _inviteAdminSub = teamBloc.coordinationBloc.databaseUpdateModel
            .getInvitesForTeam(teamUid)
            .listen((Iterable<InviteAsAdmin> invites) {
          add(_SingleTeamInvitesAdminLoaded(invites: invites));
        });
      }
    }

    if (event is SingleTeamLoadAllSeasons) {
      _seasonSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getSeasonsForTeam(teamUid)
          .listen((Iterable<Season> seasons) {
        add(_SingleTeamSeasonDataLoaded(seasons: seasons, fullUpdate: true));
      });
    }

    if (event is _SingleTeamNewSeasons) {
      yield SingleTeamLoaded(fullSeason: event.seasons, state: state);
    }

    if (event is _SingleTeamLoadedOpponents) {
      yield SingleTeamLoaded(
          state: state, loadedOpponents: true, opponents: event.opponents);
    }

    if (event is SingleTeamLoadOpponents) {
      _loadOpponents();
    }

    if (event is _SingleTeamSeasonDataLoaded) {
      yield SingleTeamLoaded(
          state: state,
          fullSeason: BuiltList.from(event.seasons),
          loadedSeasons: true);
    }

    if (event is _SingleTeamNewClub) {
      yield SingleTeamLoaded(state: state, club: event.club);
    }

    if (event is _SingleTeamNoClub) {
      yield SingleTeamLoaded(state: state, club: null);
    }

    if (event is SingleTeamUpdateClub) {
      try {
        Team myTeam = state.team.rebuild((b) => b..clubUid = event.clubUid);
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreTeam(myTeam);
        yield SingleTeamSaveDone(state: state);
        yield SingleTeamLoaded(state: state, team: myTeam);
      } catch (e) {
        yield SingleTeamSaveFailed(state: state, error: e);
        yield SingleTeamLoaded(state: state);
      }
    }

    if (event is SingleTeamArchive) {
      try {
        Team myTeam = state.team.rebuild((b) => b..archived = event.archive);
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreTeam(myTeam);
        yield SingleTeamSaveDone(state: state);
        yield SingleTeamLoaded(state: state, team: myTeam);
      } catch (e) {
        yield SingleTeamSaveFailed(state: state, error: e);
        yield SingleTeamLoaded(state: state);
      }
    }
  }
}
