import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/player/playerimage.dart';
import '../../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../../services/messages.dart';

///
/// Shows the game log on the screen.
///
class GameLogView extends StatelessWidget {
  /// Constructor.
  GameLogView(this.game) {
    game.add(SingleGameLoadEvents());
  }

  /// The game the bloc is in.
  final SingleGameBloc game;

  Widget _buildGameItem(
      BuildContext context, GameEvent log, TextStyle subheadStyle) {
    Widget subtitle;
    switch (log.type) {
      case GameEventType.Message:
        subtitle = Text(log.message, style: subheadStyle);
        break;
      case GameEventType.PeriodStart:
        subtitle = Text(
            Messages.of(context)
                .periodStartText(Messages.of(context).periodName(log.period)),
            style: subheadStyle);
        break;
      case GameEventType.PeriodEnd:
        subtitle = Text(
          Messages.of(context)
              .periodEnd(Messages.of(context).periodName(log.period)),
          style: subheadStyle,
        );
        break;
      case GameEventType.ScoreSet:
        subtitle = Text(
          Messages.of(context).onlyScore(log.fixedScore),
          style: subheadStyle,
        );
        break;
    }
    return ListTile(
      leading: CircleAvatar(
        child: PlayerImage(playerUid: log.playerUid),
      ),
      title: Text(
          MaterialLocalizations.of(context).formatFullDate(log.timestamp),
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
      bloc: game,
      builder: (context, SingleGameState state) {
        var subheadStyle = Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(color: Colors.black, fontSize: 20.0);
        var logs = state.gameEvents.toList();

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
