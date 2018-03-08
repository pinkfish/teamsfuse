import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamedetails.dart';
import 'package:flutter_fuse/widgets/games/availability.dart';

import 'dart:async';

class GameDetailsScreen extends StatefulWidget {
  GameDetailsScreen(this.gameUid);

  final String gameUid;

  @override
  GameDetailsScreenState createState() {
    return new GameDetailsScreenState(gameUid);
  }
}

class GameDetailsScreenState extends State<GameDetailsScreen> {
  final String gameUid;
  Game game;
  int _tabIndex = 0;
  ScrollController _scrollController = new ScrollController();

  GameDetailsScreenState(this.gameUid) {
    game = UserDatabaseData.instance.games[gameUid];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditGame/" + gameUid);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent opponent = team.opponents[game.opponentUid];

    if (_tabIndex == 0) {
      body = new GameDetails(gameUid);
    } else {
      body = new Availaility(game);
    }

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).gametitlevs(opponent.name)),
          actions: <Widget>[
            new FlatButton(
                onPressed: this._editGame,
                child: new Text(Messages.of(context).editbuttontext,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.white))),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              _tabIndex = index;
            });
          },
            currentIndex: _tabIndex,
            items: [
          new BottomNavigationBarItem(
            icon: const Icon(Icons.gamepad),
            title: new Text(Messages.of(context).gamedetails),
          ),
          new BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              title: new Text(Messages.of(context).gameavailability))
        ]),
        body: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: body,
        ));
  }
}
