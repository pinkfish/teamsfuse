import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'coordinationbloc.dart';
import 'internal/blocstoload.dart';

abstract class PlayerEvent extends Equatable {}

class _PlayerUserLoaded extends PlayerEvent {
  _PlayerUserLoaded();

  @override
  String toString() {
    return '_PlayerUserLoaded{}';
  }

  @override
  List<Object> get props => [];
}

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
/// Basic state for all the player states.
///
abstract class PlayerState extends Equatable {
  final BuiltMap<String, Player> players;
  final BuiltMap<String, Player> extraPlayers;
  final Player me;
  final bool onlySql;

  PlayerState(
      {@required this.players,
      @required this.onlySql,
      @required this.me,
      @required this.extraPlayers});

  ///
  /// Look up the specific player in the current state.
  ///
  Player getPlayer(String uid) {
    if (players.containsKey(uid)) {
      return players[uid];
    }
    if (extraPlayers.containsKey(uid)) {
      return extraPlayers[uid];
    }
    return null;
  }

  @override
  List<Object> get props => [players, extraPlayers, me, onlySql];
}

///
/// Data is currently leading, although there is also data in here
/// possibly too.
///
class PlayerLoading extends PlayerState {
  PlayerLoading(
      {@required PlayerState playerState,
      BuiltMap<String, Player> players,
      BuiltMap<String, Player> extraPlayers,
      Player me,
      bool onlySql})
      : super(
            players: players ?? playerState.players,
            onlySql: onlySql ?? playerState.onlySql,
            me: me ?? playerState.me,
            extraPlayers: extraPlayers ?? playerState.extraPlayers);

  @override
  String toString() {
    return 'PlayerLoading{players: ${players.length}, onlySql: $onlySql}';
  }
}

///
/// No data at all, we are uninitialized.
///
class PlayerUninitialized extends PlayerState {
  PlayerUninitialized()
      : super(
            players: BuiltMap(),
            extraPlayers: BuiltMap(),
            onlySql: true,
            me: null);

  @override
  String toString() {
    return 'PlayerUninitialized{players: ${players.length}, onlySql: $onlySql}';
  }
}

///
/// Player data is loaded and everything is fluffy.
///
class PlayerLoaded extends PlayerState {
  PlayerLoaded(
      {@required PlayerState playerState,
      BuiltMap<String, Player> players,
      BuiltMap<String, Player> extraPlayers,
      Player me,
      bool onlySql})
      : super(
            players: players ?? playerState.players,
            me: me ?? playerState.me,
            onlySql: onlySql ?? playerState.onlySql,
            extraPlayers: extraPlayers ?? playerState.extraPlayers);

  @override
  String toString() {
    return 'PlayerLoaded{players.length: ${players.length}, extraPlayers.length: ${extraPlayers?.length}, me: $me, onlySql: $onlySql}';
  }
}

///
/// Player bloc handles the player flow.  Loading all the players from
/// firestore.
///
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<Iterable<Player>> _playerSnapshot;
  bool _createdMePlayer = false;
  StreamSubscription<CoordinationState> _authSub;

  bool _loadingSql = false;
  bool _loadingFirestore = false;

  PlayerBloc({
    @required this.coordinationBloc,
  }) : super(PlayerUninitialized()) {
    coordinationBloc
        .add(CoordinationEventTrackLoading(toLoad: BlocsToLoad.Player));

    _authSub = coordinationBloc.listen((CoordinationState coordState) {
      if (coordState is CoordinationStateLoggedOut) {
        _loadingFirestore = false;
        _loadingSql = false;
        add(_PlayerLoggedOut());
      } else if (coordState is CoordinationStateLoadingSql) {
        if (!_loadingSql) {
          _loadingSql = true;
          _startLoading(coordState);
        }
      } else if (coordState is CoordinationStateLoadingFirestore) {
        if (!_loadingFirestore) {
          _loadingFirestore = true;
          _startLoadingFirestore(coordState);
        }
      }
    });
  }

  void _startLoading(CoordinationStateLoadingSql state) {
    add(_PlayerUserLoaded());
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
    if (event is _PlayerUserLoaded) {
      yield PlayerLoading(playerState: state, onlySql: true);
      TraceProxy playerTrace =
          coordinationBloc.analyticsSubsystem.newTrace("playerData");
      playerTrace.start();
      Map<String, Map<String, dynamic>> data = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.playersTable);
      Map<String, Player> newPlayers = new Map<String, Player>();
      Player me;
      String userUid = coordinationBloc.state.uid;

      data.forEach((String uid, Map<String, dynamic> input) {
        coordinationBloc.sqlTrace?.incrementCounter("player");
        playerTrace.incrementCounter("player");
        Player player = Player.fromJSON(uid, input).build();
        newPlayers[uid] = player;
        if (player.users[userUid].relationship == Relationship.Me) {
          me = player;
        }
      });
      print(
          'End players ${coordinationBloc.start.difference(new DateTime.now())}');
      playerTrace.stop();
      yield PlayerLoaded(
          playerState: state,
          players: BuiltMap.from(newPlayers),
          onlySql: true,
          me: me);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Player, sql: true));
    }

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
      yield PlayerLoaded(
          playerState: state,
          players: event.players,
          onlySql: false,
          me: event.me);
      coordinationBloc.add(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Player, sql: false));
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
      yield PlayerLoaded(playerState: state, extraPlayers: extras.build());
    }
  }
}
