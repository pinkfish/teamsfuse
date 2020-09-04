import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../blocs/singleteamprovider.dart';
import 'results/gamelogview.dart';
import 'results/messagesend.dart';
import 'results/scoredetails.dart';

class EditResultDialog extends StatelessWidget {
  EditResultDialog(this._game) {
    _game.add(SingleGameLoadGameLog());
  }

  final SingleGameBloc _game;

  Widget buildGame(
      BuildContext context, Game game, Team team, Opponent opponent) {
    ThemeData theme = Theme.of(context);
    String resultStr = "";

    if (game.result.inProgress == GameInProgress.Final) {
      switch (game.result.result) {
        case GameResult.Loss:
          resultStr = Messages.of(context).resultloss(game.result);
          break;
        case GameResult.Tie:
          resultStr = Messages.of(context).resulttie(game.result);
          break;
        case GameResult.Win:
          resultStr = Messages.of(context).resultwin(game.result);
          break;
        default:
          resultStr = Messages.of(context).gameresult(game.result.result);
          break;
      }
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context).gametitlevs(game.sharedData, opponent.name) +
              "  " +
              resultStr,
          overflow: TextOverflow.clip,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomPadding: true,
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            child: new Container(
              constraints: new BoxConstraints(),
              margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
              decoration: new BoxDecoration(color: theme.cardColor),
              child: new GameLogView(_game),
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(
                left: 10.0, right: 10.0, bottom: 10.0, top: 1.0),
            child: new MessageSendBox(_game),
          ),
          new ScoreDetails(_game, team),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: _game,
      listener: (BuildContext context, SingleGameState state) {
        if (state is SingleGameDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
        cubit: _game,
        builder: (BuildContext context, SingleGameState state) {
          if (state is SingleGameDeleted) {
            return CircularProgressIndicator();
          }
          return SingleTeamProvider(
            teamUid: state.game.teamUid,
            builder: (BuildContext context, SingleTeamBloc teamBloc) =>
                BlocBuilder(
              cubit: teamBloc,
              builder: (BuildContext context, SingleTeamState teamState) =>
                  buildGame(context, state.game, teamState.team,
                      teamState.opponents[state.game.opponentUids[0]]),
            ),
          );
        },
      ),
    );
  }
}
