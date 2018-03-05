import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fuse/services/messages.dart';

class GameCard extends StatelessWidget {
  Game game;

  GameCard(this.game);

  Widget build(BuildContext context) {
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent op = team.opponents[game.opponentUid];
    String opName;
    if (op == null) {
      opName = Messages.of(context).unknown;
    } else {
      opName = op.name;
    }
    TimeOfDay day = new TimeOfDay.fromDateTime(game.tzTime);
    String format = MaterialLocalizations.of(context).formatTimeOfDay(day);

    AssetImage image = new AssetImage('assets/sports/' + team.sport.toString() + '.png');

    return new Card(
      child: new ListTile(
        leading: new DecoratedBox(decoration: new BoxDecoration(image: new DecorationImage(image: image))),
        title: new Row(
          children: <Widget>[
            new Text(format + ' vs ', style: new TextStyle( fontWeight: FontWeight.bold )),
            new Text(opName)
          ],
        ),
        subtitle: new Text(game.place.address),
      ),
    );
  }
}