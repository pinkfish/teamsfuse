import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import '../data/playerblocstate.dart';
import '../playerbloc.dart';
import 'data/singleplayerbloc.dart';

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
class SinglePlayerBloc
    extends HydratedBloc<SinglePlayerEvent, SinglePlayerState> {
  final PlayerBloc playerBloc;
  final String playerUid;

  StreamSubscription<PlayerState> _playerSub;
  StreamSubscription<Iterable<InviteToPlayer>> _inviteSub;

  SinglePlayerBloc({@required this.playerBloc, @required this.playerUid})
      : super((playerBloc.state.players.containsKey(playerUid)
            ? (SinglePlayerLoadedBuilder()
                  ..player = playerBloc.state.players[playerUid].toBuilder()
                  ..mePlayer = playerBloc.state.me?.uid == playerUid
                  ..invitesLoaded = false)
                .build()
            : SinglePlayerDeletedBuilder().build())) {
    _playerSub = playerBloc.listen((PlayerState playerState) {
      if (playerState.players.containsKey(playerUid)) {
        var player = playerState.players[playerUid];
        // Only send this if the Player is not the same.
        if (player != state.player) {
          add(_SinglePlayerNewPlayer(newPlayer: player));
        }
      } else {
        add(_SinglePlayerDeleted());
      }
    });
  }

  // Load this id from the hydratedBloc
  @override
  String get id => playerUid;

  @override
  Future<void> close() async {
    await super.close();
    _playerSub?.cancel();
    _inviteSub?.cancel();
  }

  @override
  Stream<SinglePlayerState> mapEventToState(SinglePlayerEvent event) async* {
    if (event is _SinglePlayerNewPlayer) {
      yield (SinglePlayerLoaded.fromState(state)
            ..player = event.newPlayer.toBuilder()
            ..mePlayer = event.newPlayer.uid == playerBloc.state.me.uid)
          .build();
    }

    // The Player is deleted.
    if (event is _SinglePlayerDeleted) {
      yield SinglePlayerDeleted();
    }

    // Save the Player.
    if (event is SinglePlayerUpdate) {
      yield SinglePlayerSaving.fromState(state).build();

      try {
        if (event.image != null) {
          var url = await playerBloc.coordinationBloc.databaseUpdateModel
              .updatePlayerImage(event.player.uid, event.image);
          event.player.photoUrl = url.toString();
        }
        await playerBloc.coordinationBloc.databaseUpdateModel
            .updateFirestorePlayer(event.player.build(), false);
        yield SinglePlayerSaveDone.fromState(state).build();
        yield (SinglePlayerLoaded.fromState(state)
              ..player = event.player
              ..mePlayer = event.player.uid == playerBloc.state.me.uid)
            .build();
      } catch (e) {
        yield (SinglePlayerSaveFailed.fromState(state)..error = e).build();
      }
    }

    if (event is SinglePlayerInviteUser) {
      yield SinglePlayerSaving.fromState(state).build();
      try {
        await playerBloc.coordinationBloc.databaseUpdateModel
            .inviteUserToPlayer(
                playerUid: playerUid,
                email: event.email,
                playerName: state.player.name,
                myUid: playerBloc.coordinationBloc.state.uid);
        yield SinglePlayerSaveDone.fromState(state).build();
        yield SinglePlayerLoaded.fromState(state).build();
      } catch (e) {
        yield (SinglePlayerSaveFailed.fromState(state)..error = e).build();
      }
    }

    if (event is _SinglePlayerInvitesAdded) {
      yield (SinglePlayerLoaded.fromState(state)
            ..player = state.player.toBuilder()
            ..invites = ListBuilder(event.invites)
            ..invitesLoaded = true)
          .build();
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

  @override
  SinglePlayerState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return SinglePlayerUninitialized();
    }

    SinglePlayerBlocStateType type =
        SinglePlayerBlocStateType.valueOf(json["type"]);
    switch (type) {
      case SinglePlayerBlocStateType.Uninitialized:
        return SinglePlayerUninitialized();
      case SinglePlayerBlocStateType.Loaded:
        return SinglePlayerLoaded.fromMap(json);
      case SinglePlayerBlocStateType.Deleted:
        return SinglePlayerDeleted.fromMap(json);
      case SinglePlayerBlocStateType.SaveFailed:
        return SinglePlayerSaveFailed.fromMap(json);
      case SinglePlayerBlocStateType.Saving:
        return SinglePlayerSaving.fromMap(json);
      case SinglePlayerBlocStateType.SaveDone:
        return SinglePlayerSaveDone.fromMap(json);
    }
    return SinglePlayerUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SinglePlayerState state) {
    return state.toMap();
  }
}
