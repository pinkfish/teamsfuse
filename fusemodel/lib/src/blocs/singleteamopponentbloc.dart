import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'teambloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';

abstract class SingleTeamOpponentState extends Equatable {
  final String teamUid;
  final String opponentUid;
  final Opponent opponent;

  SingleTeamOpponentState(
      {@required this.teamUid,
      @required this.opponent,
      @required this.opponentUid});
}

///
/// Nothing happened for this team yet.
///
class SingleTeamOpponentUninitalized extends SingleTeamOpponentState {
  SingleTeamOpponentUninitalized(
      {@required String teamUid, @required String opponentUid})
      : super(teamUid: teamUid, opponentUid: opponentUid, opponent: null);
}

///
/// We have a team, default state.
///
class SingleTeamOpponentLoaded extends SingleTeamOpponentState {
  SingleTeamOpponentLoaded(
      {@required String teamUid,
      @required Opponent opponent,
      @required String opponentUid})
      : super(teamUid: teamUid, opponent: opponent, opponentUid: opponentUid);

  @override
  String toString() {
    return 'SingleTeamOpponentLoaded{teamUid: $teamUid, opponentUid: $opponentUid}';
  }
}

///
/// Saving operation in progress.
///
class SingleTeamOpponentSaving extends SingleTeamOpponentState {
  SingleTeamOpponentSaving(
      {@required String teamUid,
      @required Opponent opponent,
      @required String opponentUid})
      : super(teamUid: teamUid, opponent: opponent, opponentUid: opponentUid);

  @override
  String toString() {
    return 'SingleTeamOpponentSaving{teamUid: $teamUid, opponentUid: $opponentUid}';
  }
}

///
/// Saving operation failed (goes back to loaded for success).
///
class SingleTeamOpponentSaveFailed extends SingleTeamOpponentState {
  final Error error;

  SingleTeamOpponentSaveFailed(
      {@required String teamUid,
      @required Opponent opponent,
      @required String opponentUid,
      this.error})
      : super(teamUid: teamUid, opponent: opponent, opponentUid: opponentUid);

  @override
  String toString() {
    return 'SingleTeamOpponentSaveFailed{teamUid: $teamUid, opponentUid: $opponentUid}';
  }
}

///
/// Team got deleted.
///
class SingleTeamOpponentDeleted extends SingleTeamOpponentState {
  SingleTeamOpponentDeleted(
      {@required String teamUid,
      @required Opponent opponent,
      @required String opponentUid})
      : super(teamUid: teamUid, opponent: opponent, opponentUid: opponentUid);

  @override
  String toString() {
    return 'SingleTeamDeleted{}';
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
class SingleTeamOpponentDelete extends SingleTeamOpponentEvent {
  SingleTeamOpponentDelete();
}

class _SingleTeamNewTeamOpponent extends SingleTeamOpponentEvent {
  final Opponent newOpponent;

  _SingleTeamNewTeamOpponent({@required this.newOpponent});
}

class _SingleTeamOpponentDeleted extends SingleTeamOpponentEvent {
  _SingleTeamOpponentDeleted();
}

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
  }

  @override
  SingleTeamOpponentState get initialState =>
      SingleTeamOpponentUninitalized(teamUid: teamUid);

  @override
  Stream<SingleTeamOpponentState> mapEventToState(
      SingleTeamOpponentEvent event) async* {
    if (event is _SingleTeamNewTeamOpponent) {
      yield SingleTeamOpponentLoaded(
          teamUid: teamUid,
          opponent: event.newOpponent,
          opponentUid: opponentUid);
    }

    // The team is deleted.
    if (event is _SingleTeamOpponentDeleted) {
      yield SingleTeamOpponentDeleted(
          teamUid: teamUid,
          opponent: currentState.opponent,
          opponentUid: opponentUid);
    }

    // Save the team.
    if (event is SingleTeamOpponentUpdate) {
      yield SingleTeamOpponentSaving(
          teamUid: currentState.teamUid,
          opponent: currentState.opponent,
          opponentUid: opponentUid);
      try {
        await teamBloc.coordinationBloc.databaseUpdateModel
            .updateFirestoreOpponent(event.opponent.build());
        yield SingleTeamOpponentLoaded(
            teamUid: teamUid,
            opponent: event.opponent.build(),
            opponentUid: opponentUid);
      } catch (e) {
        yield SingleTeamOpponentSaveFailed(
            teamUid: currentState.teamUid,
            opponent: currentState.opponent,
            opponentUid: currentState.opponentUid,
            error: e);
      }
    }
  }
}
