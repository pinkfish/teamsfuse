import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:clock/clock.dart';

import '../common.dart';
import '../serializer.dart';

part 'gameperiod.g.dart';

///
/// The type of the game period.
///
class GamePeriodType extends EnumClass {
  static Serializer<GamePeriodType> get serializer =>
      _$gamePeriodTypeSerializer;

  static const GamePeriodType NotStarted = _$notStarted;
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
  factory GamePeriod([Function(GamePeriodBuilder b) updates]) = _$GamePeriod;

  static const String _BREAK = '--';

  String toIndex() {
    if (periodNumber > 0) {
      return '$type--$periodNumber';
    }
    return '$type';
  }

  static GamePeriod fromIndex(String str) {
    GamePeriodType type;
    num periodNumber;
    if (str == null) {
      return null;
    }

    var bits = str.split(_BREAK);
    if (bits.length == 2) {
      if (bits[0] == 'FinalRegulation') {
        bits[0] = 'Final';
      }
      if (bits[0] == 'Numbered') {
        bits[0] = 'Regulation';
      }
      type = GamePeriodType.values
          .firstWhere((GamePeriodType val) => val.toString() == bits[0]);
      periodNumber = getNum(bits[1]);
      return GamePeriod((b) => b
        ..type = type
        ..periodNumber = periodNumber);
    } else {
      // Old style.
      switch (str) {
        case 'Final':
          type = GamePeriodType.Final;
          periodNumber = 0;
          break;
        case 'Overtime':
          type = GamePeriodType.Overtime;
          periodNumber = 0;
          break;
        case 'Penalty':
          type = GamePeriodType.Penalty;
          periodNumber = 0;
          break;
        default:
          type = GamePeriodType.Regulation;
          periodNumber = 0;
          break;
      }
      return GamePeriod((b) => b
        ..type = type
        ..periodNumber = periodNumber);
    }
  }

  @override
  String toString() => 'GamePeriod [$type $periodNumber]';

  static GamePeriod notStarted = GamePeriod((b) => b
    ..type = GamePeriodType.NotStarted
    ..periodNumber = 0);
  static GamePeriod regulation1 = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 1);
  static GamePeriod regulation2 = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 2);
  static GamePeriod regulation3 = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 3);
  static GamePeriod regulation4 = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 4);
  static GamePeriod regulation5 = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 5);
  static GamePeriod regulation6 = GamePeriod((b) => b
    ..type = GamePeriodType.Regulation
    ..periodNumber = 6);
  static GamePeriod overtime1 = GamePeriod((b) => b
    ..type = GamePeriodType.Overtime
    ..periodNumber = 1);
  static GamePeriod overtime2 = GamePeriod((b) => b
    ..type = GamePeriodType.Overtime
    ..periodNumber = 2);
  static GamePeriod overtime3 = GamePeriod((b) => b
    ..type = GamePeriodType.Overtime
    ..periodNumber = 3);
  static GamePeriod overtime4 = GamePeriod((b) => b
    ..type = GamePeriodType.Overtime
    ..periodNumber = 4);
  static GamePeriod overtime5 = GamePeriod((b) => b
    ..type = GamePeriodType.Overtime
    ..periodNumber = 5);
  static GamePeriod penalty = GamePeriod((b) => b
    ..type = GamePeriodType.Penalty
    ..periodNumber = 0);
  static GamePeriod finalPeriod = GamePeriod((b) => b
    ..type = GamePeriodType.Final
    ..periodNumber = 0);

  static List<GamePeriod> values = [
    notStarted,
    regulation1,
    regulation2,
    regulation3,
    regulation4,
    regulation5,
    regulation6,
    overtime1,
    overtime2,
    overtime3,
    overtime4,
    overtime5,
    penalty,
    finalPeriod
  ];
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
  factory GamePeriodTime([Function(GamePeriodTimeBuilder b) updates]) =
      _$GamePeriodTime;

  DateTime get currentPeriodStart => currentPeriodStartInternal != null &&
          currentPeriodStartInternal != 0
      ? DateTime.fromMillisecondsSinceEpoch(currentPeriodStartInternal.toInt())
      : null;

  Duration currentStopwatch() {
    if (currentPeriodStartInternal != null) {
      if (timeCountUp) {
        return Duration(
            milliseconds: clock.now().millisecondsSinceEpoch -
                currentPeriodStartInternal +
                currentOffsetInternal);
      } else {
        int diff = clock.now().millisecondsSinceEpoch -
            currentPeriodStartInternal +
            currentOffsetInternal;
        if (diff > currentOffsetInternal) {
          // Out of time, show as 0.
          return Duration();
        }
        return Duration(milliseconds: currentOffsetInternal - diff);
      }
    }

    return Duration(milliseconds: currentOffsetInternal);
  }

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GamePeriodTime.serializer, this);
  }

  static void _initializeBuilder(GamePeriodTimeBuilder b) => b
    ..timeCountUp = true
    .._currentOffsetInternal = 0
    .._currentPeriodStartInternal = 0;

  static GamePeriodTime fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(GamePeriodTime.serializer, jsonData);
  }

  static Serializer<GamePeriodTime> get serializer =>
      _$gamePeriodTimeSerializer;

  Duration get currentOffset =>
      Duration(milliseconds: currentOffsetInternal ?? 0);
  Duration get defaultPeriodDuration =>
      Duration(milliseconds: currentPeriodStartInternal ?? 0);

  @override
  String toString() {
    return 'GamePeriodTime {start: $currentPeriodStart offset: $currentOffset  countUp: $timeCountUp defaultDuration: $defaultPeriodDuration}';
  }
}
