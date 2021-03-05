import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:intl/intl.dart';

import '../../../services/messages.dart';
import '../../player/playername.dart';

/// Signature for when a tap has occurred on a GameEventWidget
typedef GameEventTapCallback = void Function(GameEvent ev);

///
/// Shows a game event, for use in lists.  It models the event as a card
/// that can be places inside other lists and places.
///
class GameEventWidget extends StatelessWidget {
  /// The game event to display.
  final GameEvent gameEvent;

  /// The timestamp, if we should show it.
  final bool showTimestamp;

  /// If we shouldshow the period name.
  final bool showPeriod;

  /// If we should show the name of the player.
  final bool showName;

  /// What to call when we tap on this event/
  final GameEventTapCallback onTap;

  /// The format for the datetime.
  static DateFormat format = DateFormat('HH:mm');

  /// The widget to display the game event
  GameEventWidget(
      {@required this.gameEvent,
      this.showTimestamp = false,
      this.showPeriod = false,
      this.showName = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getColor(context),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () => onTap(gameEvent),
          child: Row(
            children: [
              SizedBox(
                width: showTimestamp ? 80.0 : 0.0,
                child: showTimestamp
                    ? Text(
                        format.format(gameEvent.timestamp),
                        textScaleFactor: 1.2,
                      )
                    : Text(""),
              ),
              Text(
                Messages.of(context).getGameEventType(gameEvent),
                style: Theme.of(context).textTheme.headline6,
                textScaleFactor: 1.2,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
              SizedBox(width: 20.0),
              Text(
                showPeriod
                    ? Messages.of(context).getPeriodName(gameEvent.period)
                    : "",
                softWrap: true,
                overflow: TextOverflow.fade,
                textScaleFactor: 1.2,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(width: 20.0),
              gameEvent.playerUid != null && gameEvent.playerUid.isNotEmpty
                  ? showName
                      ? PlayerName(
                          playerUid: gameEvent.playerUid,
                        )
                      : SizedBox(width: 0)
                  : showPeriod
                      ? SizedBox(
                          width: 0,
                        )
                      : Text(
                          Messages.of(context).getPeriodName(gameEvent.period),
                          style: Theme.of(context).textTheme.bodyText2,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    Color c = Theme.of(context).cardColor;

    switch (gameEvent.type) {
      case GameEventType.Made:
        return c.withRed(50);
      case GameEventType.Missed:
        return c.withGreen(50);
      case GameEventType.Steal:
      case GameEventType.Turnover:
      case GameEventType.Block:
      case GameEventType.Foul:
      case GameEventType.DefensiveRebound:
      case GameEventType.OffsensiveRebound:
        return c.withBlue(50);
      case GameEventType.PeriodEnd:
      case GameEventType.PeriodStart:
      case GameEventType.PeriodStart:
      case GameEventType.Sub:
      case GameEventType.TimeoutStart:
      case GameEventType.TimeoutEnd:
        return c;
      default:
        throw ArgumentError(gameEvent.type.toString());
    }
  }
}
