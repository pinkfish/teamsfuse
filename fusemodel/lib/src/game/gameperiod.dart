import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../common.dart';
import '../serializer.dart';

part 'gameperiod.g.dart';

///
/// The type of the game period.
///
class GamePeriodType extends EnumClass {
  static Serializer<GamePeriodType> get serializer =>
      _$gamePeriodTypeSerializer;

  static const GamePeriodType Break = _$break;
  static const GamePeriodType Overtime = _$overtime;
  static const GamePeriodType Penalty = _$penalty;
  static const GamePeriodType Regulation = _$regulation;
  static const GamePeriodType OvertimeBreak = _$overtimeBreak;
  static const GamePeriodType Final = _$final;

  const GamePeriodType._(String name) : super(name);

  static BuiltSet<GamePeriodType> get values => _$GamePeriodTypeValues;

  static GamePeriodType valueOf(String name) => _$GamePeriodTypeValueOf(name);
}

abstract class GamePeriod implements Built<GamePeriod, GamePeriodBuilder> {
  GamePeriodType get type;
  num get periodNumber;

  GamePeriod._();
  factory GamePeriod([updates(GamePeriodBuilder b)]) = _$GamePeriod;

  static const String _BREAK = "--";

  String toIndex() {
    if (periodNumber > 0) {
      return "$type--$periodNumber";
    }
    return "$type";
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
        bits[0] = "Final";
      }
      if (bits[0] == "Numbered") {
        bits[0] = "Regulation";
      }
      type = GamePeriodType.values
          .firstWhere((GamePeriodType val) => val.toString() == bits[0]);
      periodNumber = getNum(bits[1]);
      return new GamePeriod((b) => b
        ..type = type
        ..periodNumber = periodNumber);
    } else {
      // Old style.
      switch (str) {
        case "Final":
          type = GamePeriodType.Final;
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
  static GamePeriod finalPeriod = GamePeriod((b) => b
    ..type = GamePeriodType.Final
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

    return Duration(milliseconds: currentOffsetInternal);
  }

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GamePeriodTime.serializer, this);
  }

  static void _initializeBuilder(GamePeriodTimeBuilder b) =>
      b..timeCountUp = true;


  static GamePeriodTime fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GamePeriodTime.serializer, jsonData);
  }

  static Serializer<GamePeriodTime> get serializer =>
      _$gamePeriodTimeSerializer;

  Duration get currentOffset => Duration(milliseconds: currentOffsetInternal);
  Duration get defaultPeriodDuration =>
      Duration(milliseconds: currentPeriodStartInternal);

  String toString() {
    return "GamePeriodTime {start: $currentPeriodStart offset: $currentOffset  countUp: $timeCountUp defaultDuration: $defaultPeriodDuration}";
  }
}
