import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Shows a stopwatch on the screen in a nice widget that updates itself
/// every second.
///
class StopwatchDisplay extends StatefulWidget {
  /// Constrctor to display the stopwatch
  StopwatchDisplay({@required this.stopwatch, @required this.style});

  /// The stopwatch to display
  final MyStopwatch stopwatch;

  /// The text tyle to use for the text
  final TextStyle style;

  @override
  State createState() {
    return _StopwatchDisplayState();
  }
}

class _StopwatchDisplayState extends State<StopwatchDisplay> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1),
        (t) => widget.stopwatch.isRunning ? setState(() {}) : null);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timer = null;
  }

  static String format(int milliseconds) {
    var hundreds = (milliseconds / 10).truncate();
    var seconds = (hundreds / 100).truncate();
    var minutes = (seconds / 60).truncate();
    var hours = (minutes / 60).truncate();
    if (hours < 0) {
      hours = -hours;
    }

    var secondsStr = (seconds % 60).toString().padLeft(2, '0');
    if (hours > 0) {
      var minutesStr = (minutes % 60).toString().padLeft(2, '0');

      return "$hours:$minutesStr:$secondsStr";
    }
    var minutesStr = (minutes % 60).toString().padLeft(2);
    return "$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: Text(format(widget.stopwatch.elapsedMilliseconds),
          style: widget.style),
    );
  }
}

///
/// A simple stopwatch interface to measure elapsed time.
///
class MyStopwatch {
  ///
  ///    Creates a [Stopwatch] in stopped state with a zero elapsed count.
  ///
  ///    The following example shows how to start a [Stopwatch]
  ///    immediately after allocation.
  ///    ```
  ///    var stopwatch = Stopwatch()..start();
  ///    ```
  MyStopwatch({this.initialValue});

  /// The underlying stopwatch to use
  Stopwatch watch = Stopwatch();

  // The _start and _stop fields capture the time when [start] and [stop]
  // are called respectively.
  // If _stop is null, the stopwatch is running.
  int _start = 0;
  int _stop = 0;

  /// The value to start the stopwatch at.
  final int initialValue;

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
    return Duration(microseconds: elapsedMicroseconds);
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
    return DateTime.now().microsecondsSinceEpoch;
  }
}
