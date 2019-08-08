import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../playerbloc.dart';
import '../teambloc.dart';

///
/// The basic state for all the bits of the single team bloc.
///
abstract class SingleTeamSeasonPlayerState extends Equatable {
  final SeasonPlayer seasonPlayer;

  SingleTeamSeasonPlayerState({@required this.seasonPlayer});
}

///
/// We have a team, default state.
///
class SingleTeamSeasonPlayerLoaded extends SingleTeamSeasonPlayerState {
  SingleTeamSeasonPlayerLoaded(
      {@required SeasonPlayer seasonPlayer,
      SingleTeamSeasonPlayerState state,
      Player player,
      bool invitesLoaded,
      Iterable<InviteToPlayer> invites})
      : super(
          seasonPlayer: seasonPlayer ?? state.seasonPlayer,
        );

  @override
  String toString() {
    return 'SingleTeamSeasonPlayerLoaded{player: $seasonPlayer}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamSeasonPlayerSaving extends SingleTeamSeasonPlayerState {
  SingleTeamSeasonPlayerSaving({@required SingleTeamSeasonPlayerState state})
      : super(seasonPlayer: state.seasonPlayer);

  @override
  String toString() {
    return 'SingleTeamSeasonPlayerSaving{player: $seasonPlayer}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamSeasonPlayerSaveFailed extends SingleTeamSeasonPlayerState {
  final Error error;

  SingleTeamSeasonPlayerSaveFailed(
      {@required SingleTeamSeasonPlayerState state, this.error})
      : super(seasonPlayer: state.seasonPlayer);

  @override
  String toString() {
    return 'SingleTeamSeasonPlayerSaveFailed{season: $seasonPlayer}';
  }
}

///
/// Team got deleted.
///
class SingleTeamSeasonPlayerDeleted extends SingleTeamSeasonPlayerState {
  SingleTeamSeasonPlayerDeleted() : super(seasonPlayer: null);

  @override
  String toString() {
    return 'SingleTeamSeasonPlayerDeleted{season: $seasonPlayer}';
  }
}

abstract class SingleTeamSeasonPlayerEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamSeasonPlayerUpdate extends SingleTeamSeasonPlayerEvent {
  final SeasonPlayer player;

  SingleTeamSeasonPlayerUpdate({@required this.player});
}

class _SingleTeamNewTeamSeasonPlayer extends SingleTeamSeasonPlayerEvent {
  final SeasonPlayer newPlayer;

  _SingleTeamNewTeamSeasonPlayer({@required this.newPlayer});
}

class _SingleTeamSeasonPlayerDeleted extends SingleTeamSeasonPlayerEvent {
  _SingleTeamSeasonPlayerDeleted();
}

class SingleTeamSeasonPlayerDelete extends SingleTeamSeasonPlayerEvent {}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamSeasonPlayerBloc
    extends Bloc<SingleTeamSeasonPlayerEvent, SingleTeamSeasonPlayerState> {
  final TeamBloc teamBloc;
  final PlayerBloc playerBloc;
  final String teamUid;
  final String seasonUid;
  final String playerUid;

  StreamSubscription<TeamState> _teamSub;

  SingleTeamSeasonPlayerBloc(
      {this.teamBloc,
      this.playerBloc,
      this.teamUid,
      this.seasonUid,
      this.playerUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null && team.seasons.containsKey(seasonUid)) {
        Season season = team.seasons[seasonUid];

        // Only send this if the team is not the same.
        if (season.players.any((SeasonPlayer p) => p.playerUid == playerUid)) {
          SeasonPlayer player = season.players
              .firstWhere((SeasonPlayer p) => p.playerUid == playerUid);

          if (player != currentState.seasonPlayer) {
            dispatch(_SingleTeamNewTeamSeasonPlayer(newPlayer: player));
          }
        }
      } else {
        dispatch(_SingleTeamSeasonPlayerDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _teamSub?.cancel();
    _teamSub = null;
  }

  @override
  SingleTeamSeasonPlayerState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null && t.seasons.containsKey(seasonUid)) {
      Season season = t.seasons[seasonUid];
      if (season.players.any((SeasonPlayer p) => p.playerUid == playerUid)) {
        SeasonPlayer player = season.players
            .firstWhere((SeasonPlayer p) => p.playerUid == playerUid);
        if (playerBloc.currentState.getPlayer(player.playerUid) != null) {
          return SingleTeamSeasonPlayerLoaded(
              seasonPlayer: player,
              player: playerBloc.currentState.getPlayer(player.playerUid));
        } else {
          return SingleTeamSeasonPlayerLoaded(seasonPlayer: player);
        }
      }
    }
    return SingleTeamSeasonPlayerDeleted();
  }

  @override
  Stream<SingleTeamSeasonPlayerState> mapEventToState(
      SingleTeamSeasonPlayerEvent event) async* {
    if (event is _SingleTeamNewTeamSeasonPlayer) {
      yield SingleTeamSeasonPlayerLoaded(
          seasonPlayer: event.newPlayer, state: currentState);
    }

    // The team is deleted.
    if (event is _SingleTeamSeasonPlayerDeleted) {
      yield SingleTeamSeasonPlayerDeleted();
    }

    if (event is SingleTeamSeasonPlayerDelete) {
      // Do its thing and it should remove ourselves whern it saves.
      yield SingleTeamSeasonPlayerSaving(state: currentState);
      try {
        teamBloc.coordinationBloc.databaseUpdateModel
            .removePlayerFromSeason(seasonUid, playerUid);
      } catch (e) {
        yield SingleTeamSeasonPlayerSaveFailed(state: currentState, error: e);
      }
    }

    // Save the team.
    if (event is SingleTeamSeasonPlayerUpdate) {
      yield SingleTeamSeasonPlayerSaving(state: currentState);
      try {
        Team t = teamBloc.currentState.getTeam(teamUid);
        if (t != null && t.seasons.containsKey(seasonUid)) {
          Season season = t.seasons[seasonUid];
          await teamBloc.coordinationBloc.databaseUpdateModel
              .updateRoleInTeamForSeason(
                  season, event.player, event.player.role);
        }
      } catch (e) {
        yield SingleTeamSeasonPlayerSaveFailed(state: currentState, error: e);
      }
    }
  }
}
