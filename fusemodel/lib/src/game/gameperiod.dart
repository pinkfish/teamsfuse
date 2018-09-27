import '../common.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import '../userdatabasedata.dart';

enum GamePeriodType { Break, Overtime, Penalty, Regulation, OvertimeBreak }

class GamePeriod {
  final GamePeriodType type;
  final num periodNumber;

  const GamePeriod({this.type, this.periodNumber = 0}) : assert(type != null);

  GamePeriod.copy(GamePeriod per)
      : type = per.type,
        periodNumber = per.periodNumber;

  static const String _BREAK = "--";

  bool isEqualTo(GamePeriod cmp) =>
      cmp.periodNumber == periodNumber && cmp.type == type;

  String toIndex() {
    if (periodNumber > 0) {
      return "${type.toString().substring(15)}--$periodNumber";
    }
    return "${type.toString().substring(15)}";
  }

  static GamePeriod fromIndex(String str) {
    GamePeriodType type;
    num periodNumber;
    if (str == null) {
      return null;
    }

    List<String> bits = str.split(_BREAK);
    if (bits.length == 2) {
      if (bits[0] == "FinalRegulation") {
        bits[0] = "Regulation";
      }
      if (bits[0] == "Numbered") {
        bits[0] = "Regulation";
      }
      type = GamePeriodType.values.firstWhere(
              (GamePeriodType val) => val.toString().substring(15) == bits[0]);
      periodNumber = getNum(bits[1]);
      return new GamePeriod(type: type, periodNumber: periodNumber);
    } else {
      // Old style.
      switch (str) {
        case "Final":
          type = GamePeriodType.Regulation;
          periodNumber = 0;
          break;
        case "Overtime":
          type = GamePeriodType.Overtime;
          periodNumber = 0;
          break;
        case "Penalty":
          type = GamePeriodType.Penalty;
          periodNumber = 0;
          break;
        default:
          type = GamePeriodType.Regulation;
          periodNumber = 0;
          break;
      }
      return new GamePeriod(type: type, periodNumber: periodNumber);
    }
  }

  String toString() => "GamePeriod [$type $periodNumber]";

  static const GamePeriod regulation =
  const GamePeriod(type: GamePeriodType.Regulation, periodNumber: 0);
  static const GamePeriod overtime =
  const GamePeriod(type: GamePeriodType.Overtime, periodNumber: 0);
  static const GamePeriod penalty =
  const GamePeriod(type: GamePeriodType.Penalty, periodNumber: 0);
}


class GamePeriodTime {
  num _currentPeriodStart; // Start of the current period.
  Duration currentOffset;
  Duration defaultPeriodDuration = new Duration(minutes: 15);
  // If we count up the time, or down the time.  This changes how the
  // duration works in this game.
  bool timeCountUp;

  GamePeriodTime(
      {DateTime currentPeriodStart,
        this.currentOffset,
        this.defaultPeriodDuration,
        this.timeCountUp})
      : _currentPeriodStart = currentPeriodStart?.millisecondsSinceEpoch;

  GamePeriodTime.copy(GamePeriodTime copy) {
    _currentPeriodStart = copy._currentPeriodStart;
    currentOffset = copy.currentOffset;
    timeCountUp = copy.timeCountUp;
    defaultPeriodDuration = copy.defaultPeriodDuration;
  }

  DateTime get currentPeriodStart =>
      _currentPeriodStart != null && _currentPeriodStart != 0
          ? new DateTime.fromMillisecondsSinceEpoch(_currentPeriodStart)
          : null;
  set currentPeriodStart(DateTime tim) => tim != null
      ? _currentPeriodStart = tim.millisecondsSinceEpoch
      : _currentPeriodStart = null;

  Duration currentStopwatch() {
    if (_currentPeriodStart != null) {
      if (timeCountUp) {
        return new Duration(
            milliseconds: new DateTime.now().millisecondsSinceEpoch -
                _currentPeriodStart +
                currentOffset.inMilliseconds);
      } else {
        int diff = new DateTime.now().millisecondsSinceEpoch -
            _currentPeriodStart +
            currentOffset.inMilliseconds;
        if (diff > currentOffset.inMilliseconds) {
          // Out of time, show as 0.
          return new Duration();
        }
        return new Duration(milliseconds: currentOffset.inMilliseconds - diff);
      }
    }
    if (currentOffset == null) {
      if (timeCountUp) {
        currentOffset = new Duration();
      } else {
        currentOffset = defaultPeriodDuration;
      }
    }
    return currentOffset;
  }

  static const String _START_TIME = 'start';
  static const String _OFFSET = 'offset';
  static const String _TIMECOUNTUP = 'countUp';
  static const String _DEFAULTDURATION = 'defaultDuration';

  void fromJSON(Map<dynamic, dynamic> data) {
    _currentPeriodStart = getNum(data[_START_TIME]);
    currentOffset = new Duration(milliseconds: getNum(data[_OFFSET]));
    timeCountUp = getBool(data[_TIMECOUNTUP]);
    defaultPeriodDuration =
    new Duration(milliseconds: getNum(data[_DEFAULTDURATION]));
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};

    ret[_START_TIME] = _currentPeriodStart;
    ret[_DEFAULTDURATION] = defaultPeriodDuration?.inMilliseconds;
    ret[_TIMECOUNTUP] = timeCountUp;
    ret[_OFFSET] = currentOffset?.inMilliseconds;
    return ret;
  }

  String toString() {
    return "GamePeriodTime {start: $_currentPeriodStart offset: $currentOffset  countUp: $timeCountUp defaultDuration: $defaultPeriodDuration}";
  }
}
