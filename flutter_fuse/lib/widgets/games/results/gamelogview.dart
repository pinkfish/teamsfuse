import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';

///
/// Shows the game log on the screen.
///
class GameLogView extends StatelessWidget {
  /// Constructor.
  GameLogView(this.game) {
    game.add(SingleGameLoadGameLog());
  }

  /// The game the bloc is in.
  final SingleGameBloc game;

  Widget _buildGameItem(
      BuildContext context, GameLog log, TextStyle subheadStyle) {
    Widget subtitle;
    switch (log.type) {
      case GameLogType.Message:
        subtitle = Text(log.message, style: subheadStyle);
        break;
      case GameLogType.PeriodStart:
        subtitle =
            Text(Messages.of(context).periodstart(log), style: subheadStyle);
        break;
      case GameLogType.PeriodStop:
        subtitle = Text(
          Messages.of(context).periodstop(log),
          style: subheadStyle,
        );
        break;
      case GameLogType.ScoreUpdate:
        subtitle = Text(
          Messages.of(context).onlyScore(log.score),
          style: subheadStyle,
        );
        break;
      case GameLogType.UpdateScore:
        subtitle = Text(
          Messages.of(context).fixScore(log),
          style: subheadStyle,
        );
        break;
    }
    return ListTile(
      leading: CircleAvatar(
        child: Text(log.initials()),
      ),
      title: Text(
          MaterialLocalizations.of(context).formatFullDate(log.eventTime),
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(color: Colors.grey, fontSize: 15.0)),
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force the logs to load if they are not already.
    return BlocBuilder(
      cubit: game,
      builder: (context, state) {
        var subheadStyle = Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: Colors.black, fontSize: 20.0);
        var logs = state.gameLog.toList();

        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return _buildGameItem(context, logs[index], subheadStyle);
          },
          itemCount: logs.length,
        );
      },
    );
  }
}
