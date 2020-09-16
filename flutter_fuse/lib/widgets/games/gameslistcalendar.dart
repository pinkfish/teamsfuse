import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:sliver_calendar/sliver_calendar.dart';

class GameListCalendarState {
  GameListCalendarState(this.details, this.state, this.gameBloc);

  StreamSubscription<GameState> _listening;
  List<Game> _listToShow = [];
  DateTime startPoint;
  DateTime endPoint;
  FilterDetails details;
  StreamController<UpdateReason> _controller = StreamController<UpdateReason>();
  Stream<UpdateReason> _myStream;
  GlobalKey<CalendarWidgetState> state;
  GameBloc gameBloc;

  Widget buildWidget(BuildContext context, CalendarEvent event) {
    return GameCard(gameUid: _listToShow[event.index].uid);
  }

  List<CalendarEvent> getEvents(DateTime start, DateTime end) {
    print('Get events $start $end');
    if (startPoint == null ||
        endPoint == null ||
        start.isBefore(startPoint) ||
        end.isAfter(endPoint)) {
      startPoint = start;
      endPoint = end;
      _resubscribe();
    }

    List<CalendarEvent> events = <CalendarEvent>[];
    int pos = 0;
    for (Game g in _listToShow) {
      events.add(CalendarEvent(
          instant: g.sharedData.tzTime,
          instantEnd: g.sharedData.tzEndTime,
          index: pos++));
    }
    print("returned ${events.length}");
    return events;
  }

  Stream<UpdateReason> get stream {
    if (_myStream == null) {
      _myStream = _controller.stream.asBroadcastStream();
    }
    return _myStream;
  }

  void initState() {
    _listening = gameBloc.listen((GameState newState) => _setGames(newState));
  }

  void dispose() {
    _listening?.cancel();
    _listening = null;
    _controller?.close();
    _controller = null;
  }

  Future<void> loadGames(FilterDetails details) async {
    this.details = details;
    _resubscribe();
  }

  void _resubscribe() {
    gameBloc.add(GameEventSetBoundaries(start: startPoint, end: endPoint));
  }

  void _setGames(GameState res) {
    Map<String, Game> gamesMap;
    for (String t in res.gamesByTeam.keys) {
      for (Game g in res.gamesByTeam[t].values) {
        gamesMap[g.uid] = g;
      }
    }
    print('_setGames');
    List<Game> games = gamesMap.values.toList();

    if (games.length > 0 || _listToShow == null) {
      games.sort(
          (Game a, Game b) => a.sharedData.time.compareTo(b.sharedData.time));

      _listToShow = games;

      _controller?.add(UpdateReason.Update);
      state.currentState?.updateEvents();
    }
  }
}
