import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singlegameprovider.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:flutter_fuse/widgets/games/availability.dart';
import 'package:flutter_fuse/widgets/games/deletegamedialog.dart';
import 'package:flutter_fuse/widgets/games/gamedetails.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class GameDetailsScreen extends StatefulWidget {
  GameDetailsScreen(this.gameUid);

  final String gameUid;

  @override
  GameDetailsScreenState createState() {
    return new GameDetailsScreenState();
  }
}

class GameDetailsScreenState extends State<GameDetailsScreen> {
  int _tabIndex = 0;
  ScrollController _scrollController = new ScrollController();

  void _select(String choice, SingleGameBloc gameBloc) async {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {});
    if (choice == 'delete') {
      // Show a dialog and then delete it!
      bool deleted = await deleteGameDialog(context, gameBloc);
      if (deleted) {
        Navigator.pop(context);
      }
    }
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditGame/" + widget.gameUid);
  }

  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: widget.gameUid,
      builder: (BuildContext conrtext, SingleGameBloc gameBloc) => BlocBuilder(
        bloc: gameBloc,
        builder: (BuildContext context, SingleGameState gameState) =>
            SingleTeamProvider(
          teamUid: gameState.game.teamUid,
          builder: (BuildContext c, SingleTeamBloc teamBloc) => BlocBuilder(
            bloc: teamBloc,
            builder: (BuildContext context, SingleTeamState singleTeamState) {
              Game game = gameState.game;
              Widget body;
              Team team = singleTeamState.team;
              Opponent opponent =
                  singleTeamState.opponents[game.opponentUids[0]];
              List<Widget> actions = <Widget>[];

              if (_tabIndex == 0) {
                body = new GameDetails(gameBloc);
              } else {
                body = new Availaility(gameBloc);
              }

              if (singleTeamState.isAdmin()) {
                actions.add(
                  new PopupMenuButton<String>(
                    onSelected: (String str) => _select(str, gameBloc),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuItem<String>>[
                        new PopupMenuItem<String>(
                          value: "delete",
                          child: new Text(
                              Messages.of(context).deletegame(game.sharedData)),
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

              return Scaffold(
                appBar: new AppBar(
                  title: new Text(Messages.of(context)
                      .gametitlevs(gameState.game.sharedData, opponentName)),
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                body: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    child: body,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
