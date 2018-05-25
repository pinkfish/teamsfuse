import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class GameLogView extends StatelessWidget {
  final Game game;

  GameLogView(this.game);

  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: game.thisGameLogStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<GameLog>> logs) {
          TextStyle subheadStyle = Theme
              .of(context)
              .textTheme
              .subhead
              .copyWith(color: Colors.black, fontSize: 20.0);
          return new ListView.builder(
            scrollDirection: Axis.vertical,
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              GameLog log = game.logs[game.logs.length - index - 1];
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
              }
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
            },
            itemCount: game.logs.length,
          );
      },
    );
  }
}
