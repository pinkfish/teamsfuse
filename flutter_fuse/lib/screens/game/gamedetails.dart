import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/games/gamedetails.dart';
import 'package:flutter_fuse/widgets/games/availability.dart';
import 'package:flutter_fuse/widgets/games/deletegamedialog.dart';

class GameDetailsScreen extends StatefulWidget {
  GameDetailsScreen(this.gameUid);

  final String gameUid;

  @override
  GameDetailsScreenState createState() {
    return new GameDetailsScreenState();
  }
}

class GameDetailsScreenState extends State<GameDetailsScreen> {
  Game game;
  int _tabIndex = 0;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    game = UserDatabaseData.instance.gamesCache[widget.gameUid];
  }


  void _select(String choice) async {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {});
    if (choice == 'delete') {
      // Show a dialog and then delete it!
      bool deleted = await deleteGameDialog(context, game);
      if (deleted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditGame/" + widget.gameUid);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    Team team = UserDatabaseData.instance.teams[game.teamUid];
    Opponent opponent;
    if (game.sharedData.type == EventType.Game && game.opponentUids.length > 0) {
      opponent = team.opponents[game.opponentUids[0]];
    }
    List<Widget> actions = <Widget>[];

    if (_tabIndex == 0) {
      body = new GameDetails(game);
    } else {
      body = new Availaility(game);
    }

    if (team.isAdmin()) {
      actions.add(
        new PopupMenuButton<String>(
          onSelected: _select,
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem<String>>[
              new PopupMenuItem<String>(
                value: "delete",
                child: new Text(Messages.of(context).deletegame(game)),
              ),
            ];
          },
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
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: const Icon(Icons.gamepad),
            title: new Text(Messages.of(context).details),
          ),
          new BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            title: new Text(Messages.of(context).gameavailability),
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _editGame,
        child: new Icon(Icons.edit),
        //backgroundColor: Colors.orange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
