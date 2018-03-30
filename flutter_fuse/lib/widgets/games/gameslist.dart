import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'emptygamelist.dart';
import 'dart:async';

class GameList extends StatefulWidget {
  FilterDetails details;
  DateTime nowTime = new DateTime.now();

  GameList(this.details);

  @override
  GameListState createState() {
    return new GameListState();
  }
}

class GameOrHeader {
  GameOrHeader({this.game, this.header});
  Game game;
  String header;
}

class GameListState extends State<GameList> {
  StreamSubscription<UpdateReason> _updateStream;
  Set<num> _headerIndexes = new Set<num>();
  List<Game> _listToShow;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    _updateStream =
        UserDatabaseData.instance.gameStream.listen((UpdateReason update) {
      setState(() {});
      UserDatabaseData.instance
          .getGames(widget.details)
          .then((Iterable<Game> res) {
        List<Game> games = res.toList();
        games.sort((a, b) => a.time.compareTo(b.time));
        setState(() {
          _listToShow = games;
          _headerIndexes = new Set<num>();
        });
      });
    });
    UserDatabaseData.instance
        .getGames(widget.details)
        .then((Iterable<Game> res) {
      List<Game> games = res.toList();
      games.sort((a, b) => a.time.compareTo(b.time));
      setState(() {
        _listToShow = games;
        _headerIndexes = new Set<num>();
      });
    });
    super.initState();
    _scrollController.addListener(() {
      print('scroll pos ${_scrollController.position}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _updateStream.cancel();
    _updateStream = null;
  }

  @override
  Widget build(BuildContext context) {
    if (UserDatabaseData.instance.loadedDatabase &&
        (_listToShow == null || _listToShow.length == 0)) {
      return new SliverToBoxAdapter(
        child: new EmptyGameList(),
      );
    }
    return new SliverList(
      delegate: new SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          print('Render index $index');
          if (_listToShow != null) {
            int gameIndex = (index / 2).toInt();
            if (_listToShow.length > gameIndex) {
              Game game = _listToShow[gameIndex];

              if (index % 2 == 0) {
                // Header!
                DateTime time = game.tzTime;
                bool showHeader = gameIndex == 0;
                bool showYear = false;
                if (gameIndex > 0) {
                  DateTime lastTime = _listToShow[gameIndex - 1].tzTime;
                  if (lastTime.day != time.day ||
                      lastTime.year != time.year ||
                      lastTime.month != time.month) {
                    showHeader = true;
                  }
                }
                print('$time ${widget.nowTime}');
                if (time.year != widget.nowTime.year) {
                  showYear = true;
                }

                if (showHeader) {
                  String textToShow;
                  if (showYear) {
                    textToShow = MaterialLocalizations
                            .of(context)
                            .formatMediumDate(time) +
                        " " +
                        MaterialLocalizations.of(context).formatYear(time);
                  } else {
                    textToShow = MaterialLocalizations
                        .of(context)
                        .formatMediumDate(time);
                  }
                  return new Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: new Text(
                      textToShow,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  );
                } else {
                  return const SizedBox(width: 0.0);
                }
              } else {
                if (index > 0) {
                  DateTime time = game.tzTime;

                  if (time.year != game.tzTime.year ||
                      time.month != game.tzTime.month ||
                      time.day != game.tzTime.day) {}

                  return new GameCard(game);
                }
              }
            }
          }
        },
      ),
    );
  }
}
