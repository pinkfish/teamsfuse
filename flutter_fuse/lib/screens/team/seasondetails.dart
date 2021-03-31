import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/games/basketball/gametile.dart';
import '../../widgets/player/playertilebasketball.dart';
import '../../widgets/util/deleted.dart';
import '../../widgets/util/loading.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Screen for displaying all the details about the specified season.
///
class SeasonDetailsScreen extends StatefulWidget {
  final String seasonUid;

  SeasonDetailsScreen({@required this.seasonUid});

  @override
  State<StatefulWidget> createState() {
    return _SeasonDetailsScreenState();
  }
}

class _SeasonDetailsScreenState extends State<SeasonDetailsScreen> {
  int _currentIndex = 0;

  Widget _innerData(SingleSeasonState state) {
    if (_currentIndex == 0) {
      Widget inner;
      if (!state.loadedGames) {
        inner = Center(
          child: Text(
            Messages.of(context).loading,
            textScaleFactor: 2.0,
          ),
        );
      } else if (state.games.isEmpty) {
        inner = Center(
          child: Text(
            Messages.of(context).noGames,
            textScaleFactor: 2.0,
          ),
        );
      } else {
        inner = ListView(
          children: state.games
              .map(
                (Game g) => Padding(
                    padding: EdgeInsets.all(5.0),
                    child: GameTile(
                      game: g,
                      onTap: () =>
                          Navigator.pushNamed(context, '/Season/View/' + g.uid),
                    )),
              )
              .toList(),
        );
      }
      return Column(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text(
                state.season.name,
                textScaleFactor: 1.5,
              ),
              subtitle: Text(
                '${state.season.playersData.length} players',
                textScaleFactor: 1.5,
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => Navigator.pushNamed(
                    context, '/Season/Edit/' + widget.seasonUid),
              ),
            ),
          ),
          Expanded(
            child: inner,
          ),
        ],
      );
    } else {
      if (state.season.playersData.isEmpty) {
        return Center(
          child: Text(Messages.of(context).noPlayers),
        );
      }
      return ListView(
        children: state.season.playersData.keys
            .map((String str) => PlayerTileBasketball(
                  playerUid: str,
                  onTap: (String playerUid) => Navigator.pushNamed(
                      context,
                      '/PlayerDetails/' +
                          state.season.teamUid +
                          '/' +
                          state.season.uid +
                          '/' +
                          str),
                ))
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        var bloc = SingleSeasonBloc(
            db: RepositoryProvider.of<DatabaseUpdateModel>(context),
            seasonUid: widget.seasonUid,
            crashes: RepositoryProvider.of<AnalyticsSubsystem>(context));
        bloc.add(SingleSeasonLoadGames());
        return bloc;
      },
      child: Builder(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: BlocBuilder(
              bloc: BlocProvider.of<SingleSeasonBloc>(context),
              builder: (BuildContext context, SingleSeasonState state) {
                if (state is SingleSeasonUninitialized ||
                    state is SingleSeasonDeleted) {
                  return Text(Messages.of(context).title);
                }
                return Text(state.season.name);
              },
            ),
          ),
          body: BlocConsumer(
            bloc: BlocProvider.of<SingleSeasonBloc>(context),
            listener: (BuildContext context, SingleSeasonState state) {
              if (!state.loadedGames && !(state is SingleSeasonUninitialized)) {
                BlocProvider.of<SingleSeasonBloc>(context)
                    .add(SingleSeasonLoadGames());
              }
              if (state is SingleSeasonDeleted) {
                Navigator.pop(context);
              }
            },
            builder: (BuildContext context, SingleSeasonState state) {
              if (state is SingleSeasonDeleted) {
                return DeletedWidget();
              }
              if (state is SingleSeasonUninitialized) {
                return LoadingWidget();
              }
              return SavingOverlay(
                  saving: state is SingleSeasonSaving,
                  child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: _innerData(state)));
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int i) => setState(() {
              _currentIndex = i;
            }),
            items: [
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.tshirtCrew),
                label: Messages.of(context).stats,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: Messages.of(context).players,
              ),
            ],
          ),
          floatingActionButton: BlocBuilder(
            bloc: BlocProvider.of<SingleSeasonBloc>(context),
            builder: (BuildContext context, SingleSeasonState state) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: FloatingActionButton.extended(
                  onPressed: _currentIndex == 0
                      ? () => _addGame(context, state.season.uid, state)
                      : () => _addPlayer(context),
                  tooltip: _currentIndex == 0
                      ? Messages.of(context).addGameTooltip
                      : Messages.of(context).addPlayerTooltip,
                  icon: Icon(Icons.add),
                  label: _currentIndex == 0
                      ? Text(Messages.of(context).addGameButton)
                      : Text(Messages.of(context).addPlayerButton),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _addGame(
      BuildContext context, String seasonUid, SingleSeasonState state) {
    if (state.season.playersData.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(Messages.of(context).noPlayers),
          content: Text(
            Messages.of(context).noPlayersForSeasonDialog,
            softWrap: true,
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushNamed(context, '/AddGame/' + seasonUid);
    }
  }

  void _addPlayer(BuildContext context) {
    /*
    SingleSeasonBloc bloc = // ignore: close_sinks
        BlocProvider.of<SingleSeasonBloc>(context);
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AddPlayerSeasonScreen(
              defaultSeasonUid: widget.seasonUid,
            )).then((FutureOr<String> playerUid) {
      if (playerUid == null || playerUid == '') {
        // Canceled.
        return;
      }
      bloc.add(SingleSeasonAddPlayer(playerUid: playerUid));
    });

     */
  }
}
