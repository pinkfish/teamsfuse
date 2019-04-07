import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'internal/blocstoload.dart';
import 'coordinationbloc.dart';

class PlayerEvent extends Equatable {}

class _PlayerUserLoaded extends PlayerEvent {
  final String uid;

  _PlayerUserLoaded({
    @required this.uid,
  });

  @override
  String toString() {
    return '_PlayerUserLoaded{}';
  }
}

class _PlayerFirestore extends PlayerEvent {
  final String uid;

  _PlayerFirestore({
    @required this.uid,
  });

  @override
  String toString() {
    return '_PlayerFirestore{}';
  }
}

class _PlayerLoggedOut extends PlayerEvent {}

class _PlayerNewPlayersLoaded extends PlayerEvent {
  final Map<String, Player> players;
  final String uid;
  final Set<String> deleted;

  _PlayerNewPlayersLoaded(
      {@required this.players, @required this.uid, @required this.deleted});
}

///
/// Basic state for all the player states.
///
class PlayerState extends Equatable {
  final Map<String, Player> players;
  final String uid;
  final bool onlySql;

  PlayerState(
      {@required this.players, @required this.uid, @required this.onlySql});
}

///
/// Data is currently leading, although there is also data in here
/// possibly too.
///
class PlayerLoading extends PlayerState {
  PlayerLoading(
      {@required Map<String, Player> players,
      @required String uid,
      @required bool onlySql})
      : super(players: players, uid: uid, onlySql: onlySql);

  @override
  String toString() {
    return 'PlayerUninitialized{players: ${players.length}, onlySql: $onlySql}';
  }
}

///
/// No data at all, we are uninitialized.
///
class PlayerUninitialized extends PlayerState {
  PlayerUninitialized() : super(players: {}, uid: null, onlySql: true);

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
      {@required Map<String, Player> players,
      @required String uid,
      @required bool onlySql})
      : super(players: players, uid: uid, onlySql: onlySql);

  @override
  String toString() {
    return 'PlayerData{players: ${players.length}, onlySql: $onlySql}';
  }
}

///
/// Player bloc handles the player flow.  Loading all the players from
/// firestore.
///
class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final CoordinationBloc coordinationBloc;

  StreamSubscription<FirestoreChangedData> _playerSnapshot;
  bool _createdMePlayer = false;
  StreamSubscription<CoordinationState> _authSub;

  PlayerBloc({
    @required this.coordinationBloc,
  }) {
    _authSub = coordinationBloc.state.listen((CoordinationState state) {
      if (state is CoordinationStateLoggedOut) {
        dispatch(_PlayerLoggedOut());
      } else if (state is CoordinationStateStartLoadingSql) {
        _startLoading(state);
      } else if (state is CoordinationStateStartLoadingFirestore) {
        _startLoadingFirestore(state);
      }
    });
  }

  void _startLoading(CoordinationStateStartLoadingSql state) {
    dispatch(_PlayerUserLoaded(uid: state.uid));
  }

  void _startLoadingFirestore(CoordinationStateStartLoadingFirestore state) {
    dispatch(_PlayerFirestore(uid: state.uid));
  }

  @override
  PlayerState get initialState {
    return new PlayerUninitialized();
  }

  @override
  void dispose() {
    _playerSnapshot?.cancel();
    _authSub?.cancel();
  }

  void _onPlayerUpdated(List<FirestoreWrappedData> query) {
    Set<String> toDeletePlayers = new Set<String>();
    bool foundMe = false;
    Map<String, Player> players =
        Map<String, Player>.from(currentState.players);

    toDeletePlayers.addAll(players.keys);
    for (FirestoreWrappedData doc in query) {
      Player player;
      if (players.containsKey(doc.id)) {
        player = players[doc.id];
        player.fromJSON(doc.id, doc.data);
        if (player.users[currentState.uid].relationship == Relationship.Me) {
          if (foundMe) {
            if (player.users.length <= 1) {
              coordinationBloc.databaseUpdateModel.deletePlayer(player.uid);
            }
          }
          foundMe = true;
        }
      } else {
        player = new Player();
        // Add in snapshots to find the teams associated with the player.
        player.fromJSON(doc.id, doc.data);
        players[player.uid] = player;
        if (player.users[currentState.uid].relationship == Relationship.Me) {
          if (foundMe) {
            if (player.users.length <= 1) {
              coordinationBloc.databaseUpdateModel.deletePlayer(player.uid);
            }
          }
          foundMe = true;
        }
      }
      toDeletePlayers.remove(doc.id);
      coordinationBloc.persistentData.updateElement(PersistenData.playersTable,
          player.uid, player.toJSON(includeUsers: true));
    }
    toDeletePlayers.forEach((String id) {
      players.remove(id);
      coordinationBloc.persistentData
          .deleteElement(PersistenData.playersTable, id);
    });
    if (query.length == 0) {
      if (!foundMe && !_createdMePlayer) {
        print('Docs are empty');
        Player player = new Player();
        player.name = coordinationBloc
                .authenticationBloc.currentUser.profile?.displayName ??
            "Frog";

        PlayerUser playerUser = new PlayerUser();
        playerUser.userUid =
            coordinationBloc.authenticationBloc.currentUser.uid;
        playerUser.relationship = Relationship.Me;
        player.users[playerUser.userUid] = playerUser;
        print('Updating firestore');
        _createdMePlayer = true;
        player.updateFirestore(includeUsers: true).then((void val) {
          print('Done!');
        }).catchError((dynamic e, StackTrace trace) {
          print('Setting up snap with players $trace');
          return e;
        });
      } else {
        print('Loaded for fluff');
      }
    }
    dispatch(_PlayerNewPlayersLoaded(
        players: players, uid: currentState.uid, deleted: toDeletePlayers));
  }

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    if (event is _PlayerUserLoaded) {
      yield PlayerLoading(players: currentState.players, uid: event.uid);
      TraceProxy playerTrace =
          coordinationBloc.analyticsSubsystem.newTrace("playerData");
      playerTrace.start();
      Map<String, Map<String, dynamic>> data = await coordinationBloc
          .persistentData
          .getAllElements(PersistenData.playersTable);
      Map<String, Player> newPlayers = new Map<String, Player>();
      data.forEach((String uid, Map<String, dynamic> input) {
        coordinationBloc.sqlTrace?.incrementCounter("player");
        playerTrace.incrementCounter("player");
        Player player = new Player();
        player.fromJSON(uid, input);
        newPlayers[uid] = player;
      });
      print(
          'End players ${coordinationBloc.start.difference(new DateTime.now())}');
      playerTrace.stop();
      yield PlayerLoaded(players: newPlayers, uid: event.uid, onlySql: true);
      coordinationBloc.dispatch(
          CoordinationEventLoadedData(loaded: BlocsToLoad.Messages, sql: true));
    }

    if (event is _PlayerFirestore) {
      // Load from firestore.
      InitialSubscription playersInitialData =
          coordinationBloc.databaseUpdateModel.getPlayers(event.uid);
      playersInitialData.startData.then((List<FirestoreWrappedData> data) {
        coordinationBloc.loadingTrace?.incrementCounter("players");
        this._onPlayerUpdated(data);
      });
      _playerSnapshot =
          playersInitialData.stream.listen((FirestoreChangedData data) {
        this._onPlayerUpdated(data.newList);
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
          players: event.players, uid: event.uid, onlySql: false);
      coordinationBloc.dispatch(CoordinationEventLoadedData(
          loaded: BlocsToLoad.Messages, sql: false));
    }
  }
}
