import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'sliverlistcalendar.dart';
import 'calendardaymarker.dart';
import 'dart:async';

abstract class CalendarSource {
  List<CalendarEvent> getEvents(DateTime start, DateTime end);

  Widget buildWidget(BuildContext context, CalendarEvent index);

  void init(SliverListCalendarElement state);

  void dispose();
}

enum CalendarViewType { Schedule, Week, Month }

class CalendarEvent {
  CalendarEvent(
      {@required this.index,
      @required TZDateTime instant,
      @required TZDateTime instantEnd})
      : _instant = instant,
        _instantEnd = instantEnd,
        _indexInCalendar = CalendarEvent.indexFromMilliseconds(instant);
  TZDateTime _instant;
  TZDateTime _instantEnd;
  int index;
  int _indexInCalendar;

  static const int _MILLISECONDS_PER_DAY = 1000 * 60 * 60 * 24;

  set instant(TZDateTime instant) {
    _instant = instant;
  }

  TZDateTime get instant => _instant;

  TZDateTime get instantEnd => _instantEnd;

  int get indexInCalendar => _indexInCalendar;

  static int indexFromMilliseconds(TZDateTime time) {
    return ((time.millisecondsSinceEpoch +
            time.location.timeZone(time.millisecondsSinceEpoch).offset) ~/
        _MILLISECONDS_PER_DAY);
  }

  @override
  String toString() {
    return 'CalendarEvent{instant: $instant, index: $index, indexInCalendar: $indexInCalendar}';
  }
}

class SliverListCalendarElement extends StatelessElement {
  TZDateTime _startWindow;
  TZDateTime _endWindow;
  TZDateTime _currentTop;
  CalendarViewType _type;
  Map<int, List<CalendarEvent>> _events = {};
  Set<int> _rangeVisible = new Set<int>();
  // View index is the number of days since the epoch.
  int _startIndex;
  Location _currentLocation;
  int _nowIndex;

  static DateFormat _MONTH_FORMAT = new DateFormat(DateFormat.ABBR_MONTH);
  static DateFormat _DAY_OF_WEEK_FORMAT = new DateFormat(DateFormat.ABBR_WEEKDAY);
  static DateFormat _DAY_MONTH_FORMAT =
      new DateFormat(DateFormat.ABBR_MONTH_DAY);

  SliverListCalendarElement(SliverListCalendar widget) : super(widget) {
    print('created element');
  }

  void initState() {
    SliverListCalendar calendarWidget = widget;
    calendarWidget.source.init(this);
    if (calendarWidget.location == null) {
      _currentLocation = local;
    } else {
      _currentLocation = calendarWidget.location;
    }
    _nowIndex = CalendarEvent
        .indexFromMilliseconds(new TZDateTime.now(_currentLocation));
    _startIndex =
        CalendarEvent.indexFromMilliseconds(calendarWidget.initialDate) * 2;
    _currentTop = calendarWidget.initialDate;
    _type = calendarWidget.view;
    // Normalize the dates.
    TZDateTime normalizedStart = new TZDateTime(
        _currentLocation,
        calendarWidget.initialDate.year,
        calendarWidget.initialDate.month,
        calendarWidget.initialDate.day);
    switch (_type) {
      case CalendarViewType.Schedule:
        // Grab 60 days ahead and 60 days behind.
        _startWindow = normalizedStart.subtract(new Duration(days: 60));
        _endWindow = normalizedStart.add(new Duration(days: 60));
        break;
      case CalendarViewType.Week:
        _startWindow = new TZDateTime(
            _currentLocation,
            calendarWidget.initialDate.year,
            calendarWidget.initialDate.month,
            calendarWidget.initialDate.day);
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
        _startWindow = new TZDateTime(_currentLocation,
            calendarWidget.initialDate.year, calendarWidget.initialDate.month);
        _endWindow = new TZDateTime(
            _currentLocation,
            calendarWidget.initialDate.year,
            calendarWidget.initialDate.month + 1);
        break;
    }
    setState(() {
      List<CalendarEvent> rawEvents =
          calendarWidget.source.getEvents(_startWindow, _endWindow);
      rawEvents.sort((CalendarEvent e, CalendarEvent e2) =>
          e.instant.compareTo(e2.instant));
      if (rawEvents.length > 0) {
        int curIndex =
            CalendarEvent.indexFromMilliseconds(rawEvents[0].instant);
        int sliceIndex = 0;
        // Get the offsets into the array.
        for (int i = 1; i < rawEvents.length; i++) {
          int index = CalendarEvent.indexFromMilliseconds(rawEvents[i].instant);
          if (index != curIndex) {
            if (sliceIndex != i) {
              _events[curIndex] = rawEvents.sublist(sliceIndex, i);
            } else {
              _events[curIndex] = [rawEvents[sliceIndex]];
            }
            curIndex = index;
            sliceIndex = i;
          }
        }
        if (sliceIndex != rawEvents.length) {
          _events[curIndex] = rawEvents.sublist(sliceIndex);
        }
      }
    });
  }

  void setState(VoidCallback fn) {
    final dynamic result = fn() as dynamic;
    assert(() {
      if (result is Future) {
        throw new FlutterError(
            'setState() callback argument returned a Future.\n'
            'The setState() method on $this was called with a closure or method that '
            'returned a Future. Maybe it is marked as "async".\n'
            'Instead of performing asynchronous work inside a call to setState(), first '
            'execute the work (without updating the widget state), and then synchronously '
            'update the state inside a call to setState().');
      }
      // We ignore other types of return values so that you can do things like:
      //   setState(() => x = 3);
      return true;
    }());
    markNeedsBuild();
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    print('mount()');
    initState();
    print('after initState()');
    super.mount(parent, newSlot);
  }

  @override
  void rebuild() {
    _rangeVisible.clear();
    super.rebuild();
  }

  Widget _buildCalendarWidget(BuildContext context, int mainIndex) {
    const double widthFirst = 40.0;
    const double inset = 5.0;
    if (mainIndex % 2 == 1) {
      int index = mainIndex ~/ 2;
      if (_events.containsKey(index)) {
        List<CalendarEvent> events = _events[index];
        DateTime day = events[0].instant;
        SliverListCalendar calendarWidget = widget;
        final Size screenSize = MediaQuery.of(context).size;
        double widthSecond = screenSize.width - widthFirst - inset;
        TextStyle style = Theme.of(context).textTheme.subhead.copyWith(
              fontWeight: FontWeight.w300,
            );
        List<Widget> displayEvents = [];
        if (index == _nowIndex) {
          TZDateTime nowTime = new TZDateTime.now(_currentLocation);
          style.copyWith(color: Theme.of(context).accentColor);
          int lastMS =
              nowTime.millisecondsSinceEpoch - Duration.millisecondsPerDay;
          bool shownDivider = false;
          for (CalendarEvent e in events) {
            if (e.instant.millisecondsSinceEpoch > lastMS &&
                nowTime.isBefore(e.instantEnd)) {
              // Stick in the 'now marker' right here.
              displayEvents.add(new CalendarDayMarker(
                color: Colors.redAccent,
              ));
              shownDivider = true;
            } else if (e.instant.isAfter(nowTime) &&
                e.instantEnd.isBefore(nowTime)) {
              // Show on top of this card.
              displayEvents.add(new Stack(
                children: <Widget>[
                  calendarWidget.source.buildWidget(context, e),
                  new CalendarDayMarker(color: Colors.redAccent),
                ],
              ));
            } else {
              displayEvents.add(calendarWidget.source.buildWidget(context, e));
            }
          }
          if (!shownDivider) {
            displayEvents.add(new CalendarDayMarker(color: Colors.redAccent));
          }
        } else {
          displayEvents = events
              .map(
                (CalendarEvent e) =>
                    calendarWidget.source.buildWidget(context, e),
              )
              .toList();
        }

        return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            new Container(
              constraints: new BoxConstraints.tightFor(width: widthFirst),
              margin: new EdgeInsets.only(top: 5.0, left: inset),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  new Text(
                    _DAY_OF_WEEK_FORMAT.format(day),
                    style: style,
                  ),
                  new Text(
                    _DAY_MONTH_FORMAT.format(day),
                    style: style.copyWith(fontSize: 10.0),
                  ),
                ],
              ),
            ),
            new Container(
              constraints: new BoxConstraints.tightFor(width: widthSecond),
              margin: new EdgeInsets.only(top: 10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: displayEvents,
              ),
            ),
          ],
        );
      } else {
        int startIndex = index;
        int ms = index * CalendarEvent._MILLISECONDS_PER_DAY;
        DateTime start = new TZDateTime.fromMillisecondsSinceEpoch(
            _currentLocation, ms + _currentLocation.timeZone(ms).offset);
        // Show day/month headers
        if (!_events.containsKey(index + 1) ||
            !_events.containsKey(index - 1)) {
          const Duration oneDay = const Duration(days: 1);
          TZDateTime hardStart =
              new TZDateTime(_currentLocation, start.year, start.month, 1);
          TZDateTime hardEnd =
              new TZDateTime(_currentLocation, start.year, start.month + 1)
                  .subtract(oneDay);
          TZDateTime cur = start;
          TZDateTime last = cur;
          bool foundEnd = false;
          if (_rangeVisible.contains(startIndex)) {
            foundEnd = true;
          }
          int lastIndex = startIndex;
          while (hardEnd.compareTo(last) > 0 &&
              !_events.containsKey(lastIndex + 1)) {
            last = last.add(oneDay);
            lastIndex++;
            if (_rangeVisible.contains(lastIndex)) {
              foundEnd = true;
            }
          }
          // Pull back to the start too.
          cur = start;
          while (hardStart.compareTo(cur) < 0 &&
              !_events.containsKey(startIndex)) {
            start = cur;
            cur = cur.subtract(oneDay);
            if (hardStart.compareTo(cur) < 0) {
              startIndex--;
              if (_rangeVisible.contains(startIndex)) {
                foundEnd = true;
              }
            }
          }
          print('loc $index $startIndex $lastIndex $foundEnd');

          if (!foundEnd &&
              !_rangeVisible.contains(startIndex) &&
              !_rangeVisible.contains(lastIndex)) {
            _rangeVisible.add(startIndex);
            _rangeVisible.add(lastIndex);
            // Range
            if (_nowIndex >= startIndex && _nowIndex <= lastIndex) {
              return new Container(
                margin: new EdgeInsets.only(top: 15.0, left: 5.0),
                child: new Stack(
                  children: <Widget>[
                    new Text(
                      _MONTH_FORMAT.format(start) +
                          " " +
                          start.day.toString() +
                          " - " +
                          last.day.toString(),
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                    new CalendarDayMarker(
                      indent: widthFirst,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              );
            } else {
              return new Container(
                margin: new EdgeInsets.only(top: 15.0, left: 5.0),
                child: new Text(
                  _MONTH_FORMAT.format(start) +
                      " " +
                      start.day.toString() +
                      " - " +
                      last.day.toString(),
                  style: Theme.of(context).textTheme.subhead.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w300,
                      ),
                ),
              );
            }
          }
        } else {
          // Single day
          if (_nowIndex == index) {
            return new Container(
              margin: new EdgeInsets.only(top: 10.0, left: 5.0),
              child: new Stack(
                children: <Widget>[
                  new Text(
                    MaterialLocalizations.of(context).formatMediumDate(start),
                    style: Theme.of(context).textTheme.subhead.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                  new CalendarDayMarker(
                    indent: widthFirst,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            );
          } else {
            return new Container(
              margin: new EdgeInsets.only(top: 10.0, left: 5.0),
              child: new Text(
                MaterialLocalizations.of(context).formatMediumDate(start),
                style: Theme.of(context).textTheme.subhead.copyWith(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                    ),
              ),
            );
          }
        }
      }
    } else {
      int index = mainIndex ~/ 2;
      // Put in the month header if we are at the start of the month.
      DateTime start = new TZDateTime.fromMillisecondsSinceEpoch(
          _currentLocation, index * CalendarEvent._MILLISECONDS_PER_DAY);
      if (start.day == 1) {
        return new Container(
          decoration: new BoxDecoration(
            color: Colors.blue,
            image: new DecorationImage(
              image: new AssetImage("assets/images/calendarbanner.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          margin: new EdgeInsets.only(top: 20.0),
          constraints: new BoxConstraints(minHeight: 75.0, maxHeight: 75.0),
          child: new Text(
            MaterialLocalizations.of(context).formatMonthYear(start),
            style: Theme.of(context).textTheme.title.copyWith(
                  color: Colors.white,
                  fontSize: 30.0,
                ),
          ),
        );
      }
    }
    return const SizedBox(height: 0.1);
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

  void didUpdateWidget(covariant SliverListCalendar oldWidget) {}

  @override
  void update(StatelessWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    // Notice that we mark ourselves as dirty before calling didUpdateWidget to
    // let authors call setState from within didUpdateWidget without triggering
    // asserts.
    markNeedsBuild();
    rebuild();
  }

  @override
  void activate() {
    super.activate();
    markNeedsBuild();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();
    SliverListCalendar calendarWidet = widget;

    calendarWidet.source.dispose();
  }

  @override
  InheritedWidget inheritFromWidgetOfExactType(Type targetType) {
    return super.inheritFromWidgetOfExactType(targetType);
  }
}

class SliverListCalendar extends ScrollView {
  final DateTime initialDate;
  final CalendarSource source;
  final CalendarViewType view;
  final Location location;

  SliverListCalendar(
      {@required this.initialDate,
      @required this.source,
      this.view = CalendarViewType.Schedule,
      this.location,
      @required double initialScrollOffset})
      : super(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            controller: new ScrollController(
                initialScrollOffset: initialScrollOffset)) {}

  SliverListCalendarElement createElement() =>
      new SliverListCalendarElement(this);

  @override
  List<Widget> buildSlivers(BuildContext context) {
    SliverListCalendarElement element = context;
    return <Widget>[
      new SliverPersistentHeader(
        delegate: HeaderCalendarDelegate(element),
        pinned: true,
      ),
      element._buildCalendarList(),
    ];
  }
}

class HeaderCalendarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  SliverListCalendarElement _calendar;

  HeaderCalendarDelegate(SliverListCalendarElement calendar) {
    _calendar = calendar;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      constraints:
          new BoxConstraints(minHeight: minExtent, maxHeight: maxExtent),
      child: new Opacity(
        opacity: 1.0,
        child: new Container(
          color: Colors.blue,
          child: new Text(
            MaterialLocalizations
                .of(context)
                .formatMonthYear(_calendar._currentTop),
            style: Theme.of(context).textTheme.title,
          ),
          //onTap: () => Navigator.pushNamed(context, "Invites"),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(HeaderCalendarDelegate oldDelegate) => false;
}
