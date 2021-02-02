import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../gamesbloc.dart';

abstract class SingleSharedGameState extends Equatable {
  final GameSharedData sharedData;

  SingleSharedGameState({@required this.sharedData});

  @override
  List<Object> get props => [sharedData];
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

  @override
  List<Object> get props => [sharedData];
}

///
/// Update the offical result for this game.
///s
class SingleSharedGameUpdateOfficalResult extends SingleSharedGameEvent {
  final GameOfficialResults result;

  SingleSharedGameUpdateOfficalResult({@required this.result});

  @override
  List<Object> get props => [result];
}

class _SingleSharedGameNewSharedGame extends SingleSharedGameEvent {
  final GameSharedData sharedData;

  _SingleSharedGameNewSharedGame({@required this.sharedData});

  @override
  List<Object> get props => [sharedData];
}

class _SingleSharedGameDeleted extends SingleSharedGameEvent {
  _SingleSharedGameDeleted();

  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific game.
///
class SingleSharedGameBloc
    extends Bloc<SingleSharedGameEvent, SingleSharedGameState> {
  final GameBloc gameBloc;
  final String sharedGameUid;
  final AnalyticsSubsystem crashes;

  static String createNew = "new";

  StreamSubscription<GameState> _gameSub;

  SingleSharedGameBloc(
      {@required this.gameBloc,
      @required this.sharedGameUid,
      @required this.crashes})
      : super(gameBloc.state.getSharedData(sharedGameUid) != null
            ? SingleSharedGameLoaded(
                sharedData: gameBloc.state.getSharedData(sharedGameUid),
                state: null)
            : SingleSharedGameDeleted.empty()) {
    _gameSub = gameBloc.listen((GameState gameState) {
      GameSharedData data = gameState.getSharedData(sharedGameUid);
      if (data != null) {
        // Only send this if the game is not the same.
        if (data != state.sharedData) {
          add(_SingleSharedGameNewSharedGame(sharedData: data));
        }
      } else {
        add(_SingleSharedGameDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _gameSub?.cancel();
  }

  @override
  Stream<SingleSharedGameState> mapEventToState(
      SingleSharedGameEvent event) async* {
    if (event is _SingleSharedGameNewSharedGame) {
      yield SingleSharedGameLoaded(state: state, sharedData: event.sharedData);
    }

    // The game is deleted.
    if (event is _SingleSharedGameDeleted) {
      yield SingleSharedGameDeleted.empty();
    }

    // Update the shared data of the game.
    if (event is SingleSharedGameUpdateData) {
      yield SingleSharedGameSaving(singleSharedGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreSharedGame(event.sharedData);
        yield SingleSharedGameLoaded(
            state: state, sharedData: event.sharedData);
      } catch (e, stack) {
        yield SingleSharedGameSaveFailed(
            singleSharedGameState: state, error: e);
        crashes.recordException(e, stack);
      }
    }

    // Update offical game result
    if (event is SingleSharedGameUpdateOfficalResult) {
      yield SingleSharedGameSaving(singleSharedGameState: state);
      try {
        await gameBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOfficalGameResult(
                state.sharedData.uid, event.result);
        yield SingleSharedGameLoaded(state: state);
      } catch (e, stack) {
        yield SingleSharedGameSaveFailed(
            singleSharedGameState: state, error: e);
        crashes.recordException(e, stack);
      }
    }
  }
}
