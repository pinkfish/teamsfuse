import 'dart:async';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

abstract class SingleLeagueOrTournamentTeamEvent extends Equatable {}

class _SingleLeagueOrTournamentEventLeagueTeamLoaded
    extends SingleLeagueOrTournamentTeamEvent {
  final LeagueOrTournamentTeam leagueDivision;

  _SingleLeagueOrTournamentEventLeagueTeamLoaded(
      {@required this.leagueDivision});

  @override
  String toString() {
    return '_SingleLeagueOrTournamentEventLeagueTeamLoaded{}';
  }

  @override
  List<Object> get props => [leagueDivision];
}

class _SingleLeagueOrTournamentEventTeamDeleted
    extends SingleLeagueOrTournamentTeamEvent {
  @override
  List<Object> get props => [];
}

class _SingleLeagueOrTournamentEventTeamGames
    extends SingleLeagueOrTournamentTeamEvent {
  final Iterable<GameSharedData> games;

  _SingleLeagueOrTournamentEventTeamGames({this.games});

  @override
  List<Object> get props => [games];
}

class _SingleLeagueOrTournamentEventTeamInvites
    extends SingleLeagueOrTournamentTeamEvent {
  final Iterable<InviteToLeagueTeam> invites;

  _SingleLeagueOrTournamentEventTeamInvites({this.invites});

  @override
  List<Object> get props => [invites];
}

///
/// Loads the Games for this league or tournament team.
///
class SingleLeagueOrTournamentTeamLoadGames
    extends SingleLeagueOrTournamentTeamEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamLoadInvites
    extends SingleLeagueOrTournamentTeamEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the public team associated with this league team.
///
class SingleLeagueOrTournamentTeamLoadPublicTeam
    extends SingleLeagueOrTournamentTeamEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamUpdate
    extends SingleLeagueOrTournamentTeamEvent {
  final LeagueOrTournamentTeam team;

  SingleLeagueOrTournamentTeamUpdate({this.team});

  @override
  List<Object> get props => [team];
}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamUpdateWinRecord
    extends SingleLeagueOrTournamentTeamEvent {
  final String divison;
  final WinRecord record;

  SingleLeagueOrTournamentTeamUpdateWinRecord({this.divison, this.record});

  @override
  List<Object> get props => [divison, record];
}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamInviteMember
    extends SingleLeagueOrTournamentTeamEvent {
  final String email;

  SingleLeagueOrTournamentTeamInviteMember({this.email});

  @override
  List<Object> get props => [email];
}

class _SingleLeagueOrTournamentEventNewPublicTeam
    extends SingleLeagueOrTournamentTeamEvent {
  final Team publicTeam;

  _SingleLeagueOrTournamentEventNewPublicTeam(this.publicTeam);

  @override
  List<Object> get props => [publicTeam];
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentTeamBloc extends AsyncHydratedBloc<
    SingleLeagueOrTournamentTeamEvent, SingleLeagueOrTournamentTeamState> {
  final String leagueTeamUid;
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;

  StreamSubscription<Iterable<GameSharedData>> _gamesSnapshot;
  StreamSubscription<Iterable<InviteToLeagueTeam>> _inviteSnapshot;
  StreamSubscription<LeagueOrTournamentTeam> _teamSub;
  StreamSubscription<Team> _sub;

  SingleLeagueOrTournamentTeamBloc(
      {@required this.leagueTeamUid, @required this.db, @required this.crashes})
      : super(SingleLeagueOrTournamentTeamUninitialized(),
            "LeagueTeam.$leagueTeamUid") {
    _teamSub = db
        .getLeagueTeamData(leagueTeamUid)
        .listen((LeagueOrTournamentTeam team) {
      if (team != null) {
        add(_SingleLeagueOrTournamentEventLeagueTeamLoaded(
            leagueDivision: team));
      } else {
        add(_SingleLeagueOrTournamentEventTeamDeleted());
      }
    });
    _teamSub.onError((e, stack) => crashes.recordException(e, stack));
  }

  @override
  Future<void> close() async {
    await super.close();
    _cleanupStuff();
  }

  void _cleanupStuff() {
    _gamesSnapshot?.cancel();
    _gamesSnapshot = null;
    _inviteSnapshot?.cancel();
    _inviteSnapshot = null;
    _teamSub?.cancel();
    _teamSub = null;
    _sub?.cancel();
    _sub = null;
  }

  void _updateInvites(Iterable<InviteToLeagueTeam> invites) {
    add(_SingleLeagueOrTournamentEventTeamInvites(invites: invites));
  }

  void _inviteMember(String email) {
    db.inviteUserToLeagueTeam(
      leagueTeam: state.leagueOrTournamentTeam,
      leagueSeasonUid: state.leagueOrTournamentTeam.leagueOrTournamentSeasonUid,
      email: email,
    );
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentTeamState> _updateLeagueOrTournamentTeam(
      LeagueOrTournamentTeam league) async* {
    if (league.uid == leagueTeamUid) {
      yield SingleLeagueOrTournamentTeamSaving.fromState(state).build();
      try {
        await db.updateLeagueTeam(league);
        yield SingleLeagueOrTournamentTeamSaveDone.fromState(state).build();
        yield SingleLeagueOrTournamentTeamLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleLeagueOrTournamentTeamSaveFailed.fromState(state)
              ..error = RemoteError(e.messages, stack.toString()))
            .build();
        yield SingleLeagueOrTournamentTeamLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    } else {
      final e = ArgumentError("league uids don't match");
      yield (SingleLeagueOrTournamentTeamSaveFailed.fromState(state)..error = e)
          .build();
      yield SingleLeagueOrTournamentTeamLoaded.fromState(state).build();
      crashes.recordError(e, StackTrace.current);
    }
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentTeamState> _updateWinRecord(
      String divison, WinRecord record) async* {
    try {
      yield SingleLeagueOrTournamentTeamSaving.fromState(state).build();
      await db.updateLeagueTeamRecord(
          state.leagueOrTournamentTeam, divison, record);
      yield SingleLeagueOrTournamentTeamSaveDone.fromState(state).build();
      yield (SingleLeagueOrTournamentTeamLoaded.fromState(state)).build();
    } catch (e, stack) {
      yield (SingleLeagueOrTournamentTeamSaveFailed.fromState(state)
            ..error = RemoteError(e.messages, stack.toString()))
          .build();
      yield SingleLeagueOrTournamentTeamLoaded.fromState(state).build();
      crashes.recordException(e, stack);
    }
  }

  @override
  Stream<SingleLeagueOrTournamentTeamState> mapEventToState(
      SingleLeagueOrTournamentTeamEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueTeamLoaded) {
      yield (SingleLeagueOrTournamentTeamLoaded.fromState(state)
            ..leagueOrTournamentTeam = event.leagueDivision.toBuilder())
          .build();
    }

    if (event is _SingleLeagueOrTournamentEventTeamDeleted) {
      yield SingleLeagueOrTournamentTeamDeleted();
      _cleanupStuff();
    }

    if (event is SingleLeagueOrTournamentTeamLoadGames) {
       if (state is SingleLeagueOrTournamentTeamLoaded &&
          _gamesSnapshot == null) {
        _gamesSnapshot = db.getLeagueGamesForTeam(leagueTeamUid).listen(
            (Iterable<GameSharedData> games) =>
                add(_SingleLeagueOrTournamentEventTeamGames(games: games)));
        _gamesSnapshot.onError((e, stack) => crashes.recordException(e, stack));
      }
    }

    if (event is SingleLeagueOrTournamentTeamLoadInvites) {
      _inviteSnapshot = db
          .getLeagueOrTournmentTeamInvitesStream(leagueTeamUid)
          .listen((Iterable<InviteToLeagueTeam> invites) =>
              _updateInvites(invites));
      _inviteSnapshot.onError((e, stack) => crashes.recordException(e, stack));
    }

    if (event is _SingleLeagueOrTournamentEventTeamGames) {
      MapBuilder<String, GameSharedData> newGames =
          MapBuilder<String, GameSharedData>();
      for (GameSharedData game in event.games) {
        newGames[game.uid] = game;
      }
      yield (SingleLeagueOrTournamentTeamLoaded.fromState(state)
            ..games = newGames
            ..loadedGames = true)
          .build();
    }

    if (event is _SingleLeagueOrTournamentEventTeamInvites) {
      yield (SingleLeagueOrTournamentTeamLoaded.fromState(state)
            ..invites = ListBuilder(event.invites)
            ..loadedInvites = true)
          .build();
    }

    if (event is SingleLeagueOrTournamentTeamUpdate) {
      yield* _updateLeagueOrTournamentTeam(event.team);
    }

    if (event is SingleLeagueOrTournamentTeamUpdateWinRecord) {
      yield* _updateWinRecord(event.divison, event.record);
    }

    if (event is SingleLeagueOrTournamentTeamInviteMember) {
      _inviteMember(event.email);
    }

    if (event is SingleLeagueOrTournamentTeamLoadPublicTeam) {
      if (state is SingleLeagueOrTournamentTeamLoaded && _sub == null) {
        _sub = db
            .getPublicTeamDetails(teamUid: state.leagueOrTournamentTeam.teamUid)
            .listen((event) {
          add(_SingleLeagueOrTournamentEventNewPublicTeam(event));
        });
        _sub.onError((e, stack) => crashes.recordException(e, stack));
      }
    }

    if (event is _SingleLeagueOrTournamentEventNewPublicTeam) {
      yield (SingleLeagueOrTournamentTeamLoaded.fromState(state)
            ..publicTeam = event.publicTeam.toBuilder())
          .build();
    }
  }

  @override
  SingleLeagueOrTournamentTeamState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SingleLeagueOrTournamentTeamUninitialized();
    }

    try {
      SingleLeagueOrTournamentTeamBlocStateType type =
          SingleLeagueOrTournamentTeamBlocStateType.valueOf(json["type"]);
      switch (type) {
        case SingleLeagueOrTournamentTeamBlocStateType.Uninitialized:
          return SingleLeagueOrTournamentTeamUninitialized();
        case SingleLeagueOrTournamentTeamBlocStateType.Loaded:
          var ret = SingleLeagueOrTournamentTeamLoaded.fromMap(json);
          return ret;
        case SingleLeagueOrTournamentTeamBlocStateType.Deleted:
          return SingleLeagueOrTournamentTeamDeleted.fromMap(json);
        case SingleLeagueOrTournamentTeamBlocStateType.SaveFailed:
          return SingleLeagueOrTournamentTeamSaveFailed.fromMap(json);
        case SingleLeagueOrTournamentTeamBlocStateType.Saving:
          return SingleLeagueOrTournamentTeamSaving.fromMap(json);
        case SingleLeagueOrTournamentTeamBlocStateType.SaveDone:
          return SingleLeagueOrTournamentTeamSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleLeagueOrTournamentTeamUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleLeagueOrTournamentTeamState state) {
    return state.toMap();
  }
}
