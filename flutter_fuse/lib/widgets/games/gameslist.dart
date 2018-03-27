import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'emptygamelist.dart';
import 'dart:async';

class GameList extends StatefulWidget {
  FilterDetails details;

  GameList(this.details);

  @override
  GameListState createState() {
    return new GameListState();
  }
}

class GameListState extends State<GameList> {
  StreamSubscription<UpdateReason> _updateStream;
  Iterable<Game> _listToShow;

  @override
  void initState() {
    _updateStream =
        UserDatabaseData.instance.gameStream.listen((UpdateReason update) {
      setState(() {});
      UserDatabaseData.instance
          .getGames(widget.details)
          .then((Iterable<Game> res) {
        setState(() {
          _listToShow = res;
        });
      });
    });
    UserDatabaseData.instance
        .getGames(widget.details)
        .then((Iterable<Game> res) {
      setState(() {
        _listToShow = res;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _updateStream.cancel();
    _updateStream = null;
  }

  Widget _buildGames(BuildContext context, AsyncSnapshot<UpdateReason> reason) {
    if (_listToShow == null) {
      return new ListTile(
        leading: const CircularProgressIndicator(),
        title: new Text(Messages.of(context).loading),
      );
    }

    // Find the games.
    List<Game> games = _listToShow.toList();
    games.sort((a, b) => a.time.compareTo(b.time));
    DateTime time = new DateTime.fromMicrosecondsSinceEpoch(0);
    List<Widget> widgets = new List<Widget>();

    // Only show the loading in the main bit if we have no games.
    if (!UserDatabaseData.instance.loadedDatabase && games.length == 0) {
      widgets.add(
        new ListTile(
          leading: const CircularProgressIndicator(),
          title: new Text(Messages.of(context).loading),
        ),
      );
    }

    games.forEach((game) {
      if (time.year != game.tzTime.year ||
          time.month != game.tzTime.month ||
          time.day != game.tzTime.day) {
        // Put in the header.
        String header =
            MaterialLocalizations.of(context).formatMediumDate(game.tzTime);
        time = game.tzTime;
        Theme.of(context).textTheme.subhead;
        widgets.add(new ListTile(
          title: new Text(header, style: Theme.of(context).textTheme.headline),
        ));
      }
      widgets.add(new GameCard(game));
    });

    if (games.isEmpty) {
      if (UserDatabaseData.instance.games.length > 0) {} else {
        widgets.add(
          new ListTile(
            leading: const Icon(Icons.tune),
            title: new Text(Messages.of(context).nogamesfiltered),
          ),
        );

        widgets.add(new EmptyGameList());
      }
    }

    return new Column(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: UserDatabaseData.instance.gameStream,
        builder: this._buildGames);
  }
}
