import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'data/playerblocstate.dart';
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

///
/// Loads the specific details of this player.
///
class PlayerLoadPlayer extends PlayerEvent {
  final String playerUid;

  PlayerLoadPlayer({@required this.playerUid});

  @override
  List<Object> get props => [playerUid];
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

  StreamSubscription<Iterable<Player>> _playerSnapshot;
  bool _createdMePlayer = false;
  StreamSubscription<CoordinationState> _authSub;

  bool _loadingFirestore = false;

  PlayerBloc({
    @required this.coordinationBloc,
  }) : super(PlayerUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Player));

    _authSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        add(_PlayerLoggedOut());
      } else if (coordState is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;
          _startLoadingFirestore(coordState);
        }
      }
    });
  }

  void _startLoadingFirestore(CoordinationStateLoadingFirestore state) {
    add(_PlayerFirestore());
  }

  @override
  Future<void> close() {
    _playerSnapshot?.cancel();
    _authSub?.cancel();
    return super.close();
  }

  void _onPlayerUpdated(Iterable<Player> data) {
    Set<String> toDeletePlayers = new Set<String>();
    bool foundMe = false;
    MapBuilder<String, Player> players = state.players.toBuilder();
    Player me;

    toDeletePlayers.addAll(state.players.keys);
    for (Player player in data) {
      String uid = coordinationBloc.state.uid;
      print("Data $player $uid");
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
      coordinationBloc.persistentData.updateElement(PersistenData.playersTable,
          player.uid, player.toJSON(includeUsers: true));
    }
    toDeletePlayers.forEach((String id) {
      players.remove(id);
      coordinationBloc.persistentData
          .deleteElement(PersistenData.playersTable, id);
    });
    if (data.length == 0) {
      if (!foundMe && !_createdMePlayer) {
        print('Docs are empty');
        PlayerUser playerUser = new PlayerUser((b) => b
          ..userUid = coordinationBloc.authenticationBloc.currentUser.uid
          ..relationship = Relationship.Me);
        PlayerBuilder player = PlayerBuilder();
        player.users[playerUser.userUid] = playerUser;
        player.name = coordinationBloc
                .authenticationBloc.currentUser.profile?.displayName ??
            "Frog";
        print('Updating firestore');
        _createdMePlayer = true;
        me = player.build();
        coordinationBloc.databaseUpdateModel
            .updateFirestorePlayer(player.build(), true)
            .then((void val) {
          print('Done!');
        }).catchError((dynamic e, StackTrace trace) {
          print('Setting up snap with players $trace');
          return e;
        });
      } else {
        print('Loaded for fluff');
      }
    }
    add(_PlayerNewPlayersLoaded(
        players: players.build(), deleted: toDeletePlayers, me: me));
  }

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    if (event is _PlayerFirestore) {
      // Load from firestore.
      _playerSnapshot = coordinationBloc.databaseUpdateModel
          .getPlayers(coordinationBloc.state.uid)
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

    if (event is PlayerLoadPlayer) {
      coordinationBloc.databaseUpdateModel
          .getPlayerDetails(event.playerUid)
          .then((Player player) {
        add(_PlayerLoadedExtra(playerUid: event.playerUid, player: player));
      });
    }

    if (event is _PlayerLoadedExtra) {
      MapBuilder<String, Player> extras = state.extraPlayers.toBuilder();
      extras[event.playerUid] = event.player;
      yield (PlayerLoaded.fromState(state)..extraPlayers = extras).build();
    }
  }

  @override
  PlayerState fromJson(Map<String, dynamic> json) {
    if (json == null || !json.containsKey("type")) {
      return PlayerUninitialized();
    }

    PlayerBlocStateType type = PlayerBlocStateType.valueOf(json["type"]);
    switch (type) {
      case PlayerBlocStateType.Uninitialized:
        return PlayerUninitialized();
      case PlayerBlocStateType.Loaded:
        TraceProxy playerTrace =
            coordinationBloc.analyticsSubsystem.newTrace("playerData");
        playerTrace.start();
        var loaded = PlayerLoaded.fromMap(json);
        print(
            'End players ${coordinationBloc.start.difference(new DateTime.now())}');
        playerTrace.stop();
        return loaded;
      default:
        return PlayerUninitialized();
    }
  }

  @override
  Map<String, dynamic> toJson(PlayerState state) {
    return state.toMap();
  }
}
