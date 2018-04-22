import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'sliverlistcalendar.dart';

abstract class CalendarSource {
  List<CalendarEvent> getEvents(DateTime start, DateTime end);

  Widget buildWidget(BuildContext context, int index);
}

enum CalendarViewType { Schedule, Week, Month }

class CalendarEvent {
  CalendarEvent({@required this.index, @required this.instant});
  DateTime instant;
  int index;
}

class SliverListCalendar extends StatefulWidget {
  final DateTime initialDate;
  final CalendarSource source;
  final CalendarViewType view;

  SliverListCalendar(
      {@required this.initialDate,
      @required this.source,
      this.view = CalendarViewType.Schedule});

  @override
  SliverCalendarViewState createState() {
    return new SliverCalendarViewState();
  }
}

class SliverCalendarViewState extends State<SliverListCalendar> {
  DateTime _startWindow;
  DateTime _endWindow;
  CalendarViewType _type;
  Map<int, List<CalendarEvent>> _events;
  // View index is the number of days since the epoch.
  int _startIndex;
  ScrollController _controller = new ScrollController(
      initialScrollOffset:
          new DateTime.now().millisecondsSinceEpoch.toDouble());

  static const int _MILLISECONDS_PER_DAY = 1000 * 60 * 60 * 24;
  static DateFormat _MONTH_FORMAT = new DateFormat(DateFormat.ABBR_MONTH);

  void initState() {
    super.initState();
    _startIndex =
        (widget.initialDate.millisecondsSinceEpoch / 1000 * 60 * 60 * 24)
            .toInt();
    _type = widget.view;
    // Normalize the dates.
    DateTime normalizedStart = new DateTime(widget.initialDate.year,
        widget.initialDate.month, widget.initialDate.day);
    switch (_type) {
      case CalendarViewType.Schedule:
        // Grab 60 days ahead and 60 days behind.
        _startWindow = normalizedStart.subtract(new Duration(days: 60));
        _endWindow = normalizedStart.add(new Duration(days: 60));
        break;
      case CalendarViewType.Week:
        _startWindow = new DateTime(widget.initialDate.year,
            widget.initialDate.month, widget.initialDate.day);
        if (_startWindow.weekday != 0) {
          if (_startWindow.weekday < 0) {
            _startWindow = _startWindow.subtract(new Duration(
                days: 0 - DateTime.daysPerWeek + _startWindow.weekday));
          } else {
            _startWindow = _startWindow
                .subtract(new Duration(days: 0 - _startWindow.weekday));
          }
          _endWindow =
              _startWindow.add(new Duration(days: DateTime.daysPerWeek));
        }
        break;
      case CalendarViewType.Month:
        _startWindow =
            new DateTime(widget.initialDate.year, widget.initialDate.month);
        _endWindow =
            new DateTime(widget.initialDate.year, widget.initialDate.month + 1);
        break;
    }
    setState(() {
      List<CalendarEvent> rawEvents =
          widget.source.getEvents(_startWindow, _endWindow);
      rawEvents.sort((CalendarEvent e, CalendarEvent e2) =>
          e.instant.compareTo(e2.instant));
      // Get the offsets into the array.
      int curIndex = indexFromMilliseconds(_startWindow);
      int foundIndex = 0;
      for (int i = 0; i < rawEvents.length; i++) {
        int index = indexFromMilliseconds(rawEvents[i].instant);
        if (index != curIndex) {
          if (foundIndex != i) {
            _events[curIndex] = rawEvents.sublist(foundIndex, i);
          }
          foundIndex = i;
          while (curIndex < index) {
            _events.remove(curIndex);
            curIndex++;
          }
        }
      }
      if (foundIndex != rawEvents.length) {
        _events[curIndex] = rawEvents.sublist(foundIndex);
      }
    });
  }

  int indexFromMilliseconds(DateTime time) {
    return time.millisecondsSinceEpoch ~/ _MILLISECONDS_PER_DAY;
  }

  Widget _buildCalendarWidget(BuildContext context, int index) {
    if (_events.containsKey(index)) {
      List<CalendarEvent> events = _events[index];
      DateTime day = events[0].instant;
      return new Row(
        children: <Widget>[
          new Column(
            children: <Widget>[
              new Text(_MONTH_FORMAT.format(day)),
              new Text(day.day.toString()),
            ],
          ),
          new Column(
            children: events.map((CalendarEvent e) =>
                widget.source.buildWidget(context, e.index)),
          ),
        ],
      );
    } else {
      // Show an empty range.
      if (_events.containsKey(index + 1) || _events.containsKey(index - 1)) {
        DateTime start = new DateTime.fromMillisecondsSinceEpoch(
            index * _MILLISECONDS_PER_DAY);
        DateTime hardEnd = new DateTime(start.year, start.month + 1);
        DateTime cur = start;
        while (hardEnd.compareTo(cur) < 0) {
          cur = cur.add(new Duration(days: 1));
        }
        if (cur.compareTo(start) != 0) {
          // Range
          return new Text(_MONTH_FORMAT.format(start) +
              " " +
              start.day.toString() +
              " - " +
              cur.day.toString());
        } else {
          // Single day
          return new Text(
              MaterialLocalizations.of(context).formatMediumDate(start));
        }
      }
    }
    return const SizedBox(height: 0.0);
  }

  SliverListCenter _buildCalendarList() {
    return new SliverListCenter(
      startIndex: _startIndex,
      delegate: new SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildCalendarWidget(context, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
      scrollDirection: Axis.vertical,
      //controller: _controller,
      slivers: <Widget>[
        /*
        new SliverAppBar(
          title: new Text(
              MaterialLocalizations.of(context).formatMonthYear(_startWindow)),
          primary: false,
          pinned: true,
        ),
        */
        //_buildCalendarList(),
      ],
    );
  }
}
