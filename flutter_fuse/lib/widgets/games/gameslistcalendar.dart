import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/games/gamecard.dart';
import 'package:sliver_calendar/sliver_calendar.dart';
import 'dart:async';

class GameListCalendarState extends CalendarSource {
  GameSubscription _subscription;
  StreamSubscription<Iterable<Game>> _listening;
  StreamSubscription<UpdateReason> _teamListen;
  List<Game> _listToShow;
  DateTime startPoint;
  DateTime endPoint;
  FilterDetails details;
  StreamController<UpdateReason> _controller =
      new StreamController<UpdateReason>();
  Stream<UpdateReason> _myStream;

  GameListCalendarState(this.details);

  @override
  Widget buildWidget(BuildContext context, CalendarEvent event) {
    return new GameCard(_listToShow[event.index]);
  }

  @override
  List<CalendarEvent> getEvents(DateTime start, DateTime end) {
    print('Get events');
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
      events.add(new CalendarEvent(
          instant: g.sharedData.tzTime, instantEnd: g.sharedData.tzEndTime, index: pos++));
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

  void _resubscribe() {
    _subscription?.dispose();
    _subscription =
        UserDatabaseData.instance.getGames(details, startPoint, endPoint);
    _setGames(_subscription.games);
    _listening?.cancel();
    _listening = _subscription.stream.listen((Iterable<Game> games) {
      print("Getting games $startPoint $endPoint");
      _setGames(games);
    });
  }

  @override
  void initState() {
    _teamListen =
        UserDatabaseData.instance.teamStream.listen((UpdateReason reason) {
      _resubscribe();
    });
  }

  @override
  void dispose() {
    _listening?.cancel();
    _listening = null;
    _teamListen?.cancel();
    _teamListen = null;
    _controller?.close();
    _controller = null;
  }

  Future<void> loadGames(FilterDetails details) async {
    this.details = details;
  }

  void _setGames(Iterable<Game> res) {
    List<Game> games = res.toList();
    games.sort((Game a, Game b) => a.sharedData.time.compareTo(b.sharedData.time));

    _listToShow = games;
    _controller?.add(UpdateReason.Update);
    updateEvents();
  }
}
