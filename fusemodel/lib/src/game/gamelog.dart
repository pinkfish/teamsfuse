import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import '../serializer.dart';
import 'gameperiod.dart';
import 'gamescore.dart';

part 'gamelog.g.dart';

///
/// The game log event type.
///
class GameLogType extends EnumClass {
  static Serializer<GameLogType> get serializer => _$gameLogTypeSerializer;

  static const GameLogType ScoreUpdate = _$scoreUpdate;
  static const GameLogType Message = _$message;
  static const GameLogType PeriodStart = _$periodStart;
  static const GameLogType PeriodStop = _$periodStop;
  static const GameLogType UpdateScore = _$updateScore;

  const GameLogType._(String name) : super(name);

  static BuiltSet<GameLogType> get values => _$GameLogTypeValues;

  static GameLogType valueOf(String name) => _$GameLogTypeValueOf(name);
}

///
/// The game log class that tracks log entries in the game.
///
abstract class GameLog implements Built<GameLog, GameLogBuilder> {
  GameLogType get type;
  String get message;
  GameScore get score;
  num get eventTimeInternal;
  GamePeriod get period;
  String get uid;
  String get displayName;

  GameLog._();
  factory GameLog([updates(GameLogBuilder b)]) = _$GameLog;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameLog.serializer, this);
  }

  static GameLog fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameLog.serializer, jsonData);
  }

  static Serializer<GameLog> get serializer => _$gameLogSerializer;

  String initials() {
    return displayName.splitMapJoin(" ",
        onNonMatch: (String str) => str.substring(0, 1));
  }

  TZDateTime get eventTime {
    return new TZDateTime.fromMillisecondsSinceEpoch(local, eventTimeInternal);
  }

  String toString() {
    return "GameLog($uid)[ $type ($eventTime): $message $period $score]";
  }
}
