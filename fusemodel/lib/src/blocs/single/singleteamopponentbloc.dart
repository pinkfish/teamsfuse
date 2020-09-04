import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import 'singleteambloc.dart';

abstract class SingleOpponentState extends Equatable {
  final Opponent opponent;
  final BuiltList<Game> games;
  final bool gamesLoaded;

  SingleOpponentState(
      {this.opponent, @required this.games, @required this.gamesLoaded});

  @override
  List<Object> get props => [opponent, games, gamesLoaded];
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
  final Iterable<Game> games;
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
    extends Bloc<SingleOpponentEvent, SingleOpponentState> {
  final SingleTeamBloc singleTeamBloc;
  final String opponentUid;

  static String createNew = "new";

  StreamSubscription<SingleTeamState> _teamSub;
  StreamSubscription<Iterable<Game>> _gameSub;

  SingleOpponentBloc({this.singleTeamBloc, this.opponentUid})
      : super(singleTeamBloc.state.opponents.containsKey(opponentUid)
            ? SingleOpponentLoaded(
                state: null,
                opponent: singleTeamBloc.state.opponents[opponentUid],
                gamesLoaded: false,
                games: BuiltList())
            : SingleOpponentDeleted()) {
    _teamSub = singleTeamBloc.listen((SingleTeamState teamState) {
      if (teamState.opponents.containsKey(opponentUid)) {
        Opponent op = teamState.opponents[opponentUid];

        // Only send this if the team is not the same.
        if (op != state.opponent) {
          add(_SingleNewTeamOpponent(newOpponent: op));
        }
      } else {
        add(_SingleOpponentDeleted());
      }
    });
  }

  @override
  Future<void> close() async {
    await super.close();
    _teamSub?.cancel();
    _teamSub = null;
    _gameSub?.cancel();
    _gameSub = null;
  }

  @override
  SingleOpponentState get initialState {}

  @override
  Stream<SingleOpponentState> mapEventToState(
      SingleOpponentEvent event) async* {
    if (event is _SingleNewTeamOpponent) {
      yield SingleOpponentLoaded(opponent: event.newOpponent, state: state);
    }

    // The team is deleted.
    if (event is _SingleOpponentDeleted) {
      yield SingleOpponentDeleted();
    }

    // Save the team.
    if (event is SingleOpponentUpdate) {
      yield SingleOpponentSaving(state: state);
      try {
        await singleTeamBloc.teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleOpponentLoaded(
            opponent: event.opponent.build(), state: state);
      } catch (e) {
        yield SingleOpponentSaveFailed(state: state, error: e);
      }
    }

    // Delete the opponent.
    if (event is SingleOpponentDeleteOpponent) {
      try {
        await singleTeamBloc.teamBloc.coordinationBloc.databaseUpdateModel
            .deleteFirestoreOpponent(state.opponent);
        yield SingleOpponentDeleted();
      } catch (e) {
        yield SingleOpponentSaveFailed(state: state, error: e);
      }
    }

    if (event is SingleOpponentUpdate) {
      try {
        await singleTeamBloc.teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleOpponentLoaded(
            opponent: event.opponent.build(), state: state);
      } catch (e) {
        yield SingleOpponentSaveFailed(state: state, error: e);
      }
    }

    if (event is SingleOpponentLoadGames) {
      _gameSub = singleTeamBloc.teamBloc.coordinationBloc.databaseUpdateModel
          .getOpponentGames(state.opponent)
          .listen((Iterable<Game> g) {
        add(_SingleTeamOpponentGamesLoaded(games: g));
      });
    }

    if (event is _SingleTeamOpponentGamesLoaded) {
      yield SingleOpponentLoaded(
          state: state, games: BuiltList.from(event.games), gamesLoaded: true);
    }
  }
}
