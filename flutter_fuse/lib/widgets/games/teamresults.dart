import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../blocs/singlegameprovider.dart';
import '../blocs/singleteamopponentprovider.dart';
import '../blocs/singleteamseasonprovider.dart';

///
/// Creates a nice team results section that shows all the games
/// and filters it down by opponent
///
class TeamResultsByOpponent extends StatelessWidget {
  TeamResultsByOpponent({@required this.teamUid, this.opponentUid});

  final String teamUid;
  final String opponentUid;

  @override
  Widget build(BuildContext context) {
    return SingleTeamOpponentProvider(
      teamUid: teamUid,
      opponentUid: opponentUid,
      builder: (BuildContext context, SingleTeamOpponentBloc teamBloc) =>
          BlocListener(
        bloc: teamBloc,
        listener: (BuildContext context, SingleTeamOpponentState state) {
          teamBloc.dispatch(SingleTeamOpponentLoadGames());
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          bloc: teamBloc,
          builder: (BuildContext context, SingleTeamOpponentState state) {
            if (state is SingleTeamOpponentDeleted) {
              return new Center(
                child: new Text(Messages.of(context).loading),
              );
            }
            if (!state.gamesLoaded) {
              return new Center(
                child: new Text(Messages.of(context).nogames),
              );
            } else {
              List<Widget> newData = <Widget>[];
              List<Game> gameSort = state.games.toList();
              gameSort.sort((Game g1, Game g2) =>
                  g1.sharedData.time.toInt() - g2.sharedData.time.toInt());
              TZDateTime lastTime;
              for (Game game in gameSort) {
                if (game.sharedData.type == EventType.Game &&
                    (opponentUid == null ||
                        game.opponentUids.contains(opponentUid))) {
                  if (lastTime == null ||
                      lastTime.year != game.sharedData.tzTime.year ||
                      lastTime.month != game.sharedData.tzTime.month ||
                      lastTime.day != game.sharedData.tzTime.day) {
                    bool showYear = false;
                    if (lastTime == null ||
                        lastTime.year != game.sharedData.tzTime.year) {
                      showYear = true;
                    }

                    String textToShow;
                    if (showYear) {
                      textToShow = MaterialLocalizations.of(context)
                              .formatMediumDate(game.sharedData.tzTime) +
                          " " +
                          MaterialLocalizations.of(context)
                              .formatYear(game.sharedData.tzTime);
                    } else {
                      textToShow = MaterialLocalizations.of(context)
                          .formatMediumDate(game.sharedData.tzTime);
                    }
                    newData.add(
                      new Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: new Text(
                          textToShow,
                          style: Theme.of(context).textTheme.subhead.copyWith(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    );
                  }
                  newData.add(
                    SingleGameProvider(
                      gameUid: game.uid,
                      builder:
                          (BuildContext context, SingleGameBloc gameBloc) =>
                              BlocBuilder(
                        bloc: gameBloc,
                        builder: (BuildContext context, SingleGameState state) {
                          return GameCard(gameUid: state.game.uid);
                        },
                      ),
                    ),
                  );
                }
              }

              if (newData.length == 0) {
                newData.add(new Text(Messages.of(context).nogames));
              }
              return new Column(
                children: newData,
              );
            }
          },
        ),
      ),
    );
  }
}

class TeamResultsBySeason extends StatelessWidget {
  TeamResultsBySeason(
      {@required this.seasonUid, @required this.teamUid, this.opponentUid});

  final String seasonUid;
  final String teamUid;
  final String opponentUid;

  @override
  Widget build(BuildContext context) {
    return SingleTeamSeasonProvider(
      teamUid: teamUid,
      seasonUid: seasonUid,
      builder: (BuildContext context, SingleTeamSeasonBloc seasonBloc) =>
          BlocListener(
        bloc: seasonBloc,
        listener: (BuildContext context, SingleTeamSeasonState state) {
          print('Asking to load games');
          seasonBloc.dispatch(SingleTeamSeasonLoadGames());
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          bloc: seasonBloc,
          builder: (BuildContext context, SingleTeamSeasonState state) {
            print('Building $state');
            seasonBloc.dispatch(SingleTeamSeasonLoadGames());
            if (state is SingleTeamOpponentDeleted) {
              return new Center(
                child: new Text(Messages.of(context).nogames),
              );
            }
            if (!state.loadedGames) {
              return new Center(
                child: new Text(Messages.of(context).loading),
              );
            } else {
              List<Widget> newData = <Widget>[];
              List<Game> gameSort = state.games.toList();
              gameSort.sort((Game g1, Game g2) =>
                  g1.sharedData.time.toInt() - g2.sharedData.time.toInt());
              TZDateTime lastTime;
              for (Game game in gameSort) {
                if (game.sharedData.type == EventType.Game &&
                    (opponentUid != null ||
                        game.opponentUids.contains(opponentUid))) {
                  if (lastTime == null ||
                      lastTime.year != game.sharedData.tzTime.year ||
                      lastTime.month != game.sharedData.tzTime.month ||
                      lastTime.day != game.sharedData.tzTime.day) {
                    bool showYear = false;
                    if (lastTime == null ||
                        lastTime.year != game.sharedData.tzTime.year) {
                      showYear = true;
                    }

                    String textToShow;
                    if (showYear) {
                      textToShow = MaterialLocalizations.of(context)
                              .formatMediumDate(game.sharedData.tzTime) +
                          " " +
                          MaterialLocalizations.of(context)
                              .formatYear(game.sharedData.tzTime);
                    } else {
                      textToShow = MaterialLocalizations.of(context)
                          .formatMediumDate(game.sharedData.tzTime);
                    }
                    newData.add(
                      new Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: new Text(
                          textToShow,
                          style: Theme.of(context).textTheme.subhead.copyWith(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    );
                  }
                  newData.add(
                    SingleGameProvider(
                      gameUid: game.uid,
                      builder:
                          (BuildContext context, SingleGameBloc gameBloc) =>
                              BlocBuilder(
                        bloc: gameBloc,
                        builder: (BuildContext context, SingleGameState state) {
                          return GameCard(gameUid: state.game.uid);
                        },
                      ),
                    ),
                  );
                }
              }

              if (newData.length == 0) {
                newData.add(new Text(Messages.of(context).nogames));
              }
              return new Column(
                children: newData,
              );
            }
          },
        ),
      ),
    );
  }
}
