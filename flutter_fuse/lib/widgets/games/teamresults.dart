import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../../services/blocs.dart';
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
  /// Constructor.
  TeamResultsByOpponent({@required this.teamUid, this.opponentUid});

  /// The teamUid to find the results for.
  final String teamUid;

  /// The opponent uid to see results for (null means all opponents).
  final String opponentUid;

  @override
  Widget build(BuildContext context) {
    return SingleOpponentProvider(
      opponentUid: opponentUid,
      builder: (context, teamBloc) => BlocListener(
        bloc: teamBloc,
        listener: (context, state) {
          teamBloc.add(SingleOpponentLoadGames());
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          bloc: teamBloc,
          builder: (context, state) {
            if (state is SingleOpponentDeleted) {
              return Center(
                child: Text(Messages.of(context).loading),
              );
            }
            if (!state.gamesLoaded) {
              return Center(
                child: Text(Messages.of(context).noGames),
              );
            } else {
              var newData = <Widget>[];
              var gameSort = state.games.toList();
              gameSort.sort((g1, g2) =>
                  g1.sharedData.time.toInt() - g2.sharedData.time.toInt());
              TZDateTime lastTime;
              for (Game game in gameSort) {
                if (game.sharedData.type == EventType.Game &&
                    (opponentUid == null || game.opponentUid == opponentUid)) {
                  if (lastTime == null ||
                      lastTime.year != game.sharedData.tzTime.year ||
                      lastTime.month != game.sharedData.tzTime.month ||
                      lastTime.day != game.sharedData.tzTime.day) {
                    var showYear = false;
                    if (lastTime == null ||
                        lastTime.year != game.sharedData.tzTime.year) {
                      showYear = true;
                    }

                    String textToShow;
                    var monthDay = MaterialLocalizations.of(context)
                        .formatMediumDate(game.sharedData.tzTime);
                    if (showYear) {
                      var year = MaterialLocalizations.of(context)
                          .formatYear(game.sharedData.tzTime);
                      textToShow = '$monthDay $year ';
                    } else {
                      textToShow = monthDay;
                    }
                    newData.add(
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Text(
                          textToShow,
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
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
                      builder: (context, gameBloc) => BlocBuilder(
                        bloc: gameBloc,
                        builder: (context, state) {
                          return GameCard(gameUid: state.game.uid);
                        },
                      ),
                    ),
                  );
                }
              }

              if (newData.isEmpty) {
                newData.add(Text(Messages.of(context).noGames));
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

///
/// Show the team results by season.
///
class TeamResultsBySeason extends StatelessWidget {
  /// Constrcutor.
  TeamResultsBySeason(
      {@required this.seasonUid, @required this.teamUid, this.opponentUid});

  /// Season to show the results for.
  final String seasonUid;

  /// Team to show the results for.
  final String teamUid;

  /// Opponent to show the results for (null for all).
  final String opponentUid;

  @override
  Widget build(BuildContext context) {
    return SingleSeasonProvider(
      seasonUid: seasonUid,
      builder: (context, seasonBloc) => BlocListener(
        bloc: seasonBloc,
        listener: (context, state) {
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder(
          bloc: seasonBloc,
          builder: (context, state) {
            if (state is SingleOpponentDeleted) {
              return Center(
                child: Text(Messages.of(context).teamDeleted),
              );
            }
            if (!state.loadedGames) {
              seasonBloc.add(SingleSeasonLoadGames());
              return Center(
                child: Text(Messages.of(context).loading),
              );
            } else {
              var newData = <Widget>[];
              var gameSort = state.games.toList();
              gameSort.sort((Game g1, Game g2) => g1.sharedData.time
                  .difference(g2.sharedData.time)
                  .inMilliseconds);
              TZDateTime lastTime;
              for (var game in gameSort) {
                if (game.sharedData.type == EventType.Game &&
                    (opponentUid == null || game.opponentUid == opponentUid)) {
                  if (lastTime == null ||
                      lastTime.year != game.sharedData.tzTime.year ||
                      lastTime.month != game.sharedData.tzTime.month ||
                      lastTime.day != game.sharedData.tzTime.day) {
                    var showYear = false;
                    if (lastTime == null ||
                        lastTime.year != game.sharedData.tzTime.year) {
                      showYear = true;
                    }

                    String textToShow;
                    var monthDay = MaterialLocalizations.of(context)
                        .formatMediumDate(game.sharedData.tzTime);
                    if (showYear) {
                      var year = MaterialLocalizations.of(context)
                          .formatYear(game.sharedData.tzTime);
                      textToShow = '$monthDay $year';
                    } else {
                      textToShow = monthDay;
                    }
                    newData.add(
                      Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Text(
                          textToShow,
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
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
                      builder: (context, gameBloc) => BlocBuilder(
                        bloc: gameBloc,
                        builder: (context, state) {
                          if (state is SingleGameLoaded) {
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

              if (newData.isEmpty) {
                newData.add(Text(Messages.of(context).noGames));
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
