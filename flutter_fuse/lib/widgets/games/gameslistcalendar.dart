import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:sliver_calendar/sliver_calendar.dart';

import '../games/gamecard.dart';

typedef UpdateEvents = void Function();

///
/// The state to handle displaying the game list in the calendar.
///
class GameListCalendarState {
  /// Constructor.
  GameListCalendarState(this.details, this._gameBloc, this._updateEvents);

  StreamSubscription<GameState> _listening;
  List<Game> _listToShow = [];

  /// Start point in the calendar for displaying thing on the screen.
  DateTime startPoint;

  /// End point in the calendar for displaying thing on the screen.
  DateTime endPoint;

  /// The current filter in terms of games being displayed.
  FilterDetails details;
  StreamController<UpdateReason> _controller = StreamController<UpdateReason>();
  Stream<UpdateReason> _myStream;
  final UpdateEvents _updateEvents;
  final GameBloc _gameBloc;

  ///
  /// Buildrs the widget for the specific calendar event.
  ///
  Widget buildWidget(BuildContext context, CalendarEvent event) {
    return GameCard(gameUid: _listToShow[event.index].uid);
  }

  ///
  /// Gets the calendar events between the specified time periods.
  ///
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

    var events = <CalendarEvent>[];
    var pos = 0;
    for (var g in _listToShow) {
      events.add(CalendarEvent(
          instant: g.sharedData.tzTime,
          instantEnd: g.sharedData.tzEndTime,
          index: pos++));
    }
    print("returned ${events.length}");
    return events;
  }

  /// Gets the stream of updates for this system.
  Stream<UpdateReason> get stream {
    if (_myStream == null) {
      _myStream = _controller.stream.asBroadcastStream();
    }
    return _myStream;
  }

  /// Initializes the state and waits for game data.
  void initState() {
    _listening = _gameBloc.listen(_setGames);
  }

  /// Cleans up the instances, closing all the various open streams.
  void dispose() {
    _listening?.cancel();
    _listening = null;
    _controller?.close();
    _controller = null;
  }

  /// Loads the games.
  Future<void> loadGames(FilterDetails details) async {
    this.details = details;
    _resubscribe();
  }

  void _resubscribe() {
    _gameBloc.add(GameEventSetBoundaries(start: startPoint, end: endPoint));
  }

  void _setGames(GameState res) {
    Map<String, Game> gamesMap;
    for (var t in res.gamesByTeam.keys) {
      for (var g in res.gamesByTeam[t].values) {
        gamesMap[g.uid] = g;
      }
    }
    var games = gamesMap.values.toList();

    if (games.length > 0 || _listToShow == null) {
      games.sort((a, b) => a.sharedData.time.compareTo(b.sharedData.time));

      _listToShow = games;

      _controller?.add(UpdateReason.Update);
      _updateEvents();
    }
  }
}
