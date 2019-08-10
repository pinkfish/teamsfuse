import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../playerbloc.dart';

abstract class SinglePlayerState extends Equatable {
  final Player player;
  final bool mePlayer;
  final bool invitesLoaded;
  final List<InviteToPlayer> invites;

  SinglePlayerState(
      {@required this.player,
      @required this.mePlayer,
      @required this.invites,
      @required this.invitesLoaded});

  SinglePlayerState.fromState(SinglePlayerState state)
      : mePlayer = state.mePlayer,
        player = state.player,
        invitesLoaded = state.invitesLoaded,
        invites = state.invites;
}

///
/// We have a Player, default state.
///
class SinglePlayerLoaded extends SinglePlayerState {
  SinglePlayerLoaded(
      {@required SinglePlayerState state,
      Player player,
      bool mePlayer,
      List<InviteToPlayer> invites,
      bool invitesLoaded,
      FusedUserProfile profile})
      : super(
            player: player ?? state.player,
            mePlayer: mePlayer ?? state.mePlayer,
            invites: invites ?? state.invites,
            invitesLoaded: invitesLoaded ?? state.invitesLoaded);

  @override
  String toString() {
    return 'SinglePlayerLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SinglePlayerSaving extends SinglePlayerState {
  SinglePlayerSaving({@required SinglePlayerState state})
      : super.fromState(state);

  @override
  String toString() {
    return 'SinglePlayerSaving{}';
  }
}

///
/// Saving operation is done.
///
class SinglePlayerSaveDone extends SinglePlayerState {
  SinglePlayerSaveDone({@required SinglePlayerState state})
      : super.fromState(state);

  @override
  String toString() {
    return 'SinglePlayerSaveDone{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SinglePlayerSaveFailed extends SinglePlayerState {
  final Error error;

  SinglePlayerSaveFailed(
      {@required SinglePlayerState state, @required this.error})
      : super.fromState(state);

  @override
  String toString() {
    return 'SinglePlayerSaveFailed{}';
  }
}

///
/// Player got deleted.
///
class SinglePlayerDeleted extends SinglePlayerState {
  SinglePlayerDeleted()
      : super(player: null, invites: [], invitesLoaded: false, mePlayer: false);

  @override
  String toString() {
    return 'SinglePlayerDeleted{}';
  }
}

abstract class SinglePlayerEvent extends Equatable {}

///
/// Updates the Player (writes it out to firebase.
///
class SinglePlayerUpdate extends SinglePlayerEvent {
  final PlayerBuilder player;
  final File image;

  SinglePlayerUpdate({@required this.player, this.image});
}

///
/// Updates the image for the Player.
///
class SinglePlayerUpdateImage extends SinglePlayerEvent {
  final File image;

  SinglePlayerUpdateImage({@required this.image});
}

///
/// Invites someone to be an person for this Player.
///
class SinglePlayerInviteUser extends SinglePlayerEvent {
  final String email;
  final Relationship relationship;

  SinglePlayerInviteUser({@required this.email, this.relationship});
}

///
/// Delete this Player from the world.
///
class SinglePlayerDelete extends SinglePlayerEvent {
  SinglePlayerDelete();
}

///
/// Loads the invites from firebase.
///
class SinglePlayerLoadInvites extends SinglePlayerEvent {
  SinglePlayerLoadInvites();
}

///
/// Loads the profile from firebase.
///
class SinglePlayerLoadProfile extends SinglePlayerEvent {
  SinglePlayerLoadProfile();
}

class _SinglePlayerNewPlayer extends SinglePlayerEvent {
  final Player newPlayer;

  _SinglePlayerNewPlayer({@required this.newPlayer});
}

class _SinglePlayerDeleted extends SinglePlayerEvent {
  _SinglePlayerDeleted();
}

class _SinglePlayerInvitesAdded extends SinglePlayerEvent {
  final Iterable<InviteToPlayer> invites;

  _SinglePlayerInvitesAdded({@required this.invites});
}

///
/// Bloc to handle updates and state of a specific Player.
///
class SinglePlayerBloc extends Bloc<SinglePlayerEvent, SinglePlayerState> {
  final PlayerBloc playerBloc;
  final String playerUid;

  StreamSubscription<PlayerState> _playerSub;
  StreamSubscription<Iterable<InviteToPlayer>> _inviteSub;

  SinglePlayerBloc({@required this.playerBloc, @required this.playerUid}) {
    _playerSub = playerBloc.state.listen((PlayerState state) {
      if (state.players.containsKey(playerUid)) {
        Player player = state.players[playerUid];
        // Only send this if the Player is not the same.
        if (Player != currentState.player) {
          dispatch(_SinglePlayerNewPlayer(newPlayer: player));
        }
      } else {
        dispatch(_SinglePlayerDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _playerSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  SinglePlayerState get initialState {
    if (playerBloc.currentState.players.containsKey(playerUid)) {
      return SinglePlayerLoaded(
          player: playerBloc.currentState.players[playerUid],
          invites: [],
          state: null,
          invitesLoaded: false);
    } else {
      return SinglePlayerDeleted();
    }
  }

  @override
  Stream<SinglePlayerState> mapEventToState(SinglePlayerEvent event) async* {
    if (event is _SinglePlayerNewPlayer) {
      yield SinglePlayerLoaded(
          state: currentState,
          player: event.newPlayer,
          mePlayer: event.newPlayer.uid == playerBloc.currentState.me.uid);
    }

    // The Player is deleted.
    if (event is _SinglePlayerDeleted) {
      yield SinglePlayerDeleted();
    }

    // Save the Player.
    if (event is SinglePlayerUpdate) {
      yield SinglePlayerSaving(state: currentState);

      try {
        if (event.image != null) {
          var url = await playerBloc.coordinationBloc.databaseUpdateModel
              .updatePlayerImage(event.player.uid, event.image);
          event.player.photoUrl = url.toString();
        }
        await playerBloc.coordinationBloc.databaseUpdateModel
            .updateFirestorePlayer(event.player.build(), false);
        yield SinglePlayerSaveDone(state: currentState);
        yield SinglePlayerLoaded(
            state: currentState,
            player: event.player.build(),
            mePlayer: event.player.uid == playerBloc.currentState.me.uid);
      } catch (e) {
        yield SinglePlayerSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SinglePlayerInviteUser) {
      yield SinglePlayerSaving(state: currentState);
      try {
        await playerBloc.coordinationBloc.databaseUpdateModel
            .inviteUserToPlayer(
                playerUid: playerUid,
                email: event.email,
                playerName: currentState.player.name);
        yield SinglePlayerSaveDone(state: currentState);
        yield SinglePlayerLoaded(state: currentState);
      } catch (e) {
        yield SinglePlayerSaveFailed(state: currentState, error: e);
      }
    }

    if (event is _SinglePlayerInvitesAdded) {
      yield SinglePlayerLoaded(
          state: currentState,
          player: currentState.player,
          invites: event.invites,
          invitesLoaded: true);
    }

    if (event is SinglePlayerLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = playerBloc.coordinationBloc.databaseUpdateModel
            .getInviteForPlayerStream(playerUid: currentState.player.uid)
            .listen((Iterable<InviteToPlayer> invites) {
          dispatch(_SinglePlayerInvitesAdded(invites: invites));
        });
      }
    }
  }
}
