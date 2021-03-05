import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:sliver_calendar/sliver_calendar.dart';

import '../../services/blocs.dart';
import '../games/gamecard.dart';

typedef UpdateEvents = void Function();

///
/// The state to handle displaying the game list in the calendar.
///
class GameListCalendarState {
  /// Constructor.
  GameListCalendarState(this._gameBloc, this._updateEvents) {
    _listening = _gameBloc.listen(_setGames);
  }

  /// Start point in the calendar for displaying thing on the screen.
  DateTime startPoint;

  /// End point in the calendar for displaying thing on the screen.
  DateTime endPoint;

  final UpdateEvents _updateEvents;
  final FilteredGameBloc _gameBloc;

  StreamController<UpdateReason> _controller = StreamController<UpdateReason>();
  Stream<UpdateReason> _myStream;
  StreamSubscription<FilteredGameState> _listening;
  List<Game> _listToShow = [];

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
    return events;
  }

  /// Gets the stream of updates for this system.
  Stream<UpdateReason> get stream {
    _myStream ??= _controller.stream.asBroadcastStream();
    return _myStream;
  }

  /// Cleans up the instances, closing all the various open streams.
  void dispose() {
    _listening?.cancel();
    _listening = null;
    _controller?.close();
    _controller = null;
  }

  /// Loads the games.
  void loadGames(FilterDetails details) {
    _resubscribe();
    _gameBloc.add(FilteredGameEventUpdateFilter(filter: details));
  }

  void _resubscribe() {
    _gameBloc
        .add(FilteredGameEventUpdateDates(start: startPoint, end: endPoint));
  }

  void _setGames(FilteredGameState res) {
    var games = res.games.values.toList();

    if (games.isNotEmpty || _listToShow == null) {
      games.sort((a, b) => a.sharedData.time.compareTo(b.sharedData.time));

      _listToShow = games;

      _controller?.add(UpdateReason.Update);
      _updateEvents();
    }
  }
}
