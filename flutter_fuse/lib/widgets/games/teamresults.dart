import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../../services/messages.dart';
import '../blocs/singlegameprovider.dart';
import '../blocs/singleopponentprovider.dart';
import '../blocs/singleseasonprovider.dart';
import '../games/gamecard.dart';

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
    return SingleOpponentProvider(
      opponentUid: opponentUid,
      builder: (BuildContext context, SingleOpponentBloc teamBloc) =>
          BlocListener(
        cubit: teamBloc,
        listener: (BuildContext context, SingleOpponentState state) {
          teamBloc.add(SingleOpponentLoadGames());
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: teamBloc,
          builder: (BuildContext context, SingleOpponentState state) {
            if (state is SingleOpponentDeleted) {
              return Center(
                child: Text(Messages.of(context).loading),
              );
            }
            if (!state.gamesLoaded) {
              return Center(
                child: Text(Messages.of(context).nogames),
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
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Text(
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
                        cubit: gameBloc,
                        builder: (BuildContext context, SingleGameState state) {
                          return GameCard(gameUid: state.game.uid);
                        },
                      ),
                    ),
                  );
                }
              }

              if (newData.length == 0) {
                newData.add(Text(Messages.of(context).nogames));
              }
              return Column(
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
    return SingleSeasonProvider(
      seasonUid: seasonUid,
      builder: (BuildContext context, SingleSeasonBloc seasonBloc) =>
          BlocListener(
        cubit: seasonBloc,
        listener: (BuildContext context, SingleSeasonState state) {
          seasonBloc.add(SingleSeasonLoadGames());
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          cubit: seasonBloc,
          builder: (BuildContext context, SingleSeasonState state) {
            seasonBloc.add(SingleSeasonLoadGames());
            if (state is SingleOpponentDeleted) {
              return Center(
                child: Text(Messages.of(context).teamdeleted),
              );
            }
            if (!state.loadedGames) {
              return Center(
                child: Text(Messages.of(context).loading),
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
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Text(
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
                        cubit: gameBloc,
                        builder: (BuildContext context, SingleGameState state) {
                          if (state is SingleGameLoaded) {
                            print("Display ${state.game.uid}");
                            return GameCard(gameUid: state.game.uid);
                          }
                          return Center(
                            child: Text(Messages.of(context).loading),
                          );
                        },
                      ),
                    ),
                  );
                }
              }

              if (newData.length == 0) {
                newData.add(Text(Messages.of(context).nogames));
              }
              return Column(
                children: newData,
              );
            }
          },
        ),
      ),
    );
  }
}
