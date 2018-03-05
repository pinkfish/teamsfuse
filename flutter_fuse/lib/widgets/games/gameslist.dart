import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';

class GameList extends StatelessWidget {
  Widget _buildGames(BuildContext context, AsyncSnapshot<UpdateReason> reason) {
    List<Game> games = UserDatabaseData.instance.games.values.toList();
    games.sort(
        (a, b) => a.time.compareTo(b.time)
    );
    DateTime time = new DateTime.fromMicrosecondsSinceEpoch(0);
    List<Widget> widgets = new List<Widget>();

    games.forEach((game) {
      if (time.year != game.tzTime.year ||
          time.month != game.tzTime.month ||
          time.day != game.tzTime.day) {
        // Put in the header.
        String header = MaterialLocalizations.of(context).formatMediumDate(game.tzTime);
        time = game.tzTime;
        Theme.of(context).textTheme.subhead;
        widgets.add(new ListTile(
          title: new Text(header,
          style: Theme.of(context).textTheme.headline),
        ));
      }
      widgets.add(new GameCard(game));
    });

    return new Column(
      children: widgets
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: UserDatabaseData.instance.gameStream,
        builder: this._buildGames
    );
  }
}