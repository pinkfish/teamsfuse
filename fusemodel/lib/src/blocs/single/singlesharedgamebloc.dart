import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../gamesbloc.dart';

abstract class SingleSharedGameState extends Equatable {
  final GameSharedData sharedData;

  SingleSharedGameState({@required this.sharedData}) : super([sharedData]);
}

///
/// We have a game, default state.
///
class SingleSharedGameLoaded extends SingleSharedGameState {
  SingleSharedGameLoaded(
      {@required SingleSharedGameState state, GameSharedData sharedData})
      : super(sharedData: sharedData ?? state.sharedData);

  @override
  String toString() {
    return 'SingleSharedGameLoaded{}';
  }
}

///
/// Saving operation in progress.
///
class SingleSharedGameSaving extends SingleSharedGameState {
  SingleSharedGameSaving(
      {@required SingleSharedGameState singleSharedGameState})
      : super(sharedData: singleSharedGameState.sharedData);

  @override
  String toString() {
    return 'SingleSharedGameSaving{}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleSharedGameSaveFailed extends SingleSharedGameState {
  final Error error;

  SingleSharedGameSaveFailed(
      {@required SingleSharedGameState singleSharedGameState, this.error})
      : super(sharedData: singleSharedGameState.sharedData);

  @override
  String toString() {
    return 'SingleSharedGameSaveFailed{}';
  }
}

///
/// SharedGame got deleted.
///
class SingleSharedGameDeleted extends SingleSharedGameState {
  SingleSharedGameDeleted.empty() : super(sharedData: null);

  @override
  String toString() {
    return 'SingleSharedGameDeleted{}';
  }
}

abstract class SingleSharedGameEvent extends Equatable {}

///
/// Updates the game (writes it out to firebase.
///
class SingleSharedGameUpdateData extends SingleSharedGameEvent {
  final GameSharedData sharedData;

  SingleSharedGameUpdateData({@required this.sharedData});
}

///
/// Update the offical result for this game.
///s
class SingleSharedGameUpdateOfficalResult extends SingleSharedGameEvent {
  final GameOfficialResults result;

  SingleSharedGameUpdateOfficalResult({@required this.result});
}

class _SingleSharedGameNewSharedGame extends SingleSharedGameEvent {
  final GameSharedData sharedData;

  _SingleSharedGameNewSharedGame({@required this.sharedData});
}

class _SingleSharedGameDeleted extends SingleSharedGameEvent {
  _SingleSharedGameDeleted();
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleSharedGameBloc
    extends Bloc<SingleSharedGameEvent, SingleSharedGameState> {
  final GameBloc gameBloc;
  String _sharedGameUid;

  static String createNew = "new";

  String get sharedGameUid => _sharedGameUid;

  StreamSubscription<GameState> _gameSub;

  SingleSharedGameBloc({@required this.gameBloc, @required String gameUid}) {
    _sharedGameUid = gameUid;
    _gameSub = gameBloc.state.listen((GameState state) {
      GameSharedData data = state.getSharedData(gameUid);
      if (data != null) {
        // Only send this if the game is not the same.
        if (data != currentState.sharedData) {
          dispatch(_SingleSharedGameNewSharedGame(sharedData: data));
        }
      } else {
        dispatch(_SingleSharedGameDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameSub?.cancel();
  }

  @override
  SingleSharedGameState get initialState {
    GameSharedData g = gameBloc.currentState.getSharedData(sharedGameUid);

    if (g != null) {
      return SingleSharedGameLoaded(sharedData: g);
    }
    return SingleSharedGameDeleted.empty();
  }

  @override
  Stream<SingleSharedGameState> mapEventToState(
      SingleSharedGameEvent event) async* {
    if (event is _SingleSharedGameNewSharedGame) {
      yield SingleSharedGameLoaded(
          state: currentState, sharedData: event.sharedData);
    }

    // The game is deleted.
    if (event is _SingleSharedGameDeleted) {
      yield SingleSharedGameDeleted.empty();
    }

    // Update the shared data of the game.
    if (event is SingleSharedGameUpdateData) {
      yield SingleSharedGameSaving(singleSharedGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSharedGame(event.sharedData);
        yield SingleSharedGameLoaded(
            state: currentState, sharedData: event.sharedData);
      } catch (e) {
        yield SingleSharedGameSaveFailed(
            singleSharedGameState: currentState, error: e);
      }
    }

    // Update offical game result
    if (event is SingleSharedGameUpdateOfficalResult) {
      yield SingleSharedGameSaving(singleSharedGameState: currentState);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOfficalGameResult(
                currentState.sharedData.uid, event.result);
        yield SingleSharedGameLoaded(state: currentState);
      } catch (e) {
        yield SingleSharedGameSaveFailed(
            singleSharedGameState: currentState, error: e);
      }
    }
  }
}
