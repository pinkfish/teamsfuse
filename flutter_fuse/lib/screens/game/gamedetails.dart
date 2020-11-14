import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singlegameprovider.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/games/availability.dart';
import '../../widgets/games/deletegamedialog.dart';
import '../../widgets/games/gamedetails.dart';

///
/// Show the dtails of the game.
///
class GameDetailsScreen extends StatefulWidget {
  /// Constructor.
  GameDetailsScreen(this.gameUid);

  /// The game to sho0w the details of
  final String gameUid;

  @override
  _GameDetailsScreenState createState() {
    return _GameDetailsScreenState();
  }
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  int _tabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  void _select(String choice, SingleGameBloc gameBloc) async {
    // Causes the app to rebuild with the new- _selectedChoice.
    setState(() {});
    if (choice == 'delete') {
      // Show a dialog and then delete it!
      var deleted = await deleteGameDialog(context, gameBloc);
      if (deleted) {
        Navigator.pop(context);
      }
    }
  }

  void _editGame() {
    Navigator.pushNamed(context, "EditGame/${widget.gameUid}");
  }

  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: widget.gameUid,
      builder: (conrtext, gameBloc) => BlocBuilder(
        cubit: gameBloc,
        builder: (context, gameState) => SingleTeamProvider(
          teamUid: gameState.game.teamUid,
          builder: (c, teamBloc) => BlocListener(
            cubit: teamBloc,
            listener: (context, state) {
              if (state is SingleTeamLoaded) {
                teamBloc.add(SingleTeamLoadOpponents());
              }
            },
            child: BlocBuilder(
              cubit: teamBloc,
              builder: (context, singleTeamState) {
                Game game = gameState.game;
                Widget body;
                var actions = <Widget>[];
                var opponentName = Messages.of(context).unknown;

                if (!singleTeamState.loadedOpponents) {
                  teamBloc.add(SingleTeamLoadOpponents());
                }

                if (singleTeamState is SingleTeamUninitialized ||
                    !singleTeamState.loadedOpponents) {
                  body = Text(Messages.of(context).loading);
                } else {
                  // This will return null if the opponent does not exist.
                  var opponent = singleTeamState.opponents[game.opponentUid];

                  if (_tabIndex == 0) {
                    body = GameDetails(gameBloc);
                  } else {
                    body = Availaility(gameBloc);
                  }

                  if (singleTeamState.isAdmin()) {
                    actions.add(
                      PopupMenuButton<String>(
                        onSelected: (str) => _select(str, gameBloc),
                        itemBuilder: (context) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              value: "delete",
                              child: Text(Messages.of(context)
                                  .deletegame(game.sharedData)),
                            ),
                          ];
                        },
                      ),
                    );
                  }
                  if (opponent != null) {
                    opponentName = opponent.name;
                  }
                }

                return Scaffold(
                  appBar: AppBar(
                    title: Text(Messages.of(context)
                        .gametitlevs(gameState.game.sharedData, opponentName)),
                    actions: actions,
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    onTap: (index) {
                      setState(() {
                        _tabIndex = index;
                      });
                    },
                    currentIndex: _tabIndex,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.gamepad),
                        label: Messages.of(context).details,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.people),
                        label: Messages.of(context).gameavailability,
                      )
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _editGame,
                    child: Icon(Icons.edit),
                    //backgroundColor: Colors.orange,
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  body: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      controller: _scrollController,
                      child: AnimatedSwitcher(
                        child: body,
                        duration: Duration(milliseconds: 500),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
