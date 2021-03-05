import 'dart:async';
import 'dart:isolate';

import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../../../util/async_hydrated_bloc/asynchydratedbloc.dart';

abstract class SingleOpponentEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleOpponentUpdate extends SingleOpponentEvent {
  final OpponentBuilder opponent;

  SingleOpponentUpdate({@required this.opponent});

  @override
  List<Object> get props => [opponent];
}

///
/// Delete this team from the world.
///
class SingleOpponentDeleteOpponent extends SingleOpponentEvent {
  @override
  List<Object> get props => [];
}

class _SingleNewTeamOpponent extends SingleOpponentEvent {
  final Opponent newOpponent;

  _SingleNewTeamOpponent({@required this.newOpponent});

  @override
  List<Object> get props => [newOpponent];
}

class _SingleOpponentDeleted extends SingleOpponentEvent {
  @override
  List<Object> get props => [];
}

class _SingleTeamOpponentGamesLoaded extends SingleOpponentEvent {
  final BuiltList<Game> games;
  _SingleTeamOpponentGamesLoaded({@required this.games});

  @override
  List<Object> get props => [games];
}

///
/// Loads the games for this opponent.
///
class SingleOpponentLoadGames extends SingleOpponentEvent {
  @override
  List<Object> get props => [];
}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleOpponentBloc
    extends AsyncHydratedBloc<SingleOpponentEvent, SingleOpponentState> {
  final String opponentUid;
  final String teamUid;
  final DatabaseUpdateModel db;
  final AnalyticsSubsystem crashes;

  static String createNew = 'new';

  StreamSubscription<Opponent> _opponentSub;
  StreamSubscription<Iterable<Game>> _gameSub;

  SingleOpponentBloc(
      {@required this.db,
      @required this.teamUid,
      @required this.opponentUid,
      @required this.crashes})
      : super(SingleOpponentUninitialized(), 'opponent.$teamUid.$opponentUid') {
    _opponentSub = db
        .getFirestoreOpponent(teamUid: teamUid, opponentUid: opponentUid)
        .listen((op) {
      if (op != null) {
        add(_SingleNewTeamOpponent(newOpponent: op));
      } else {
        add(_SingleOpponentDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _opponentSub?.cancel();
    _opponentSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  Stream<SingleOpponentState> mapEventToState(
      SingleOpponentEvent event) async* {
    if (event is _SingleNewTeamOpponent) {
      yield (SingleOpponentLoaded.fromState(state)
            ..opponent = event.newOpponent.toBuilder())
          .build();
    }

    // The team is deleted.
    if (event is _SingleOpponentDeleted) {
      yield SingleOpponentDeleted();
    }

    // Save the team.
    if (event is SingleOpponentUpdate) {
      yield SingleOpponentSaving.fromState(state).build();
      try {
        await db.updateFirestoreOpponent(event.opponent.build());
        yield (SingleOpponentSaveDone.fromState(state)
              ..opponent = event.opponent)
            .build();
        yield (SingleOpponentLoaded.fromState(state)..opponent = event.opponent)
            .build();
      } catch (e, stack) {
        yield (SingleOpponentSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleOpponentLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    // Delete the opponent.
    if (event is SingleOpponentDeleteOpponent) {
      yield SingleOpponentSaving.fromState(state).build();
      try {
        await db.deleteFirestoreOpponent(state.opponent);
        yield SingleOpponentSaveDone.fromState(state).build();
        yield SingleOpponentDeleted();
      } catch (e, stack) {
        yield (SingleOpponentSaveFailed.fromState(state)
              ..error = RemoteError(e.message, stack.toString()))
            .build();
        yield SingleOpponentLoaded.fromState(state).build();
        crashes.recordException(e, stack);
      }
    }

    if (event is SingleOpponentLoadGames) {
      if (_gameSub == null) {
        _gameSub =
            db.getOpponentGames(state.opponent).listen((Iterable<Game> g) {
          add(_SingleTeamOpponentGamesLoaded(games: g));
        });
      }
    }

    if (event is _SingleTeamOpponentGamesLoaded) {
      yield (SingleOpponentLoaded.fromState(state)
            ..games = event.games.toBuilder()
            ..loadedGames = true)
          .build();
    }
  }

  @override
  SingleOpponentState fromJson(Map<String, dynamic> json) {
    if (!(state is SingleOpponentUninitialized)) {
      return state;
    }
    if (json == null || !json.containsKey('type')) {
      return state;
    }

    try {
      SingleOpponentBlocStateType type =
          SingleOpponentBlocStateType.valueOf(json['type']);
      switch (type) {
        case SingleOpponentBlocStateType.Uninitialized:
          return SingleOpponentUninitialized();
        case SingleOpponentBlocStateType.Loaded:
          var ret = SingleOpponentLoaded.fromMap(json);
          return ret;
        case SingleOpponentBlocStateType.Deleted:
          return SingleOpponentDeleted.fromMap(json);
        case SingleOpponentBlocStateType.SaveFailed:
          return SingleOpponentSaveFailed.fromMap(json);
        case SingleOpponentBlocStateType.Saving:
          return SingleOpponentSaving.fromMap(json);
        case SingleOpponentBlocStateType.SaveDone:
          return SingleOpponentSaveDone.fromMap(json);
      }
    } catch (e, stack) {
      if (e is Error) {
        crashes.recordError(e, stack);
      } else {
        crashes.recordException(e, stack);
      }
    }

    return state;
  }

  @override
  Map<String, dynamic> toJson(SingleOpponentState state) {
    return state.toMap();
  }
}
