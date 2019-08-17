import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../teambloc.dart';

abstract class SingleTeamOpponentState extends Equatable {
  final Opponent opponent;
  final BuiltList<Game> games;
  final bool gamesLoaded;

  SingleTeamOpponentState(
      {@required this.opponent,
      @required this.games,
      @required this.gamesLoaded})
      : super([opponent, games, gamesLoaded]);
}

///
/// We have a team, default state.
///
class SingleTeamOpponentLoaded extends SingleTeamOpponentState {
  SingleTeamOpponentLoaded(
      {@required SingleTeamOpponentState state,
      Opponent opponent,
      BuiltList<Game> games,
      bool gamesLoaded})
      : super(
            opponent: opponent ?? state.opponent,
            games: games ?? state.games,
            gamesLoaded: gamesLoaded ?? state.gamesLoaded);

  @override
  String toString() {
    return 'SingleTeamOpponentLoaded{opponent: $opponent}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamOpponentSaving extends SingleTeamOpponentState {
  SingleTeamOpponentSaving({@required SingleTeamOpponentState state})
      : super(
            opponent: state.opponent,
            games: state.games,
            gamesLoaded: state.gamesLoaded);

  @override
  String toString() {
    return 'SingleTeamOpponentSaving{opponent: $opponent}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamOpponentSaveFailed extends SingleTeamOpponentState {
  final Error error;

  SingleTeamOpponentSaveFailed(
      {@required SingleTeamOpponentState state, this.error})
      : super(
            opponent: state.opponent,
            games: state.games,
            gamesLoaded: state.gamesLoaded);

  @override
  String toString() {
    return 'SingleTeamOpponentSaveFailed{opponent: $opponent}';
  }
}

///
/// Team got deleted.
///
class SingleTeamOpponentDeleted extends SingleTeamOpponentState {
  SingleTeamOpponentDeleted()
      : super(opponent: null, games: BuiltList(), gamesLoaded: false);

  @override
  String toString() {
    return 'SingleTeamOpponentDeleted{}';
  }
}

abstract class SingleTeamOpponentEvent extends Equatable {}

///
/// Updates the team (writes it out to firebase.
///
class SingleTeamOpponentUpdate extends SingleTeamOpponentEvent {
  final OpponentBuilder opponent;

  SingleTeamOpponentUpdate({@required this.opponent});
}

///
/// Delete this team from the world.
///
class SingleTeamOpponentDeleteOpponent extends SingleTeamOpponentEvent {}

class _SingleTeamNewTeamOpponent extends SingleTeamOpponentEvent {
  final Opponent newOpponent;

  _SingleTeamNewTeamOpponent({@required this.newOpponent});
}

class _SingleTeamOpponentDeleted extends SingleTeamOpponentEvent {}

class _SingleTeamOpponentGamesLoaded extends SingleTeamOpponentEvent {
  final Iterable<Game> games;
  _SingleTeamOpponentGamesLoaded({@required this.games});
}

///
/// Loads the games for this opponent.
///
class SingleTeamOpponentLoadGames extends SingleTeamOpponentEvent {}

///
/// Bloc to handle updates and state of a specific team.
///
class SingleTeamOpponentBloc
    extends Bloc<SingleTeamOpponentEvent, SingleTeamOpponentState> {
  final TeamBloc teamBloc;
  final String teamUid;
  final String opponentUid;

  static String createNew = "new";

  StreamSubscription<TeamState> _teamSub;
  StreamSubscription<Iterable<Game>> _gameSub;

  SingleTeamOpponentBloc({this.teamBloc, this.teamUid, this.opponentUid}) {
    _teamSub = teamBloc.state.listen((TeamState state) {
      Team team = state.getTeam(teamUid);
      if (team != null && team.opponents.containsKey(opponentUid)) {
        Opponent op = team.opponents[opponentUid];

        // Only send this if the team is not the same.
        if (op != currentState.opponent) {
          dispatch(_SingleTeamNewTeamOpponent(newOpponent: op));
        }
      } else {
        dispatch(_SingleTeamOpponentDeleted());
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
  SingleTeamOpponentState get initialState {
    Team t = teamBloc.currentState.getTeam(teamUid);
    if (t != null && t.opponents.containsKey(opponentUid)) {
      return SingleTeamOpponentLoaded(opponent: t.opponents[opponentUid]);
    } else {
      return SingleTeamOpponentDeleted();
    }
  }

  @override
  Stream<SingleTeamOpponentState> mapEventToState(
      SingleTeamOpponentEvent event) async* {
    if (event is _SingleTeamNewTeamOpponent) {
      yield SingleTeamOpponentLoaded(opponent: event.newOpponent);
    }

    // The team is deleted.
    if (event is _SingleTeamOpponentDeleted) {
      yield SingleTeamOpponentDeleted();
    }

    // Save the team.
    if (event is SingleTeamOpponentUpdate) {
      yield SingleTeamOpponentSaving(state: currentState);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleTeamOpponentLoaded(opponent: event.opponent.build());
      } catch (e) {
        yield SingleTeamOpponentSaveFailed(state: currentState, error: e);
      }
    }

    // Delete the opponent.
    if (event is SingleTeamOpponentDeleteOpponent) {
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .deleteFirestoreOpponent(currentState.opponent);
        yield SingleTeamOpponentDeleted();
      } catch (e) {
        yield SingleTeamOpponentSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamOpponentUpdate) {
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleTeamOpponentLoaded(opponent: event.opponent.build());
      } catch (e) {
        yield SingleTeamOpponentSaveFailed(state: currentState, error: e);
      }
    }

    if (event is SingleTeamOpponentLoadGames) {
      _gameSub = teamBloc.coordinationBloc.databaseUpdateModel
          .getOpponentGames(currentState.opponent)
          .listen((Iterable<Game> g) {
        dispatch(_SingleTeamOpponentGamesLoaded(games: g));
      });
    }

    if (event is _SingleTeamOpponentGamesLoaded) {
      yield SingleTeamOpponentLoaded(
          state: currentState,
          games: BuiltList.from(event.games),
          gamesLoaded: true);
    }
  }
}
