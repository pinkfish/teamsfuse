import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:flutter_fuse/widgets/calendar/calendar.dart';
import 'dart:async';

class GameListCalendarState implements CalendarSource {
  List<Game> _listToShow;
  ScrollController _scrollController = new ScrollController(
      initialScrollOffset:
          new DateTime.now().millisecondsSinceEpoch / (1000 * 60 * 60 * 24));

  @override
  Widget buildWidget(BuildContext context, int index) {
    return new GameCard(_listToShow[index]);
  }

  @override
  List<CalendarEvent> getEvents(DateTime start, DateTime end) {
    if (_listToShow == null) {
      return [];
    }
    List<CalendarEvent> events = new List<CalendarEvent>(_listToShow.length);
    int pos = 0;
    _listToShow.forEach((Game g) =>
        events.add(new CalendarEvent(instant: g.tzTime, index: pos++)));
    return events;
  }

  Future<void> loadGames(FilterDetails details) async {
    Iterable<Game> list = await UserDatabaseData.instance.getGames(details);

    _setGames(list);
  }

  void _setGames(Iterable<Game> res) {
    List<Game> games = res.toList();
    games.sort((a, b) => a.time.compareTo(b.time));
    int nowMs = new DateTime.now()
        .subtract(new Duration(days: 7))
        .millisecondsSinceEpoch;

    _listToShow = games;
  }
}
