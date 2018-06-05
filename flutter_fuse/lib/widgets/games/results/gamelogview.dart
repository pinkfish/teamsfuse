import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class GameLogView extends StatelessWidget {
  final Game game;

  GameLogView(this.game);

  Widget _buildGameItem(BuildContext context, GameLog log, TextStyle subheadStyle) {
    Widget subtitle;
    switch (log.type) {
      case GameLogType.Message:
        subtitle = new Text(log.message,
            style: subheadStyle);
        break;
      case GameLogType.PeriodStart:
        subtitle = new Text(
            Messages
                .of(context)
                .periodstart(log),
            style: subheadStyle);
        break;
      case GameLogType.PeriodStop:
        subtitle = new Text(
          Messages.of(context).periodstop(log),
          style: subheadStyle,
        );
        break;
      case GameLogType.ScoreUpdate:
        subtitle = new Text(
          Messages
              .of(context)
              .onlyscore(log.score),
          style: subheadStyle,
        );
        break;
      case GameLogType.UpdateScore:
        subtitle = new Text(
          Messages.of(context).fixscore(log),
          style: subheadStyle,
        );
        break;
    }
    print("$log");
    return new ListTile(
      leading: new CircleAvatar(
        child: new Text(log.initials()),
      ),
      title: new Text(
          MaterialLocalizations
              .of(context)
              .formatFullDate(log.eventTime),
          style: Theme
              .of(context)
              .textTheme
              .subhead
              .copyWith(
              color: Colors.grey, fontSize: 15.0)),
      subtitle: subtitle,
    );
  }

  Widget build(BuildContext context) {
    // Force the logs to load if they are not already.
    game.loadGameLogs();
    return new StreamBuilder(
      stream: game.thisGameLogStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<GameLog>> logs) {
            TextStyle subheadStyle = Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.black, fontSize: 20.0);
          if (logs.hasData) {
            return new ListView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return _buildGameItem(context, logs.data[index], subheadStyle);
              },
              itemCount: logs.data.length,
            );
          }
          return new ListView.builder(
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return _buildGameItem(context, game.logs[index], subheadStyle);
            },
            itemCount: game.logs.length,
          );
      },
    );
  }
}
