import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class PlayerEvent extends Equatable {}

class _PlayerFirestore extends PlayerEvent {
  _PlayerFirestore();

  @override
  String toString() {
    return '_PlayerFirestore{}';
  }

  @override
  List<Object> get props => [];
}

class _PlayerLoadedExtra extends PlayerEvent {
  final String playerUid;
  final Player player;

  _PlayerLoadedExtra({@required this.playerUid, @required this.player});

  @override
  List<Object> get props => [playerUid, player];
}

class _PlayerLoggedOut extends PlayerEvent {
  @override
  List<Object> get props => [];
}

class _PlayerNewPlayersLoaded extends PlayerEvent {
  final BuiltMap<String, Player> players;
  final Set<String> deleted;
  final Player me;

  _PlayerNewPlayersLoaded(
      {@required this.players, @required this.deleted, @required this.me});

  @override
  List<Object> get props => [players, deleted, me];
}

///
/// Player bloc handles the player flow.  Loading all the players from
/// firestore.
///
class PlayerBloc extends HydratedBloc<PlayerEvent, PlayerState> {
  final CoordinationBloc coordinationBloc;
  final AnalyticsSubsystem crashes;

  StreamSubscription<Iterable<Player>> _playerSnapshot;
  bool _createdMePlayer = false;
  StreamSubscription<CoordinationState> _authSub;

  bool _loadingFirestore = false;

  PlayerBloc({@required this.coordinationBloc, @required this.crashes})
      : super(PlayerUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Player));
    _authSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_PlayerLoggedOut());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        _startLoadingFirestore(coordState);
      }
    });
    if (coordinationBloc.state is CoordinationStateLoadingFirestore) {
      _startLoadingFirestore(coordinationBloc.state);
    }
  }

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    if (!_loadingFirestore) {
      _loadingFirestore = true;
      add(_PlayerFirestore());
    }
  }

  @override
  Future<void> close() {
    _playerSnapshot?.cancel();
    _authSub?.cancel();
    return super.close();
  }

  void _onPlayerUpdated(Iterable<Player> data) {
    Set<String> toDeletePlayers = Set<String>();
    bool foundMe = false;
    MapBuilder<String, Player> players = state.players.toBuilder();
    Player me;

    toDeletePlayers.addAll(state.players.keys);
    for (Player player in data) {
      String uid = coordinationBloc.state.uid;
      if (player.users[uid].relationship == Relationship.Me) {
        if (foundMe) {
          if (player.users.length <= 1) {
            coordinationBloc.databaseUpdateModel.deletePlayer(player.uid);
          }
        }

        foundMe = true;
        me = player;
      }
      players[player.uid] = player;
      toDeletePlayers.remove(player.uid);
    }
    toDeletePlayers.forEach((String id) {
      players.remove(id);
    });
    if (!foundMe && !_createdMePlayer) {
      PlayerUserInternal playerUser = PlayerUserInternal((b) => b
        ..added = true
        ..relationship = Relationship.Me);
      PlayerBuilder player = PlayerBuilder()
        ..uid = ''
        ..playerType = PlayerType.player;
      player.usersData[coordinationBloc.authenticationBloc.currentUser.uid] =
          playerUser;
      player.name = coordinationBloc
              .authenticationBloc.currentUser.profile?.displayName ??
          'Frog';
      _createdMePlayer = true;
      me = player.build();
      coordinationBloc.databaseUpdateModel
          .addFirestorePlayer(player.build())
          .then((void val) {})
          .catchError((dynamic e, StackTrace trace) {
        return e;
      });
    }
    coordinationBloc
        .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Player));
    add(_PlayerNewPlayersLoaded(
        players: players.build(), deleted: toDeletePlayers, me: me));
  }

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    if (event is _PlayerFirestore) {
      // Load from firestore.
      _playerSnapshot = coordinationBloc.databaseUpdateModel
          .getPlayers()
          .listen((Iterable<Player> players) {
        this._onPlayerUpdated(players);
      });
    }

    // Unload everything.
    if (event is _PlayerLoggedOut) {
      yield PlayerUninitialized();
      _playerSnapshot?.cancel();
      _playerSnapshot = null;
    }

    // Update the data from an event.
    if (event is _PlayerNewPlayersLoaded) {
      yield (PlayerLoaded.fromState(state)
            ..players = event.players.toBuilder()
            ..loadedFirestore = true
            ..me = event.me.toBuilder())
          .build();
      coordinationBloc
          .add(CoordinationEventLoadedData(loaded: BlocsToLoad.Player));
    }

    if (event is _PlayerLoadedExtra) {
      MapBuilder<String, Player> extras = state.extraPlayers.toBuilder();
      extras[event.playerUid] = event.player;
      yield (PlayerLoaded.fromState(state)..extraPlayers = extras).build();
    }
  }

  @override
  PlayerState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey('type')) {
      return PlayerUninitialized();
    }

    PlayerBlocStateType type = PlayerBlocStateType.valueOf(json['type']);
    switch (type) {
      case PlayerBlocStateType.Uninitialized:
        return PlayerUninitialized();
      case PlayerBlocStateType.Loaded:
        try {
          TraceProxy playerTrace =
              coordinationBloc.analytics.newTrace('playerData');
          playerTrace.start();
          var loaded = PlayerLoaded.fromMap(json);
          playerTrace.stop();
          return loaded;
        } catch (e, stacktrace) {
          if (e is Error) {
            crashes.recordError(e, stacktrace);
          } else {
            crashes.recordException(e, stacktrace);
          }
        }
        return PlayerUninitialized();
      default:
        return PlayerUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(PlayerState state) {
    return state.toMap();
  }
}
