import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';

class TeamResultsStreamFuture extends StatefulWidget {
  final String seasonUid;
  final String teamUid;
  final String opponentUid;
  TeamResultsStreamFuture(
      {@required this.seasonUid, @required this.teamUid, this.opponentUid});

  @override
  _TeamResultsStreamFutureState createState() {
    return new _TeamResultsStreamFutureState();
  }
}

class _TeamResultsStreamFutureState extends State<TeamResultsStreamFuture> {
  GameSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = UserDatabaseData
        .instance.teams[widget.teamUid].seasons[widget.seasonUid]
        .getGames();
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<Iterable<Game>>(
      stream: _subscription.stream,
      initialData: _subscription.initialData,
      builder: (BuildContext context, AsyncSnapshot<Iterable<Game>> games) {
        if (!games.hasData) {
          return new Center(
            child: new Text(Messages.of(context).loading),
          );
        }
        if (games.data.length == 0) {
          return new Center(
            child: new Text(Messages.of(context).nogames),
          );
        } else {
          List<Widget> newData = <Widget>[];
          List<Game> gameSort = games.data.toList();
          gameSort
              .sort((Game g1, Game g2) => g1.sharedData.time.toInt() - g2.sharedData.time.toInt());
          TZDateTime lastTime;
          for (Game game in gameSort) {
            if (game.sharedData.type == EventType.Game &&
                (widget.opponentUid == null ||
                    game.opponentUids.contains(widget.opponentUid))) {
              if (lastTime == null ||
                  lastTime.year != game.sharedData.tzTime.year ||
                  lastTime.month != game.sharedData.tzTime.month ||
                  lastTime.day != game.sharedData.tzTime.day) {
                bool showYear = false;
                if (lastTime == null || lastTime.year != game.sharedData.tzTime.year) {
                  showYear = true;
                }

                String textToShow;
                if (showYear) {
                  textToShow = MaterialLocalizations
                          .of(context)
                          .formatMediumDate(game.sharedData.tzTime) +
                      " " +
                      MaterialLocalizations.of(context).formatYear(game.sharedData.tzTime);
                } else {
                  textToShow = MaterialLocalizations
                      .of(context)
                      .formatMediumDate(game.sharedData.tzTime);
                }
                newData.add(
                  new Container(
                    margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                    child: new Text(
                      textToShow,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
              }
              newData.add(new GameCard(game));
            }
          }
          if (newData.length == 0) {
            newData.add(new Text(Messages.of(context).nogames));
          }
          return new Column(
            children: newData,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.dispose();
    _subscription = null;
  }
}
