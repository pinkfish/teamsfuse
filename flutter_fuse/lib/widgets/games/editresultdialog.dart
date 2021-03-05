import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../blocs/singleteamprovider.dart';
import 'results/gamelogview.dart';
import 'results/messagesend.dart';
import 'results/scoredetails.dart';

///
/// Dialog to edit the result of the game.
///
class EditResultDialog extends StatelessWidget {
  /// Constructor.
  EditResultDialog(this._game) {
    _game.add(SingleGameLoadGameLog());
  }

  final SingleGameBloc _game;

  Widget _buildGame(
      BuildContext context, Game game, Team team, Opponent opponent) {
    var theme = Theme.of(context);
    var resultStr = '';

    if (game.result.inProgress == GameInProgress.Final) {
      switch (game.result.result) {
        case GameResult.Loss:
          resultStr = Messages.of(context).resultLoss(game.result);
          break;
        case GameResult.Tie:
          resultStr = Messages.of(context).resultTie(game.result);
          break;
        case GameResult.Win:
          resultStr = Messages.of(context).resultWin(game.result);
          break;
        default:
          resultStr = Messages.of(context).gameresult(game.result.result);
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${Messages.of(context).gameTitleVs(game.sharedData, opponent?.name ?? Messages.of(context).unknown)}  $resultStr',
          overflow: TextOverflow.clip,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              constraints: BoxConstraints(),
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              decoration: BoxDecoration(color: theme.cardColor),
              child: GameLogView(_game),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: 10.0, right: 10.0, bottom: 10.0, top: 1.0),
            child: MessageSendBox(_game),
          ),
          ScoreDetails(_game, team),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: _game,
      listener: (context, state) {
        if (state is SingleGameDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
        cubit: _game,
        builder: (context, state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return SingleTeamProvider(
            teamUid: state.game.teamUid,
            builder: (context, teamBloc) => BlocBuilder(
              cubit: teamBloc,
              builder: (context, teamState) => _buildGame(context, state.game,
                  teamState.team, teamState.opponents[state.game.opponentUid]),
            ),
          );
        },
      ),
    );
  }
}
