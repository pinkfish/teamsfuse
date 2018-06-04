import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:sliver_calendar/sliver_calendar.dart';
import 'dart:async';

class GameListCalendarState extends CalendarSource {
  List<Game> _listToShow;
  StreamSubscription<UpdateReason> _listening;

  @override
  Widget buildWidget(BuildContext context, CalendarEvent event) {
    return new GameCard(_listToShow[event.index]);
  }

  @override
  List<CalendarEvent> getEvents(DateTime start, DateTime end) {
    if (_listToShow == null) {
      _listToShow = UserDatabaseData.instance.games.values.toList();
    }
    if (_listToShow == null) {
      return [];
    }
    List<CalendarEvent> events = new List<CalendarEvent>();
    int pos = 0;
    _listToShow.forEach((Game g) => events.add(new CalendarEvent(
        instant: g.tzTime, instantEnd: g.tzEndTime, index: pos++)));
    return events;
  }

  @override
  void initState() {
    _listToShow = UserDatabaseData.instance.games.values.toList();
    _listening = UserDatabaseData.instance.gameStream.listen((UpdateReason r) {
      _listToShow = UserDatabaseData.instance.games.values.toList();
      state.updateEvents();
    });
  }

  @override
  void dispose() {
    _listening.cancel();
  }

  Future<void> loadGames(FilterDetails details) async {
    Iterable<Game> list = await UserDatabaseData.instance.getGames(details);

    _setGames(list);
  }

  void _setGames(Iterable<Game> res) {
    List<Game> games = res.toList();
    games.sort((a, b) => a.time.compareTo(b.time));

    _listToShow = games;
  }
}
