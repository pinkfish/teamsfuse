import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

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
    extends AsyncHydratedBloc<SinglePlayerEvent, SinglePlayerState> {
  final String playerUid;
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;

  StreamSubscription<Player> _playerSub;
  StreamSubscription<Iterable<InviteToPlayer>> _inviteSub;

  SinglePlayerBloc(
      {@required this.db, @required this.playerUid, @required this.crashes})
      : super(SinglePlayerUninitialized(), playerUid) {
    _playerSub = db.getPlayerDetails(playerUid).listen((data) {
      if (data == null) {
        print("Couldnt find $playerUid");
        add(_SinglePlayerDeleted());
      } else {
        add(_SinglePlayerNewPlayer(newPlayer: data));
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
            ..mePlayer = event.newPlayer.uid == db.currentUser.uid)
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
          var url = await db.updatePlayerImage(
              event.player.uid, await event.image.readAsBytes());
          event.player.photoUrl = url.toString();
        }
        await db.updateFirestorePlayer(event.player.build(), false);
        yield SinglePlayerSaveDone.fromState(state).build();
        yield (SinglePlayerLoaded.fromState(state)
              ..player = event.player
              ..mePlayer = event.player.uid == db.currentUser.uid)
            .build();
      } catch (e, stack) {
        yield (SinglePlayerSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SinglePlayerLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SinglePlayerInviteUser) {
      yield SinglePlayerSaving.fromState(state).build();
      try {
        await db.inviteUserToPlayer(
            playerUid: playerUid,
            email: event.email,
            playerName: state.player.name,
            myUid: db.currentUser.uid);
        yield SinglePlayerSaveDone.fromState(state).build();
        yield SinglePlayerLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SinglePlayerSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SinglePlayerLoaded.fromState(state).build();
        crashes.recordException(e, stack);
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
        _inviteSub = db
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

    try {
      SinglePlayerBlocStateType type =
          SinglePlayerBlocStateType.valueOf(json["type"]);
      switch (type) {
        case SinglePlayerBlocStateType.Uninitialized:
          return SinglePlayerUninitialized();
        case SinglePlayerBlocStateType.Loaded:
          return SinglePlayerLoaded.fromMap(json);
        case SinglePlayerBlocStateType.Deleted:
          print("Loading as deleted? $playerUid");
          return SinglePlayerDeleted.fromMap(json);
        case SinglePlayerBlocStateType.SaveFailed:
          return SinglePlayerSaveFailed.fromMap(json);
        case SinglePlayerBlocStateType.Saving:
          return SinglePlayerSaving.fromMap(json);
        case SinglePlayerBlocStateType.SaveDone:
          return SinglePlayerSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SinglePlayerUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SinglePlayerState state) {
    return state.toMap();
  }
}
