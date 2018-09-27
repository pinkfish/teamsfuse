import '../common.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import 'gameperiod.dart';
import 'gamescore.dart';

enum GameLogType { ScoreUpdate, Message, PeriodStart, PeriodStop, UpdateScore }

class GameLogReturnData {
  StreamSubscription<dynamic> myLogStream;
  Future<List<GameLog>> logs;
}

class GameLog {
  GameLogType type;
  String message;
  GameScore score;
  num _eventTime;
  GamePeriod period;
  String uid;
  String displayName;

  GameLog(
      {this.type,
        this.message,
        this.score,
        this.uid,
        this.period,
        this.displayName,
        num eventTime})
      : _eventTime = eventTime ?? new DateTime.now().millisecondsSinceEpoch,
        assert(displayName != null),
        assert(uid != null);

  GameLog.fromJson(String uid, Map<String, dynamic> data) {
    _fromJSON(uid, data);
  }

  String initials() {
    return displayName.splitMapJoin(" ",
        onNonMatch: (String str) => str.substring(0, 1));
  }

  TZDateTime get eventTime {
    return new TZDateTime.fromMillisecondsSinceEpoch(local, _eventTime);
  }

  set eventTime(TZDateTime time) {
    _eventTime = time.millisecondsSinceEpoch;
  }

  static const String _TYPE = 'type';
  static const String _MESSAGE = 'message';
  static const String _EVENT_TIME = 'time';
  static const String _PERIOD = 'period';

  void _fromJSON(String uid, Map<String, dynamic> data) {
    type = GameLogType.values
        .firstWhere((GameLogType ty) => ty.toString() == data[_TYPE]);
    message = getString(data[_MESSAGE]);
    if (data.containsKey(GameScore.PTS_FOR)) {
      score = new GameScore.fromJSON(data);
    }
    _eventTime = getNum(data[_EVENT_TIME]);
    displayName = getString(data[NAME]);
    GamePeriod newPeriod = GamePeriod.fromIndex(data[_PERIOD]);
    period = newPeriod;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    ret[_TYPE] = type.toString();
    ret[_MESSAGE] = message;
    ret[_EVENT_TIME] = _eventTime;
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
