import 'dart:async';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';
import '../playerbloc.dart';

/// The event for all the single player bloc events
abstract class SinglePlayerEvent extends Equatable {}

///
/// Updates the Player (writes it out to firebase.
///
class SinglePlayerUpdate extends SinglePlayerEvent {
  /// The player to update.
  final PlayerBuilder player;

  /// Optional image to set for the player.
  final Uint8List image;

  /// Create the update request.
  SinglePlayerUpdate({@required this.player, this.image});

  @override
  List<Object> get props => [player, image];
}

///
/// Updates the image for the Player.
///
class SinglePlayerUpdateImage extends SinglePlayerEvent {
  /// The image for the player.
  final Uint8List image;

  /// Update just just the image.
  SinglePlayerUpdateImage({@required this.image});

  @override
  List<Object> get props => [image];
}

///
/// Invites someone to be an person for this Player.
///
class SinglePlayerInviteUser extends SinglePlayerEvent {
  /// Email to invite to the player.
  final String email;

  /// The relationship the player will have with this player.
  final Relationship relationship;

  /// Create the invite to the user.
  SinglePlayerInviteUser({@required this.email, this.relationship});

  @override
  List<Object> get props => [email, relationship];
}

///
/// Delete this Player from the world.
///
class SinglePlayerDelete extends SinglePlayerEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the invites from firebase.
///
class SinglePlayerLoadInvites extends SinglePlayerEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the profile from firebase.
///
class SinglePlayerLoadProfile extends SinglePlayerEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the seasons for this player from firebase.
///
class SinglePlayerLoadSeasons extends SinglePlayerEvent {
  @override
  List<Object> get props => [];
}

///
/// Loads the media for this player from firebase.
///
class SinglePlayerLoadMedia extends SinglePlayerEvent {
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

class _SinglePlayerSeasonsAdded extends SinglePlayerEvent {
  final Iterable<Season> seasons;

  _SinglePlayerSeasonsAdded({@required this.seasons});

  @override
  List<Object> get props => [seasons];
}

class _SinglePlayerMediaAdded extends SinglePlayerEvent {
  final BuiltList<MediaInfo> media;

  _SinglePlayerMediaAdded({@required this.media});

  @override
  List<Object> get props => [media];
}

///
/// Bloc to handle updates and state of a specific Player.
///
class SinglePlayerBloc
    extends AsyncHydratedBloc<SinglePlayerEvent, SinglePlayerState> {
  /// The player uid to use to find the data.
  final String playerUid;

  /// The database to get the data from.
  final DatabaseUpdateModel db;

  /// Where to report crashes.
  final AnalyticsSubsystem crashes;

  StreamSubscription<Player> _playerSub;
  StreamSubscription<Iterable<InviteToPlayer>> _inviteSub;
  StreamSubscription<Iterable<Season>> _seasonSub;
  StreamSubscription<BuiltList<MediaInfo>> _mediaSub;

  /// Create the single player bloc to load the data for the player.
  SinglePlayerBloc(
      {@required this.db,
      @required this.playerUid,
      @required this.crashes,
      @required PlayerBloc playerBloc})
      : super(_getInitialState(playerUid, playerBloc), playerUid) {
    _playerSub = db.getPlayerDetails(playerUid).listen((data) {
      if (data == null) {
        print('Couldn\'t find $playerUid');
        add(_SinglePlayerDeleted());
      } else {
        add(_SinglePlayerNewPlayer(newPlayer: data));
      }
    });
    _playerSub.onError((e, stack) => crashes.recordException(e, stack));
  }

  static SinglePlayerState _getInitialState(String uid, PlayerBloc playerBloc) {
    final player = playerBloc?.getPlayer(uid);
    if (player == null) {
      return SinglePlayerUninitialized();
    }
    return SinglePlayerLoaded((b) => b..player = player.toBuilder());
  }

  // Load this id from the hydratedBloc
  @override
  String get id => playerUid;

  @override
  Future<void> close() async {
    await super.close();
    await _playerSub?.cancel();
    await _inviteSub?.cancel();
  }

  @override
  Stream<SinglePlayerState> mapEventToState(SinglePlayerEvent event) async* {
    if (event is _SinglePlayerNewPlayer) {
      yield (SinglePlayerLoaded.fromState(state)
            ..player = event.newPlayer.toBuilder()
            ..mePlayer = event.newPlayer.uid == db.currentUser?.uid)
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
          final url = await db.updatePlayerImage(event.player.uid, event.image);
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
            ..loadedInvites = true)
          .build();
    }

    if (event is _SinglePlayerSeasonsAdded) {
      yield (SinglePlayerLoaded.fromState(state)
            ..player = state.player.toBuilder()
            ..seasons = ListBuilder(event.seasons)
            ..loadedSeasons = true)
          .build();
    }

    if (event is _SinglePlayerMediaAdded) {
      yield (SinglePlayerLoaded.fromState(state)
            ..media = ListBuilder(event.media)
            ..loadedMedia = true)
          .build();
    }

    if (event is SinglePlayerLoadInvites) {
      if (_inviteSub == null) {
        _inviteSub = db
            .getInviteForPlayerStream(playerUid: state.player.uid)
            .listen((Iterable<InviteToPlayer> invites) {
          add(_SinglePlayerInvitesAdded(invites: invites));
        });
        _inviteSub.onError((e, stack) => crashes.recordException(e, stack));
      }
    }
    if (event is SinglePlayerLoadSeasons) {
      if (_seasonSub == null) {
        _seasonSub = db.getPlayerSeasons(state.player.uid).listen((seasons) {
          add(_SinglePlayerSeasonsAdded(seasons: seasons));
        });
        _seasonSub.onError((e, stack) => crashes.recordException(e, stack));
      }
    }
    if (event is SinglePlayerLoadMedia) {
      if (_mediaSub == null) {
        _mediaSub =
            db.getMediaForPlayer(playerUid: state.player.uid).listen((media) {
          add(_SinglePlayerMediaAdded(media: media));
        });
        _mediaSub.onError((e, stack) => crashes.recordException(e, stack));
      }
    }
  }

  @override
  SinglePlayerState fromJson(Map<String, dynamic> json) {
    if (!(state is SinglePlayerUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return SinglePlayerUninitialized();
    }

    try {
      var type = SinglePlayerBlocStateType.valueOf(json['type']);
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
