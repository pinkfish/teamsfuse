import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

import 'results/gamelogview.dart';
import 'results/messagesend.dart';
import 'results/scoredetails.dart';

class EditResultDialog extends StatelessWidget {
  EditResultDialog(this._game)
      : _team = UserDatabaseData.instance.teams[_game.teamUid] ?? new Team(),
        _opponent = UserDatabaseData.instance.teams[_game.teamUid]
                ?.opponents[_game.opponentUids[0]] ??
            new Opponent() {
    _game.loadGameLogs();
  }

  final Game _game;
  final Team _team;
  final Opponent _opponent;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String resultStr = "";

    if (_game.result.inProgress == GameInProgress.Final) {
      switch (_game.result.result) {
        case GameResult.Loss:
          resultStr = Messages.of(context).resultloss(_game.result);
          break;
        case GameResult.Tie:
          resultStr = Messages.of(context).resulttie(_game.result);
          break;
        case GameResult.Win:
          resultStr = Messages.of(context).resultwin(_game.result);
          break;
        default:
          resultStr = Messages.of(context).gameresult(_game.result.result);
          break;
      }
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context).gametitlevs(_game.sharedData, _opponent.name) +
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
          new ScoreDetails(_game, _team),
        ],
      ),
    );
  }
}
