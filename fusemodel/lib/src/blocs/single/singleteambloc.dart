import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:meta/meta.dart';

import '../data/seasonblocstate.dart';
import 'data/singleteambloc.dart';

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
class SingleTeamLoadSeasons extends SingleTeamEvent {
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

  _SingleTeamNewTeam({@required this.newTeam});

  @override
  List<Object> get props => [newTeam];
}

class _SingleTeamDeleted extends SingleTeamEvent {
  @override
  List<Object> get props => [];
}

class _SingleTeamInvitesAdminLoaded extends SingleTeamEvent {
  final BuiltList<InviteAsAdmin> invites;

  _SingleTeamInvitesAdminLoaded({@required this.invites});

  @override
  List<Object> get props => [invites];
}

class _SingleTeamSeasonDataLoaded extends SingleTeamEvent {
  final BuiltList<Season> seasons;
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
class SingleTeamBloc
    extends AsyncHydratedBloc<SingleTeamEvent, SingleTeamState> {
  final String teamUid;
  final DatabaseUpdateModel db;

  static String createNew = "new";

  StreamSubscription<Team> _teamSub;
  StreamSubscription<Club> _clubSub;
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteAdminSub;
  StreamSubscription<Iterable<Season>> _seasonSub;
  StreamSubscription<Iterable<Opponent>> _opponentSub;
  StreamSubscription<SeasonState> _seasonStateSub;

  SingleTeamBloc({@required this.db, @required this.teamUid})
      : super(SingleTeamUninitialized(), "TeamState.$teamUid") {
    _teamSub = db.getTeamDetails(teamUid: teamUid).listen((team) {
      if (team != null) {
        add(
          _SingleTeamNewTeam(
            newTeam: team,
          ),
        );
        _setupClubSub(team);
      } else {
        add(_SingleTeamDeleted());
      }
    });
  }

  void _loadOpponents() async {
    print("Loading opponents");
    if (_opponentSub == null) {
      _opponentSub =
          db.getTeamOpponents(teamUid).listen((Iterable<Opponent> ops) {
        MapBuilder<String, Opponent> opponents = MapBuilder<String, Opponent>();
        for (Opponent op in ops) {
          opponents[op.uid] = op;
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

  void _setupClubSub(Team t) {
    if (t.clubUid != null && _clubSub != null) {
      _clubSub = db.getClubData(clubUid: t.clubUid).listen((c) {
        if (c != null) {
          add(_SingleTeamNewClub(club: c));
        } else {
          add(_SingleTeamNoClub());
        }
      });
    }
  }

  @override
  Stream<SingleTeamState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      yield (SingleTeamLoaded.fromState(state)
            ..team = event.newTeam.toBuilder())
          .build();
    }

    // The team is deleted.
    if (event is _SingleTeamDeleted) {
      yield SingleTeamDeleted();
    }

    // Save the team.
    if (event is SingleTeamUpdate) {
      yield SingleTeamSaving.fromState(state).build();
      if (state.team.publicOnly) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = ArgumentError("Cannot save a public team"))
            .build();
      } else {
        try {
          if (event.image != null) {
            await db.updateTeamImage(teamUid, event.image);
          }
          await db.updateFirestoreTeam(event.team.build());
          yield SingleTeamSaveDone.fromState(state).build();
          yield (SingleTeamLoaded.fromState(state)..team = event.team).build();
        } catch (e) {
          yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
          yield SingleTeamLoaded.fromState(state).build();
        }
      }
    }

    // Save the team image.
    if (event is SingleTeamUpdateImage) {
      yield SingleTeamSaving.fromState(state).build();
      if (state.team.publicOnly) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = ArgumentError("Cannot save a public team"))
            .build();
      } else {
        try {
          await db.updateTeamImage(teamUid, event.image);
          yield SingleTeamSaveDone.fromState(state).build();
          yield SingleTeamLoaded.fromState(state).build();
        } catch (e) {
          yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
          yield SingleTeamLoaded.fromState(state).build();
        }
      }
    }

    if (event is SingleTeamAddAdmin) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        await db.addAdmin(teamUid, event.adminUid);
        yield SingleTeamSaveDone.fromState(state).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
        yield SingleTeamLoaded.fromState(state).build();
      }
    }

    if (event is SingleTeamDeleteAdmin) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        await db.deleteAdmin(state.team, event.adminUid);
        yield SingleTeamSaveDone.fromState(state).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
        yield SingleTeamLoaded.fromState(state).build();
      }
    }

    if (event is SingleTeamInviteAdmin) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        await db.inviteAdminToTeam(
            teamUid: state.team.uid,
            email: event.email,
            teamName: state.team.name,
            myUid: db.currentUser.uid);
        yield SingleTeamSaveDone.fromState(state).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
        yield SingleTeamLoaded.fromState(state).build();
      }
    }

    if (event is SingleTeamAddOpponent) {
      try {
        await db.addFirestoreOpponent(
            event.opponent.rebuild((b) => b..teamUid = teamUid));
        yield SingleTeamSaveDone.fromState(state).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e) {
        yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
        yield SingleTeamLoaded.fromState(state).build();
      }
    }

    if (event is _SingleTeamInvitesAdminLoaded) {
      yield (SingleTeamLoaded.fromState(state)
            ..invitesAsAdmin = event.invites.toBuilder()
            ..loadedInvites = true)
          .build();
    }

    if (event is SingleTeamLoadInvites) {
      if (_inviteAdminSub == null) {
        _inviteAdminSub = db
            .getInvitesForTeam(teamUid)
            .listen((Iterable<InviteAsAdmin> invites) {
          add(_SingleTeamInvitesAdminLoaded(invites: invites));
        });
      }
    }

    if (event is SingleTeamLoadSeasons) {
      if (_seasonSub == null) {
        _seasonSub = db.getSeasonsForTeam(teamUid).listen((var seasons) {
          add(_SingleTeamSeasonDataLoaded(seasons: seasons, fullUpdate: true));
        });
      }
    }

    if (event is _SingleTeamLoadedOpponents) {
      yield (SingleTeamLoaded.fromState(state)
            ..loadedOpponents = true
            ..opponents = event.opponents.toBuilder())
          .build();
    }

    if (event is SingleTeamLoadOpponents) {
      _loadOpponents();
    }

    if (event is _SingleTeamSeasonDataLoaded) {
      yield (SingleTeamLoaded.fromState(state)
            ..fullSeason = event.seasons.toBuilder()
            ..loadedSeasons = true)
          .build();
    }

    if (event is _SingleTeamNewClub) {
      yield (SingleTeamLoaded.fromState(state)..club = event.club.toBuilder())
          .build();
    }

    if (event is _SingleTeamNoClub) {
      yield (SingleTeamLoaded.fromState(state)..club = null).build();
    }

    if (event is SingleTeamUpdateClub) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        Team myTeam = state.team.rebuild((b) => b..clubUid = event.clubUid);
        await db.updateFirestoreTeam(myTeam);
        yield SingleTeamSaveDone.fromState(state).build();
        yield (SingleTeamLoaded.fromState(state)..team = myTeam.toBuilder())
            .build();
      } catch (e) {
        yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
        yield SingleTeamLoaded.fromState(state).build();
      }
    }

    if (event is SingleTeamArchive) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        Team myTeam = state.team.rebuild(
            (b) => b..archivedData[state.team.userUid] = event.archive);
        await db.updateFirestoreTeam(myTeam);
        yield SingleTeamSaveDone.fromState(state).build();
        yield (SingleTeamLoaded.fromState(state)..team = myTeam.toBuilder())
            .build();
      } catch (e) {
        yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
        yield SingleTeamLoaded.fromState(state).build();
      }
    }
  }

  @override
  SingleTeamState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleTeamUninitialized();
    }

    SingleTeamBlocStateType type =
        SingleTeamBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SingleTeamBlocStateType.Uninitialized:
        return SingleTeamUninitialized();
      case SingleTeamBlocStateType.Loaded:
        var ret = SingleTeamLoaded.fromMap(json);
        return ret;
      case SingleTeamBlocStateType.Deleted:
        return SingleTeamDeleted.fromMap(json);
      case SingleTeamBlocStateType.SaveFailed:
        return SingleTeamSaveFailed.fromMap(json);
      case SingleTeamBlocStateType.Saving:
        return SingleTeamSaving.fromMap(json);
      case SingleTeamBlocStateType.SaveDone:
        return SingleTeamSaveDone.fromMap(json);
    }
    return SingleTeamUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleTeamState state) {
    return state.toMap();
  }
}
