import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../teambloc.dart';

abstract class SingleOpponentState extends Equatable {
  final Opponent opponent;
  final BuiltList<Game> games;
  final bool gamesLoaded;

  SingleOpponentState(
      {this.opponent, @required this.games, @required this.gamesLoaded})
      : super([opponent, games, gamesLoaded]);
}

///
/// We have a team, default state.
///
class SingleOpponentLoaded extends SingleOpponentState {
  SingleOpponentLoaded(
      {@required SingleOpponentState state,
      Opponent opponent,
      BuiltList<Game> games,
      bool gamesLoaded})
      : super(
            opponent: opponent ?? state.opponent,
            games: games ?? state.games,
            gamesLoaded: gamesLoaded ?? state.gamesLoaded);

  @override
  String toString() {
    return 'SingleOpponentLoaded{opponent: $opponent}';
  }
}

///
/// Saving operation in progress.
///
class SingleOpponentSaving extends SingleOpponentState {
  SingleOpponentSaving({@required SingleOpponentState state})
      : super(
            opponent: state.opponent,
            games: state.games,
            gamesLoaded: state.gamesLoaded);

  @override
  String toString() {
    return 'SingleOpponentSaving{opponent: $opponent}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleOpponentSaveFailed extends SingleOpponentState {
  final Error error;

  SingleOpponentSaveFailed({@required SingleOpponentState state, this.error})
      : super(
            opponent: state.opponent,
            games: state.games,
            gamesLoaded: state.gamesLoaded);

  @override
  String toString() {
    return 'SingleOpponentSaveFailed{opponent: $opponent}';
  }
}

///
/// Team got deleted.
///
class SingleOpponentDeleted extends SingleOpponentState {
  SingleOpponentDeleted()
      : super(opponent: null, games: BuiltList(), gamesLoaded: false);

  @override
  String toString() {
    return 'SingleOpponentDeleted{}';
  }
}

abstract class SingleOpponentEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleOpponentUpdate extends SingleOpponentEvent {
  final OpponentBuilder opponent;

  SingleOpponentUpdate({@required this.opponent});
}

///
/// Delete this team from the world.
///
class SingleOpponentDeleteOpponent extends SingleOpponentEvent {}

class _SingleNewTeamOpponent extends SingleOpponentEvent {
  final Opponent newOpponent;

  _SingleNewTeamOpponent({@required this.newOpponent});
}

class _SingleOpponentDeleted extends SingleOpponentEvent {}

class _SingleTeamOpponentGamesLoaded extends SingleOpponentEvent {
  final Iterable<Game> games;
  _SingleTeamOpponentGamesLoaded({@required this.games});
}

///
/// Loads the games for this opponent.
///
class SingleOpponentLoadGames extends SingleOpponentEvent {}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleOpponentBloc
    extends Bloc<SingleOpponentEvent, SingleOpponentState> {
  final TeamBloc teamBloc;
  final String opponentUid;

  static String createNew = "new";

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<Iterable<Game>> _gameSub;

  SingleOpponentBloc({this.teamBloc, this.opponentUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      if (state.opponents.containsKey(opponentUid)) {
        Opponent op = state.opponents[opponentUid];

        // Only send this if the team is not the same.
        if (op != currentState.opponent) {
          dispatch(_SingleNewTeamOpponent(newOpponent: op));
        }
      } else {
        dispatch(_SingleOpponentDeleted());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _teamSub?.cancel();
    _teamSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  SingleOpponentState get initialState {
    if (teamBloc.currentState.opponents.containsKey(opponentUid)) {
      return SingleOpponentLoaded(
          opponent: teamBloc.currentState.opponents[opponentUid]);
    } else {
      return SingleOpponentDeleted();
    }
  }

  @override
  Stream<SingleOpponentState> mapEventToState(
      SingleOpponentEvent event) async* {
    if (event is _SingleNewTeamOpponent) {
      yield SingleOpponentLoaded(opponent: event.newOpponent);
    }

    // The team is deleted.
    if (event is _SingleOpponentDeleted) {
      yield SingleOpponentDeleted();
    }

    // Save the team.
    if (event is SingleOpponentUpdate) {
      yield SingleOpponentSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleOpponentLoaded(opponent: event.opponent.build());
      } catch (e) {
        yield SingleOpponentSaveFailed(state: currentState, error: e);
      }
    }

    // Delete the opponent.
    if (event is SingleOpponentDeleteOpponent) {
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .deleteFirestoreOpponent(currentState.opponent);
        yield SingleOpponentDeleted();
      } catch (e) {
        yield SingleOpponentSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleOpponentUpdate) {
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleOpponentLoaded(opponent: event.opponent.build());
      } catch (e) {
        yield SingleOpponentSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleOpponentLoadGames) {
      _gameSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getOpponentGames(currentState.opponent)
          .listen((Iterable<Game> g) {
        dispatch(_SingleTeamOpponentGamesLoaded(games: g));
      });
    }

    if (event is _SingleTeamOpponentGamesLoaded) {
      yield SingleOpponentLoaded(
          state: currentState,
          games: BuiltList.from(event.games),
          gamesLoaded: true);
    }
  }
}
