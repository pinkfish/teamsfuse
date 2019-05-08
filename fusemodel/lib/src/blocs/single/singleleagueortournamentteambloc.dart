import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/blocs/single/singleleagueortournamentdivisonbloc.dart';
import 'package:meta/meta.dart';

///
/// Basic state for all the data in this system.
///
abstract class SingleLeagueOrTournamentTeamState extends Equatable {
  final LeagueOrTournamentTeam leagueOrTournamentTeam;
  final Map<String, GameSharedData> games;
  final Iterable<InviteToLeagueTeam> invites;
  final Team publicTeam;

  SingleLeagueOrTournamentTeamState(
      {@required this.leagueOrTournamentTeam,
      @required this.games,
      @required this.invites,
      @required this.publicTeam});
}

///
/// Doing something.
///
class SingleLeagueOrTournamentTeamLoaded
    extends SingleLeagueOrTournamentTeamState {
  SingleLeagueOrTournamentTeamLoaded(
      {@required SingleLeagueOrTournamentTeamState state,
      LeagueOrTournamentTeam leagueOrTournamentTeam,
      Iterable<InviteToLeagueTeam> invites,
      Map<String, GameSharedData> games,
      Team publicTeam})
      : super(
            leagueOrTournamentTeam:
                leagueOrTournamentTeam ?? state.leagueOrTournamentTeam,
            games: games ?? state.games,
            publicTeam: publicTeam ?? state.publicTeam,
            invites: invites ?? state.invites);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentTeamLoaded{}';
  }
}

///
/// Saveing failed, with an specified error.
///
class SingleLeagueOrTournamentTeamSaveFailed
    extends SingleLeagueOrTournamentTeamState {
  final Error error;

  SingleLeagueOrTournamentTeamSaveFailed(
      {@required SingleLeagueOrTournamentTeamState leagueOrTournament,
      @required this.error})
      : super(
            leagueOrTournamentTeam: leagueOrTournament.leagueOrTournamentTeam,
            games: leagueOrTournament.games,
            invites: leagueOrTournament.invites,
            publicTeam: leagueOrTournament.publicTeam);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentTeamSaveFailed{}';
  }
}

///
/// In the process of saving.
///
class SingleLeagueOrTournamentTeamSaving
    extends SingleLeagueOrTournamentTeamState {
  SingleLeagueOrTournamentTeamSaving(
      {@required SingleLeagueOrTournamentTeamState leagueOrTournament})
      : super(
            leagueOrTournamentTeam: leagueOrTournament.leagueOrTournamentTeam,
            games: leagueOrTournament.games,
            invites: leagueOrTournament.invites,
            publicTeam: leagueOrTournament.publicTeam);

  @override
  String toString() {
    return 'SingleLeagueOrTournamentTeamSaving{}';
  }
}

///
/// Deleted
///
class SingleLeagueOrTournamentTeamDeleted
    extends SingleLeagueOrTournamentTeamState {
  SingleLeagueOrTournamentTeamDeleted(
      {@required SingleLeagueOrTournamentTeamState leagueOrTournament})
      : super(
            leagueOrTournamentTeam: leagueOrTournament.leagueOrTournamentTeam,
            invites: leagueOrTournament.invites,
            games: leagueOrTournament.games,
            publicTeam: leagueOrTournament.publicTeam);
  SingleLeagueOrTournamentTeamDeleted.empty()
      : super(
            leagueOrTournamentTeam: null,
            invites: {},
            games: {},
            publicTeam: null);
  @override
  String toString() {
    return 'SingleLeagueOrTournamentDivisonDeleted{}';
  }
}

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
}

class _SingleLeagueOrTournamentEventTeamDeleted
    extends SingleLeagueOrTournamentTeamEvent {}

class _SingleLeagueOrTournamentEventTeamGames
    extends SingleLeagueOrTournamentTeamEvent {
  Iterable<GameSharedData> games;

  _SingleLeagueOrTournamentEventTeamGames({this.games});
}

class _SingleLeagueOrTournamentEventTeamInvites
    extends SingleLeagueOrTournamentTeamEvent {
  Iterable<InviteToLeagueTeam> invites;

  _SingleLeagueOrTournamentEventTeamInvites({this.invites});
}

///
/// Loads the Games for this league or tournament team.
///
class SingleLeagueOrTournamentTeamLoadGames
    extends SingleLeagueOrTournamentTeamEvent {}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamLoadInvites
    extends SingleLeagueOrTournamentTeamEvent {}

///
/// Loads the public team associated with this league team.
///
class SingleLeagueOrTournamentTeamLoadPublicTeam
    extends SingleLeagueOrTournamentTeamEvent {}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamUpdate
    extends SingleLeagueOrTournamentTeamEvent {
  final LeagueOrTournamentTeam team;

  SingleLeagueOrTournamentTeamUpdate(this.team);
}

///
/// Loads the Invites for this league or tournament team.
///
class SingleLeagueOrTournamentTeamUpdateWinRecord
    extends SingleLeagueOrTournamentTeamEvent {
  final String divison;
  final WinRecord record;

  SingleLeagueOrTournamentTeamUpdateWinRecord(this.divison, this.record);
}

///
/// Handles the work around the clubs and club system inside of
/// the app.
///
class SingleLeagueOrTournamentTeamBloc extends Bloc<
    SingleLeagueOrTournamentTeamEvent, SingleLeagueOrTournamentTeamState> {
  final SingleLeagueOrTournamentDivisonBloc singleLeagueOrTournamenDivisonBloc;
  final String leagueTeamUid;

  StreamSubscription<SingleLeagueOrTournamentDivisonState> _coordSub;
  StreamSubscription<Iterable<GameSharedData>> _gamesSnapshot;
  StreamSubscription<Iterable<InviteToLeagueTeam>> _inviteSnapshot;

  SingleLeagueOrTournamentTeamBloc(
      {@required this.singleLeagueOrTournamenDivisonBloc,
      @required this.leagueTeamUid}) {
    _coordSub = singleLeagueOrTournamenDivisonBloc.state
        .listen((SingleLeagueOrTournamentDivisonState state) {
      if (state is SingleLeagueOrTournamentDivisonLoaded) {
        if (state.leagueOrTournamentTeams.containsKey(leagueTeamUid)) {
          dispatch(_SingleLeagueOrTournamentEventLeagueTeamLoaded(
              leagueDivision: state.leagueOrTournamentTeams[leagueTeamUid]));
        } else {
          dispatch(_SingleLeagueOrTournamentEventTeamDeleted());
        }
      }
      if (state is SingleLeagueOrTournamentDivisonDeleted) {
        dispatch(_SingleLeagueOrTournamentEventTeamDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cleanupStuff();
    _coordSub?.cancel();
  }

  void _cleanupStuff() {
    _gamesSnapshot?.cancel();
    _gamesSnapshot = null;
    _inviteSnapshot?.cancel();
    _inviteSnapshot = null;
  }

  @override
  SingleLeagueOrTournamentTeamState get initialState {
    if (singleLeagueOrTournamenDivisonBloc.currentState.leagueOrTournamentTeams
        .containsKey(leagueTeamUid)) {
      return SingleLeagueOrTournamentTeamLoaded(
          leagueOrTournamentTeam: singleLeagueOrTournamenDivisonBloc
              .currentState.leagueOrTournamentTeams[leagueTeamUid],
          games: {});
    } else {
      return SingleLeagueOrTournamentTeamDeleted.empty();
    }
  }

  void _updateGames(Iterable<GameSharedData> games) {
    dispatch(_SingleLeagueOrTournamentEventTeamGames(games: games));
  }

  void _updateInvites(Iterable<InviteToLeagueTeam> invites) {
    dispatch(_SingleLeagueOrTournamentEventTeamInvites(invites: invites));
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentTeamState> _updateLeagueOrTournamentTeam(
      LeagueOrTournamentTeam league) async* {
    if (league.uid == leagueTeamUid) {
      yield SingleLeagueOrTournamentTeamSaving(
          leagueOrTournament: currentState);
      try {
        await singleLeagueOrTournamenDivisonBloc
            .singleLeagueOrTournamentSeasonBloc
            .singleLeagueOrTournamentBloc
            .leagueOrTournamentBloc
            .coordinationBloc
            .databaseUpdateModel
            .updateLeagueTeam(league);
        yield SingleLeagueOrTournamentTeamLoaded(
            leagueOrTournamentTeam: currentState.leagueOrTournamentTeam,
            games: currentState.games);
      } catch (e) {
        yield SingleLeagueOrTournamentTeamSaveFailed(
            leagueOrTournament: currentState, error: e);
      }
    } else {
      yield SingleLeagueOrTournamentTeamSaveFailed(
          leagueOrTournament: currentState,
          error: ArgumentError("league uids don't match"));
    }
  }

  ///
  /// Updates the league or tournament with great new stuff.
  ///
  Stream<SingleLeagueOrTournamentTeamState> _updateWinRecord(
      String divison, WinRecord record) async* {
    try {
      yield SingleLeagueOrTournamentTeamSaving(
          leagueOrTournament: currentState);
      await singleLeagueOrTournamenDivisonBloc
          .singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .updateLeagueTeamRecord(
              currentState.leagueOrTournamentTeam, divison, record);
      yield SingleLeagueOrTournamentTeamLoaded(
          leagueOrTournamentTeam: currentState.leagueOrTournamentTeam,
          games: currentState.games);
    } catch (e) {
      yield SingleLeagueOrTournamentTeamSaveFailed(
          leagueOrTournament: currentState, error: e);
    }
  }

  @override
  Stream<SingleLeagueOrTournamentTeamState> mapEventToState(
      SingleLeagueOrTournamentTeamEvent event) async* {
    if (event is _SingleLeagueOrTournamentEventLeagueTeamLoaded) {
      yield SingleLeagueOrTournamentTeamLoaded(
          state: currentState, leagueOrTournamentTeam: event.leagueDivision);
    }

    if (event is _SingleLeagueOrTournamentEventTeamDeleted) {
      yield SingleLeagueOrTournamentTeamDeleted.empty();
      _cleanupStuff();
    }

    if (event is SingleLeagueOrTournamentTeamLoadGames) {
      _gamesSnapshot = singleLeagueOrTournamenDivisonBloc
          .singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .getLeagueGamesForTeam(leagueTeamUid)
          .listen((Iterable<GameSharedData> games) => _updateGames(games));
    }

    if (event is SingleLeagueOrTournamentTeamLoadInvites) {
      _inviteSnapshot = singleLeagueOrTournamenDivisonBloc
          .singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .getLeagueOrTournmentTeamInvitesStream(leagueTeamUid)
          .listen((Iterable<InviteToLeagueTeam> invites) =>
              _updateInvites(invites));
    }

    if (event is _SingleLeagueOrTournamentEventTeamGames) {
      Map<String, GameSharedData> newGames = {};
      for (GameSharedData game in event.games) {
        newGames[game.uid] = game;
      }
      yield SingleLeagueOrTournamentTeamLoaded(
          state: currentState,
          leagueOrTournamentTeam: currentState.leagueOrTournamentTeam,
          games: newGames);
    }

    if (event is _SingleLeagueOrTournamentEventTeamInvites) {
      yield SingleLeagueOrTournamentTeamLoaded(
          state: currentState, invites: event.invites);
    }

    if (event is SingleLeagueOrTournamentTeamUpdate) {
      yield* _updateLeagueOrTournamentTeam(event.team);
    }

    if (event is SingleLeagueOrTournamentTeamUpdateWinRecord) {
      yield* _updateWinRecord(event.divison, event.record);
    }

    if (event is SingleLeagueOrTournamentTeamLoadPublicTeam) {
      Team publicTeam = await singleLeagueOrTournamenDivisonBloc
          .singleLeagueOrTournamentSeasonBloc
          .singleLeagueOrTournamentBloc
          .leagueOrTournamentBloc
          .coordinationBloc
          .databaseUpdateModel
          .getPublicTeamDetails(
              userUid: singleLeagueOrTournamenDivisonBloc
                  .singleLeagueOrTournamentSeasonBloc
                  .singleLeagueOrTournamentBloc
                  .leagueOrTournamentBloc
                  .coordinationBloc
                  .authenticationBloc
                  .currentUser
                  .uid,
              teamUid: currentState.leagueOrTournamentTeam.teamUid);
      yield SingleLeagueOrTournamentTeamLoaded(
          state: currentState, publicTeam: publicTeam);
    }
  }
}
