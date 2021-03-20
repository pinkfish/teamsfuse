import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

abstract class SingleTeamEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamUpdate extends SingleTeamEvent {
  final TeamBuilder team;
  final Uint8List image;

  SingleTeamUpdate({@required this.team, this.image});

  @override
  List<Object> get props => [team, image];
}

///
/// Updates the image for the team.
///
class SingleTeamUpdateImage extends SingleTeamEvent {
  final Uint8List image;

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
/// Loads the club for this team.
///
class SingleTeamLoadClub extends SingleTeamEvent {
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
  final AnalyticsSubsystem crashes;

  static String createNew = 'new';

  StreamSubscription<Team> _teamSub;
  StreamSubscription<Club> _clubSub;
  StreamSubscription<Iterable<InviteAsAdmin>> _inviteAdminSub;
  StreamSubscription<Iterable<Season>> _seasonSub;
  StreamSubscription<Iterable<Opponent>> _opponentSub;
  StreamSubscription<SeasonState> _seasonStateSub;
  String _listeningClubUid;

  SingleTeamBloc(
      {@required this.db, @required this.teamUid, @required this.crashes})
      : super(SingleTeamUninitialized(), 'TeamState.$teamUid') {
    _teamSub = db.getTeamDetails(teamUid: teamUid).listen((team) {
      if (team != null) {
        add(
          _SingleTeamNewTeam(
            newTeam: team,
          ),
        );
      } else {
        add(_SingleTeamDeleted());
      }
    });
    _teamSub.onError((error, stack) {
      add(_SingleTeamDeleted());
      crashes.recordException(error, stack);
    });
    loadedData.then((value) {
      if (state.team != null) {
        _setupClubSub(state.team);
      }
    });
  }

  void _loadOpponents() async {
    if (_opponentSub != null) {
      await _opponentSub.cancel();
      _opponentSub = null;
    }
    if (_opponentSub == null) {
      _opponentSub =
          db.getTeamOpponents(teamUid).listen((Iterable<Opponent> ops) {
        var opponents = MapBuilder<String, Opponent>();
        for (var op in ops) {
          opponents[op.uid] = op;
        }
        add(_SingleTeamLoadedOpponents(opponents: opponents.build()));
      });
      _opponentSub.onError((e) {
        _opponentSub.cancel();
        _opponentSub = null;
        throw e;
      });
    }
  }

  @override
  Future<void> close() async {
    await super.close();
    await _teamSub?.cancel();
    await _inviteAdminSub?.cancel();
    await _seasonSub?.cancel();
    await _clubSub?.cancel();
    _clubSub = null;
    await _opponentSub?.cancel();
    _opponentSub = null;
    await _seasonStateSub?.cancel();
    _seasonStateSub = null;
  }

  void _setupClubSub(Team t) {
    if (t.clubUid != null &&
        _clubSub == null &&
        _listeningClubUid != t.clubUid) {
      if (_clubSub != null) {
        _clubSub.cancel();
        _clubSub = null;
      }
      _listeningClubUid = t.clubUid;
      _clubSub = db.getClubData(clubUid: t.clubUid).listen((c) {
        if (c != null) {
          add(_SingleTeamNewClub(club: c));
        } else {
          add(_SingleTeamNoClub());
        }
      });
      _clubSub.onError((error, stack) {
        crashes.recordException(error, stack);
      });
    }
  }

  @override
  Stream<SingleTeamState> mapEventToState(SingleTeamEvent event) async* {
    if (event is _SingleTeamNewTeam) {
      Club theClub;

      /// See if we need to load the club.
      if (event.newTeam.clubUid != null) {
        try {
          theClub = await db.getClubData(clubUid: event.newTeam.clubUid).first;
        } catch (e, stack) {
          if (e is Exception) {
            crashes.recordException(e, stack);
          } else if (e is Error) {
            crashes.recordError(e, stack);
          }
        }
      }
      yield (SingleTeamLoaded.fromState(state)
            ..team = event.newTeam.toBuilder()
            ..club = theClub?.toBuilder())
          .build();
      _setupClubSub(state.team);
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
              ..error = ArgumentError('Cannot save a public team'))
            .build();
      } else {
        try {
          if (event.image != null) {
            final newUri = await db.updateTeamImage(teamUid, event.image);
            event.team.photoUrl = newUri.toString();
          }
          await db.updateFirestoreTeam(event.team.build());
          yield (SingleTeamSaveDone.fromState(state)..savedUid = event.team.uid)
              .build();
          yield (SingleTeamLoaded.fromState(state)..team = event.team).build();
        } catch (e, stack) {
          yield (SingleTeamSaveFailed.fromState(state)..error = e).build();
          yield SingleTeamLoaded.fromState(state).build();
          crashes.recordException(e, stack);
        }
      }
    }

    // Save the team image.
    if (event is SingleTeamUpdateImage) {
      yield SingleTeamSaving.fromState(state).build();
      if (state.team.publicOnly) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = ArgumentError('Cannot save a public team'))
            .build();
      } else {
        try {
          await db.updateTeamImage(teamUid, event.image);
          yield (SingleTeamSaveDone.fromState(state)..savedUid = teamUid)
              .build();
          yield SingleTeamLoaded.fromState(state).build();
        } catch (e, stack) {
          yield (SingleTeamSaveFailed.fromState(state)
                ..error = RemoteError(e.message, stack.toString()))
              .build();
          yield SingleTeamLoaded.fromState(state).build();
          crashes.recordException(e, stack);
        }
      }
    }

    if (event is SingleTeamAddAdmin) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        await db.addAdmin(teamUid, event.adminUid);
        yield (SingleTeamSaveDone.fromState(state)..savedUid = teamUid).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleTeamDeleteAdmin) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        await db.deleteAdmin(state.team, event.adminUid);
        yield (SingleTeamSaveDone.fromState(state)..savedUid = teamUid).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
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
        yield (SingleTeamSaveDone.fromState(state)..savedUid = teamUid).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleTeamAddOpponent) {
      try {
        var op = await db.addFirestoreOpponent(
            event.opponent.rebuild((b) => b..teamUid = teamUid));
        yield (SingleTeamSaveDone.fromState(state)..savedUid = op.uid).build();
        yield SingleTeamLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is _SingleTeamInvitesAdminLoaded) {
      yield (SingleTeamLoaded.fromState(state)
            ..invitesAsAdmin = event.invites.toBuilder()
            ..loadedInvites = true)
          .build();
    }

    if (event is SingleTeamLoadInvites) {
      if (_inviteAdminSub == null && !(state is SingleTeamUninitialized)) {
        _inviteAdminSub = db
            .getInvitesForTeam(teamUid)
            .listen((Iterable<InviteAsAdmin> invites) {
          add(_SingleTeamInvitesAdminLoaded(invites: BuiltList.of(invites)));
        });
      }
    }

    if (event is SingleTeamLoadSeasons) {
      if (_seasonSub == null && !(state is SingleTeamUninitialized)) {
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
      if (_opponentSub == null) {
        _loadOpponents();
      }
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
        var myTeam = state.team.rebuild((b) => b..clubUid = event.clubUid);
        await db.updateFirestoreTeam(myTeam);
        yield (SingleTeamSaveDone.fromState(state)..savedUid = teamUid).build();
        yield (SingleTeamLoaded.fromState(state)..team = myTeam.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleTeamArchive) {
      yield SingleTeamSaving.fromState(state).build();
      try {
        var myTeam = state.team.rebuild(
            (b) => b..archivedData[state.team.userUid] = event.archive);
        await db.updateFirestoreTeam(myTeam);
        yield (SingleTeamSaveDone.fromState(state)..savedUid = teamUid).build();
        yield (SingleTeamLoaded.fromState(state)..team = myTeam.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleTeamState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleTeamUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return state;
    }

    try {
      var type = SingleTeamBlocStateType.valueOf(json['type']);
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
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleTeamUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleTeamState state) {
    return state.toMap();
  }
}
