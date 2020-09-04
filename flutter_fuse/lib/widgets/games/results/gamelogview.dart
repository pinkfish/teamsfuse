import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class GameLogView extends StatelessWidget {
  GameLogView(this.game) {
    game.add(SingleGameLoadGameLog());
  }

  final SingleGameBloc game;

  Widget _buildGameItem(
      BuildContext context, GameLog log, TextStyle subheadStyle) {
    Widget subtitle;
    switch (log.type) {
      case GameLogType.Message:
        subtitle = new Text(log.message, style: subheadStyle);
        break;
      case GameLogType.PeriodStart:
        subtitle = new Text(Messages.of(context).periodstart(log),
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
          Messages.of(context).onlyscore(log.score),
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
          MaterialLocalizations.of(context).formatFullDate(log.eventTime),
          style: Theme.of(context)
              .textTheme
              .subhead
              .copyWith(color: Colors.grey, fontSize: 15.0)),
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force the logs to load if they are not already.
    return BlocBuilder(
      cubit: game,
      builder: (BuildContext context, SingleGameState state) {
        TextStyle subheadStyle = Theme.of(context)
            .textTheme
            .subhead
            .copyWith(color: Colors.black, fontSize: 20.0);
        List<GameLog> logs = state.gameLog.toList();

        return new ListView.builder(
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return _buildGameItem(context, logs[index], subheadStyle);
          },
          itemCount: logs.length,
        );
      },
    );
  }
}
