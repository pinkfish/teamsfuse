import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'results/gamelogview.dart';
import 'results/messagesend.dart';
import 'results/scoredetails.dart';

class EditResultDialog extends StatelessWidget {
  final Game _game;
  final Team _team;
  final Opponent _opponent;

  EditResultDialog(this._game)
      : _team = UserDatabaseData.instance.teams[_game.teamUid] ?? new Team(),
        _opponent = UserDatabaseData
                .instance.teams[_game.teamUid]?.opponents[_game.opponentUid] ??
            new Opponent() {
    _game.loadGameLogs();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context).gametitlevs(_game, _opponent.name),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomPadding: true,
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
