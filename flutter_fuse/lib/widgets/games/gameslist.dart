import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'emptygamelist.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/sliverlistcenter.dart';

class GameList extends StatefulWidget {
  final FilterDetails details;
  final DateTime nowTime = new DateTime.now();

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
  List<Game> _listToShow;
  ScrollController _scrollController = new ScrollController();
  int _startIndex;

  @override
  void initState() {
    _updateStream =
        UserDatabaseData.instance.gameStream.listen((UpdateReason update) {
      setState(() {});
      UserDatabaseData.instance
          .getGames(widget.details)
          .then((Iterable<Game> res) {
        _setGames(res);
      });
    });
    UserDatabaseData.instance
        .getGames(widget.details)
        .then((Iterable<Game> res) {
      _setGames(res);
    });
    super.initState();
    _scrollController.addListener(() {
      print('scroll pos ${_scrollController.position}');
    });
  }

  void _setGames(Iterable<Game> res) {
    List<Game> games = res.toList();
    games.sort((a, b) => a.time.compareTo(b.time));
    int nowMs = new DateTime.now()
        .subtract(new Duration(days: 7))
        .millisecondsSinceEpoch;
    setState(() {
      _listToShow = games;
      _startIndex = games.indexWhere((Game g) => g.time > nowMs);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _updateStream.cancel();
    _updateStream = null;
  }

  Widget _renderSliverIndex(BuildContext context, int index) {
    if (_listToShow != null) {
      int gameIndex = index ~/ 2;
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
              textToShow =
                  MaterialLocalizations.of(context).formatMediumDate(time) +
                      " " +
                      MaterialLocalizations.of(context).formatYear(time);
            } else {
              textToShow =
                  MaterialLocalizations.of(context).formatMediumDate(time);
            }
            return new Container(
              margin: const EdgeInsets.only(top: 30.0, left: 10.0),
              child: new Text(
                textToShow,
                style: Theme.of(context).textTheme.subhead.copyWith(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          } else {
            return new SizedBox(
              width: 0.0,
              height: 10.0,
              key: new ValueKey(index),
            );
          }
        } else {
          if (game != null) {
            DateTime time = game.tzTime;

            if (time.year != game.tzTime.year ||
                time.month != game.tzTime.month ||
                time.day != game.tzTime.day) {}

            return new GameCard(game);
          }
        }
      } else if (index == 2) {
        Size screenSize = MediaQuery.of(context).size;
        return new SizedBox(
          height: screenSize.height,
        );
      }
    } else {
      if (index == 2) {
        Size screenSize = MediaQuery.of(context).size;
        return new SizedBox(
          height: screenSize.height,
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print("Loaded for gamelist ${UserDatabaseData.instance.loadedDatabase}");
    if (!UserDatabaseData.instance.loadedFromSQL) {
      return new SliverToBoxAdapter(
        child: new Container(
            color: Colors.white,
            child: new Column(
              children: <Widget>[
                new Text(Messages.of(context).loading),
                new CircularProgressIndicator(),
              ],
            ),

      ),
      );
    }
    if (UserDatabaseData.instance.loadedDatabase &&
        (_listToShow == null || _listToShow.length == 0)) {
      return new SliverToBoxAdapter(
        child: new EmptyGameList(),
      );
    }
    return new SliverListCenter(
      startIndex: _startIndex,
      delegate: new SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _renderSliverIndex(context, index);
        },
        addAutomaticKeepAlives: false,
      ),
    );
  }
}
