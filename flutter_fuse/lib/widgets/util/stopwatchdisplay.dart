import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

///
/// Shows a stopwatch on the screen in a nice widget that updates itself
/// every second.
///
class StopwatchDisplay extends StatefulWidget {
  final MyStopwatch stopwatch;
  final TextStyle style;

  StopwatchDisplay({@required this.stopwatch, @required this.style});

  @override
  State createState() {
    return new _StopwatchDisplayState();
  }
}

class _StopwatchDisplayState extends State<StopwatchDisplay> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = new Timer.periodic(new Duration(seconds: 1),
        (Timer t) => widget.stopwatch.isRunning ? setState(() {}) : null);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timer = null;
  }

  static String format(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    if (hours < 0) {
      hours = -hours;
    }

    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    if (hours > 0) {
      String minutesStr = (minutes % 60).toString().padLeft(2, '0');

      return "$hours:$minutesStr:$secondsStr";
    }
    String minutesStr = (minutes % 60).toString().padLeft(2);
    return "$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    return new Text(
      format(widget.stopwatch.elapsedMilliseconds),
      style: widget.style,
    );
  }
}

///
/// A simple stopwatch interface to measure elapsed time.
///
class MyStopwatch {
  Stopwatch watch = new Stopwatch();

  // The _start and _stop fields capture the time when [start] and [stop]
  // are called respectively.
  // If _stop is null, the stopwatch is running.
  int _start = 0;
  int _stop = 0;
  final int initialValue;

  ///
  ///    Creates a [Stopwatch] in stopped state with a zero elapsed count.
  ///
  ///    The following example shows how to start a [Stopwatch]
  ///    immediately after allocation.
  ///    ```
  ///    var stopwatch = new Stopwatch()..start();
  ///    ```
  MyStopwatch({this.initialValue});

  ///   Starts the [Stopwatch].
  ///
  ///    The [elapsed] count is increasing monotonically. If the [Stopwatch] has
  ///    been stopped, then calling start again restarts it without resetting the
  ///    [elapsed] count.
  ///
  ///    If the [Stopwatch] is currently running, then calling start does nothing.

  void start() {
    if (_stop != null) {
      // (Re)start this stopwatch.
      // Don't count the time while the stopwatch has been stopped.
      if (_stop == 0 && initialValue != null) {
        _stop += initialValue;
      }
      _start += _now() - _stop;
      _stop = null;
    }
  }

  ///
  /// Stops the [Stopwatch].
  ///
  /// The [elapsedTicks] count stops increasing after this call. If the
  /// [Stopwatch] is currently not running, then calling this method has no
  /// effect.
  ///
  void stop() {
    _stop ??= _now();
  }

  ///
  /// Resets the [elapsed] count to zero.
  ///
  /// This method does not stop or start the [Stopwatch].
  ///
  void reset() {
    _start = _stop ?? _now();
  }

  ///
  /// Resets the [elapsed] count to a specific time.
  ///
  /// This method does not stop or start the [Stopwatch].
  ///
  void resetTo(int elapsedMs) {
    if (elapsedMs == null) {
      reset();
    } else {
      _start = elapsedMs * 1000;
    }
  }

  ///
  /// The elapsed number of clock ticks since calling [start] while the
  /// [Stopwatch] is running.
  ///
  /// This is the elapsed number of clock ticks between calling [start] and
  /// calling [stop].
  ///
  /// Is 0 if the [Stopwatch] has never been started.
  ///
  /// The elapsed number of clock ticks increases by [frequency] every second.
  ///
  int get elapsedTicks {
    return (_stop ?? _now()) - _start;
  }

  ///
  /// The [elapsedTicks] counter converted to a [Duration].
  ///
  Duration get elapsed {
    return new Duration(microseconds: elapsedMicroseconds);
  }

  ///
  /// The [elapsedTicks] counter converted to microseconds.
  ///
  int get elapsedMicroseconds {
    return elapsedTicks;
  }

  ///
  /// The [elapsedTicks] counter converted to milliseconds.
  ///
  int get elapsedMilliseconds {
    return elapsedTicks ~/ 1000;
  }

  ///
  /// Whether the [Stopwatch] is currently running.
  ///
  bool get isRunning => _stop == null;

  int _now() {
    return new DateTime.now().microsecondsSinceEpoch;
  }
}