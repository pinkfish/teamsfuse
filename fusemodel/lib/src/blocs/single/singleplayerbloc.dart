import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../data/playerblocstate.dart';
import '../playerbloc.dart';

abstract class SinglePlayerState extends Equatable {
  final Player player;
  final bool mePlayer;
  final bool invitesLoaded;
  final BuiltList<InviteToPlayer> invites;

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

  @override
  List<Object> get props => [player, invites, invitesLoaded, mePlayer];
}

///
/// We have a Player, default state.
///
class SinglePlayerLoaded extends SinglePlayerState {
  SinglePlayerLoaded(
      {@required SinglePlayerState state,
      Player player,
      bool mePlayer,
      BuiltList<InviteToPlayer> invites,
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
      : super(
            player: null,
            invites: BuiltList(),
            invitesLoaded: false,
            mePlayer: false);

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

  @override
  List<Object> get props => [player, image];
}

///
/// Updates the image for the Player.
///
class SinglePlayerUpdateImage extends SinglePlayerEvent {
  final File image;

  SinglePlayerUpdateImage({@required this.image});

  @override
  List<Object> get props => [image];
}

///
/// Invites someone to be an person for this Player.
///
class SinglePlayerInviteUser extends SinglePlayerEvent {
  final String email;
  final Relationship relationship;

  SinglePlayerInviteUser({@required this.email, this.relationship});

  @override
  List<Object> get props => [email, relationship];
}

///
/// Delete this Player from the world.
///
class SinglePlayerDelete extends SinglePlayerEvent {
  SinglePlayerDelete();

  @override
  List<Object> get props => [];
}

///
/// Loads the invites from firebase.
///
class SinglePlayerLoadInvites extends SinglePlayerEvent {
  SinglePlayerLoadInvites();

  @override
  List<Object> get props => [];
}

///
/// Loads the profile from firebase.
///
class SinglePlayerLoadProfile extends SinglePlayerEvent {
  SinglePlayerLoadProfile();

  @override
  List<Object> get props => [];
}

class _SinglePlayerNewPlayer extends SinglePlayerEvent {
  final Player newPlayer;

  _SinglePlayerNewPlayer({@required this.newPlayer});

  @override
  List<Object> get props => [newPlayer];
}

class _SinglePlayerDeleted extends SinglePlayerEvent {
  _SinglePlayerDeleted();

  @override
  List<Object> get props => [];
}

class _SinglePlayerInvitesAdded extends SinglePlayerEvent {
  final Iterable<InviteToPlayer> invites;

  _SinglePlayerInvitesAdded({@required this.invites});

  @override
  List<Object> get props => [invites];
}

///
/// Bloc to handle updates and state of a specific Player.
///
class SinglePlayerBloc extends Bloc<SinglePlayerEvent, SinglePlayerState> {
  final PlayerBloc playerBloc;
  final String playerUid;

  StreamSubscription<PlayerState> _playerSub;
  StreamSubscription<Iterable<InviteToPlayer>> _inviteSub;

  SinglePlayerBloc({@required this.playerBloc, @required this.playerUid})
      : super(playerBloc.state.players.containsKey(playerUid)
            ? SinglePlayerLoaded(
                player: playerBloc.state.players[playerUid],
                invites: BuiltList(),
                state: null,
                mePlayer: playerBloc.state.me?.uid == playerUid,
                invitesLoaded: false)
            : SinglePlayerDeleted()) {
    _playerSub = playerBloc.listen((PlayerState playerState) {
      if (playerState.players.containsKey(playerUid)) {
        Player player = playerState.players[playerUid];
        // Only send this if the Player is not the same.
        if (Player != state.player) {
          add(_SinglePlayerNewPlayer(newPlayer: player));
        }
      } else {
        add(_SinglePlayerDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _playerSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  Stream<SinglePlayerState> mapEventToState(SinglePlayerEvent event) async* {
    if (event is _SinglePlayerNewPlayer) {
      yield SinglePlayerLoaded(
          state: state,
          player: event.newPlayer,
          mePlayer: event.newPlayer.uid == playerBloc.state.me.uid);
    }

    // The Player is deleted.
    if (event is _SinglePlayerDeleted) {
      yield SinglePlayerDeleted();
    }

    // Save the Player.
    if (event is SinglePlayerUpdate) {
      yield SinglePlayerSaving(state: state);

      try {
        if (event.image != null) {
          var url = await playerBloc.coordinationBloc.databaseUpdateModel
              .updatePlayerImage(event.player.uid, event.image);
          event.player.photoUrl = url.toString();
        }
        await playerBloc.coordinationBloc.databaseUpdateModel
            .updateFirestorePlayer(event.player.build(), false);
        yield SinglePlayerSaveDone(state: state);
        yield SinglePlayerLoaded(
            state: state,
            player: event.player.build(),
            mePlayer: event.player.uid == playerBloc.state.me.uid);
      } catch (e) {
        yield SinglePlayerSaveFailed(state: state, error: e);
      }
    }

    if (event is SinglePlayerInviteUser) {
      yield SinglePlayerSaving(state: state);
      try {
        await playerBloc.coordinationBloc.databaseUpdateModel
            .inviteUserToPlayer(
                playerUid: playerUid,
                email: event.email,
                playerName: state.player.name,
                myUid: playerBloc.coordinationBloc.state.uid);
        yield SinglePlayerSaveDone(state: state);
        yield SinglePlayerLoaded(state: state);
      } catch (e) {
        yield SinglePlayerSaveFailed(state: state, error: e);
      }
    }

    if (event is _SinglePlayerInvitesAdded) {
      yield SinglePlayerLoaded(
          state: state,
          player: state.player,
          invites: BuiltList.from(event.invites),
          invitesLoaded: true);
    }

    if (event is SinglePlayerLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = playerBloc.coordinationBloc.databaseUpdateModel
            .getInviteForPlayerStream(playerUid: state.player.uid)
            .listen((Iterable<InviteToPlayer> invites) {
          add(_SinglePlayerInvitesAdded(invites: invites));
        });
      }
    }
  }
}
