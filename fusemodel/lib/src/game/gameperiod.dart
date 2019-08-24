import 'package:built_value/built_value.dart';

import '../common.dart';

part 'gameperiod.g.dart';

enum GamePeriodType { Break, Overtime, Penalty, Regulation, OvertimeBreak }

abstract class GamePeriod implements Built<GamePeriod, GamePeriodBuilder> {
  GamePeriodType get type;
  num get periodNumber;

  GamePeriod._();
  factory GamePeriod([updates(GamePeriodBuilder b)]) = _$GamePeriod;

  static const String _BREAK = "--";

  //bool isEqualTo(GamePeriod cmp) =>
  //    cmp.periodNumber == periodNumber && cmp.type == type;

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
      return new GamePeriod((b) => b
        ..type = type
        ..periodNumber = periodNumber);
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
      return new GamePeriod((b) => b
        ..type = type
        ..periodNumber = periodNumber);
    }
  }

  String toString() => "GamePeriod [$type $periodNumber]";

  static GamePeriod regulation = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 0);
  static GamePeriod overtime = GamePeriod((b) => b
    ..type = GamePeriodType.Overtime
    ..periodNumber = 0);
  static GamePeriod penalty = GamePeriod((b) => b
    ..type = GamePeriodType.Penalty
    ..periodNumber = 0);
}

abstract class GamePeriodTime
    implements Built<GamePeriodTime, GamePeriodTimeBuilder> {
  @nullable
  num get currentPeriodStartInternal; // Start of the current period.
  @nullable
  num get currentOffsetInternal;
  @nullable
  num get defaultPeriodDurationInternal;
  // If we count up the time, or down the time.  This changes how the
  // duration works in this game.
  bool get timeCountUp;

  GamePeriodTime._();
  factory GamePeriodTime([updates(GamePeriodTimeBuilder b)]) = _$GamePeriodTime;

  DateTime get currentPeriodStart =>
      currentPeriodStartInternal != null && currentPeriodStartInternal != 0
          ? new DateTime.fromMillisecondsSinceEpoch(
              currentPeriodStartInternal.toInt())
          : null;

  Duration currentStopwatch() {
    if (currentPeriodStartInternal != null) {
      if (timeCountUp) {
        return new Duration(
            milliseconds: new DateTime.now().millisecondsSinceEpoch -
                currentPeriodStartInternal +
                currentOffsetInternal);
      } else {
        int diff = new DateTime.now().millisecondsSinceEpoch -
            currentPeriodStartInternal +
            currentOffsetInternal;
        if (diff > currentOffsetInternal) {
          // Out of time, show as 0.
          return new Duration();
        }
        return new Duration(milliseconds: currentOffsetInternal - diff);
      }
    }
    /*
    if (currentOffsetInternal == null) {
      if (timeCountUp) {
        currentOffsetInternal = 0;
      } else {
        currentOffsetInternal = defaultPeriodDuration;
      }
    }
    */
    return Duration(milliseconds: currentOffsetInternal);
  }

  static const String _START_TIME = 'start';
  static const String _OFFSET = 'offset';
  static const String _TIMECOUNTUP = 'countUp';
  static const String _DEFAULTDURATION = 'defaultDuration';

  static GamePeriodTimeBuilder fromJSON(Map<dynamic, dynamic> data) {
    GamePeriodTimeBuilder builder = GamePeriodTimeBuilder();
    builder.currentPeriodStartInternal = getNum(data[_START_TIME]);
    builder.currentOffsetInternal = getNum(data[_OFFSET]);
    builder.timeCountUp = getBool(data[_TIMECOUNTUP]);
    builder.defaultPeriodDurationInternal = getNum(data[_DEFAULTDURATION]);
    return builder;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};

    ret[_START_TIME] = currentPeriodStartInternal;
    ret[_DEFAULTDURATION] = defaultPeriodDurationInternal;
    ret[_TIMECOUNTUP] = timeCountUp;
    ret[_OFFSET] = currentOffsetInternal;
    return ret;
  }

  Duration get currentOffset => Duration(milliseconds: currentOffsetInternal);
  Duration get defaultPeriodDuration =>
      Duration(milliseconds: currentPeriodStartInternal);

  String toString() {
    return "GamePeriodTime {start: $currentPeriodStart offset: $currentOffset  countUp: $timeCountUp defaultDuration: $defaultPeriodDuration}";
  }
}
