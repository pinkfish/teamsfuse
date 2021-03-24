import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singlegameprovider.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/games/availability.dart';
import '../../widgets/games/basketball/gameshotlocations.dart';
import '../../widgets/games/basketball/gametimeseries.dart';
import '../../widgets/games/basketball/playerdatatable.dart';
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
    } else if (choice == 'edit') {
      await Navigator.pushNamed(context, 'EditGame/${widget.gameUid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleGameProvider(
      gameUid: widget.gameUid,
      builder: (context, gameBloc) => BlocConsumer(
        bloc: gameBloc,
        listener: (context, gameState) {
          if (gameState is SingleGameDeleted) {
            Navigator.pop(context);
          }
        },
        builder: (context, gameState) {
          if (gameState is SingleGameUninitialized ||
              gameState is SingleGameDeleted) {
            return LoadingWidget();
          }

          return SingleTeamProvider(
            teamUid: gameState.game.teamUid,
            builder: (c, teamBloc) => BlocConsumer(
              bloc: teamBloc,
              listener: (context, state) {
                if (state is SingleTeamLoaded) {
                  teamBloc.add(SingleTeamLoadOpponents());
                }
              },
              builder: (context, singleTeamState) {
                Game game = gameState.game;
                Widget body;
                var actions = <Widget>[];
                var opponentName = Messages.of(context).unknown;

                if (!singleTeamState.loadedOpponents) {
                  teamBloc.add(SingleTeamLoadOpponents());
                }
                var navItems = <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.gamepad),
                    label: Messages.of(context).details,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.people),
                    label: Messages.of(context).gameavailability,
                  )
                ];

                if (singleTeamState is SingleTeamUninitialized ||
                    !singleTeamState.loadedOpponents) {
                  body = Text(Messages.of(context).loading);
                } else {
                  // This will return null if the opponent does not exist.
                  var opponent = singleTeamState.opponents[game.opponentUid];

                  if (singleTeamState.team.sport == Sport.Basketball) {
                    navItems.add(BottomNavigationBarItem(
                      icon: const Icon(MdiIcons.graph),
                      label: Messages.of(context).stats,
                    ));
                    navItems.add(BottomNavigationBarItem(
                      icon: const Icon(MdiIcons.basketball),
                      label: Messages.of(context).shots,
                    ));
                  }

                  if (_tabIndex == 0) {
                    body = SingleChildScrollView(
                      child: GameDetails(gameBloc),
                    );
                  } else if (_tabIndex == 1) {
                    if (game.result.inProgress != GameInProgress.NotStarted &&
                        singleTeamState?.team?.sport == Sport.Basketball) {
                      body = OrientationBuilder(
                        builder: (context, orientation) => PlayerDataTable(
                            game: gameState, orientation: orientation),
                      );
                    } else {
                      body = Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          controller: _scrollController,
                          child: Availaility(gameBloc),
                        ),
                      );
                    }
                  } else if (_tabIndex == 2) {
                    if (!gameState.loadedEvents) {
                      gameBloc.add(SingleGameLoadEvents());
                    }
                    body = GameTimeseries(state: gameState);
                  } else {
                    if (!gameState.loadedEvents) {
                      gameBloc.add(SingleGameLoadEvents());
                    }
                    body = GameShotLocations(state: gameState);
                  }

                  if (singleTeamState.isAdmin()) {
                    actions.add(
                      PopupMenuButton<String>(
                        onSelected: (str) => _select(str, gameBloc),
                        itemBuilder: (context) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text(Messages.of(context)
                                  .deletegame(game.sharedData)),
                            ),
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text(Messages.of(context).editGame),
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
                        .gameTitleVs(gameState.game.sharedData, opponentName)),
                    actions: actions,
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    onTap: (index) {
                      setState(() {
                        _tabIndex = index;
                      });
                    },
                    currentIndex: _tabIndex,
                    items: navItems,
                  ),
                  body: AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    child: body,
                  ),
                  floatingActionButton:
                      gameState.game.result.inProgress == GameInProgress.Final
                          ? null
                          : FloatingActionButton.extended(
                              icon: Icon(MdiIcons.graph),
                              label: Text(Messages.of(context).statsButton),
                              onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/GameStats/' +
                                      gameState.game.uid +
                                      '/' +
                                      gameState.game.seasonUid +
                                      '/' +
                                      gameState.game.teamUid),
                            ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
