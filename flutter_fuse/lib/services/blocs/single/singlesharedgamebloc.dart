import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

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
    extends AsyncHydratedBloc<SingleSharedGameEvent, SingleSharedGameState> {
  final DatabaseUpdateModel db;
  final String sharedGameUid;
  final AnalyticsSubsystem crashes;

  static String createNew = 'new';

  StreamSubscription<GameSharedData> _gameSub;

  ///
  /// Build the shared game bloc for us to do fun stuff with.
  ///
  SingleSharedGameBloc(
      {@required this.db, @required this.sharedGameUid, @required this.crashes})
      : super(SingleSharedGameUninitialized(), sharedGameUid) {
    _gameSub = db.getSharedGame(sharedGameUid).listen((sharedGame) {
      if (sharedGame != null) {
        // Only send this if the game is not the same.
        add(_SingleSharedGameNewSharedGame(sharedData: sharedGame));
      } else {
        add(_SingleSharedGameDeleted());
      }
    });
    _gameSub.onError((e, stack) => crashes.recordException(e, stack));
  }

  @override
  Future<void> close() async {
    await super.close();
    await _gameSub?.cancel();
  }

  @override
  Stream<SingleSharedGameState> mapEventToState(
      SingleSharedGameEvent event) async* {
    if (event is _SingleSharedGameNewSharedGame) {
      yield (SingleSharedGameLoaded.fromState(state)
            ..sharedGame = event.sharedData.toBuilder())
          .build();
    }

    // The game is deleted.
    if (event is _SingleSharedGameDeleted) {
      yield SingleSharedGameDeleted.fromState(state).build();
    }

    // Update the shared data of the game.
    if (event is SingleSharedGameUpdateData) {
      yield SingleSharedGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreSharedGame(event.sharedData);
        yield SingleSharedGameSaveDone.fromState(state).build();
        yield (SingleSharedGameLoaded.fromState(state)
              ..sharedGame = event.sharedData.toBuilder())
            .build();
      } catch (e, stack) {
        yield (SingleSharedGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordException(e, stack);
      }
    }

    // Update offical game result
    if (event is SingleSharedGameUpdateOfficalResult) {
      yield SingleSharedGameSaving.fromState(state).build();
      try {
        await db.updateFirestoreOfficialGameResult(sharedGameUid, event.result);
        yield SingleSharedGameSaveDone.fromState(state).build();
        yield SingleSharedGameLoaded.fromState(state).build();
      } catch (e, stack) {
        yield (SingleSharedGameSaveFailed.fromState(state)..error = e).build();
        crashes.recordException(e, stack);
      }
    }
  }

  @override
  SingleSharedGameState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleSharedGameUninitialized)) {
      return state;
    }

    if (json == null || !json.containsKey('type')) {
      return SingleSharedGameUninitialized();
    }

    try {
      var type = SingleSharedGameBlocStateType.valueOf(json['type']);
      switch (type) {
        case SingleSharedGameBlocStateType.Uninitialized:
          return SingleSharedGameUninitialized();
        case SingleSharedGameBlocStateType.Loaded:
          var ret = SingleSharedGameLoaded.fromMap(json);
          return ret;
        case SingleSharedGameBlocStateType.Deleted:
          return SingleSharedGameDeleted.fromMap(json);
        case SingleSharedGameBlocStateType.SaveFailed:
          return SingleSharedGameSaveFailed.fromMap(json);
        case SingleSharedGameBlocStateType.Saving:
          return SingleSharedGameSaving.fromMap(json);
        case SingleSharedGameBlocStateType.SaveDone:
          return SingleSharedGameSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return SingleSharedGameUninitialized();
  }

  @override
  Map<String, dynamic> toJson(SingleSharedGameState state) {
    return state.toMap();
  }
}
