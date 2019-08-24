import 'package:built_value/built_value.dart';
import 'package:timezone/timezone.dart';

import '../common.dart';
import 'gameperiod.dart';
import 'gamescore.dart';

part 'gamelog.g.dart';

enum GameLogType { ScoreUpdate, Message, PeriodStart, PeriodStop, UpdateScore }

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

  static GameLogBuilder fromJson(String uid, Map<String, dynamic> data) {
    GameScoreBuilder scoreBuilder = GameScoreBuilder()
      ..ptsFor = 0
      ..ptsAgainst = 0;
    GamePeriod newPeriod = GamePeriod.fromIndex(data[_PERIOD]);
    return GameLogBuilder()
      ..type = GameLogType.values.firstWhere(
          (GameLogType ty) => ty.toString() == data[_TYPE],
          orElse: () => GameLogType.Message)
      ..message = getString(data[_MESSAGE])
      ..eventTimeInternal = getNum(data[_EVENT_TIME])
      ..displayName = getString(data[NAME])
      ..period = newPeriod.toBuilder()
      ..score = data.containsKey(GameScore.PTS_FOR)
          ? GameScore.fromJSON(data)
          : scoreBuilder;
  }

  String initials() {
    return displayName.splitMapJoin(" ",
        onNonMatch: (String str) => str.substring(0, 1));
  }

  TZDateTime get eventTime {
    return new TZDateTime.fromMillisecondsSinceEpoch(local, eventTimeInternal);
  }

  /*
  set eventTime(TZDateTime time) {
    _eventTime = time.millisecondsSinceEpoch;
  }
  */

  static const String _TYPE = 'type';
  static const String _MESSAGE = 'message';
  static const String _EVENT_TIME = 'time';
  static const String _PERIOD = 'period';

  void _fromJSON(String uid, Map<String, dynamic> data) {}

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    ret[_TYPE] = type.toString();
    ret[_MESSAGE] = message;
    ret[_EVENT_TIME] = eventTimeInternal;
    ret[NAME] = displayName;
    if (period != null) {
      ret[_PERIOD] = period.toIndex();
    }
    if (score != null) {
      score.toJSON(ret);
    }
    return ret;
  }

  String toString() {
    return "GameLog($uid)[ $type ($eventTime): $message $period $score]";
  }
}
