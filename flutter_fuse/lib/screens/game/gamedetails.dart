import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamedetails.dart';
import 'package:flutter_fuse/widgets/games/availability.dart';
import 'package:flutter_fuse/widgets/games/deletegamedialog.dart';

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

  void _deleteGame() async {
    bool deleted = await deleteGameDialog(context, game);
    if (deleted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent opponent = team.opponents[game.opponentUid];
    List<Widget> actions = new List<Widget>();

    if (_tabIndex == 0) {
      body = new GameDetails(game);
    } else {
      body = new Availaility(game);
    }

    if (team.isAdmin(UserDatabaseData.instance.players)) {
      actions.add(
        new FlatButton(
          onPressed: this._deleteGame,
          child: new Text(
            Messages.of(context).deletebuttontext,
            style: Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.white),
          ),
        ),
      );
      actions.add(
        new FlatButton(
          onPressed: this._editGame,
          child: new Text(
            Messages.of(context).editbuttontext,
            style: Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.white),
          ),
        ),
      );
    }
    String opponentName;
    if (opponent != null) {
      opponentName = opponent.name;
    } else {
      opponentName = Messages.of(context).unknown;
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).gametitlevs(game, opponentName)),
        actions: actions,
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
            title: new Text(Messages.of(context).gameavailability),
          )
        ],
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: body,
        ),
      ),
    );
  }
}
