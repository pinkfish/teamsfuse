import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:collection/collection.dart';

import 'gameperiod.dart';
import 'gameresultshareddetails.dart';
import 'gamescore.dart';

part 'gameresult.g.dart';

enum GameResult { Win, Loss, Tie, Unknown }
enum GameInProgress { NotStarted, InProgress, Final }
enum GameDivisionsType { Halves, Quarters, Thirds }

abstract class GameResultPerPeriod
    implements Built<GameResultPerPeriod, GameResultPerPeriodBuilder> {
  GamePeriod get period;
  GameScore get score;

  GameResultPerPeriod._();
  factory GameResultPerPeriod([updates(GameResultPerPeriodBuilder b)]) =
      _$GameResultPerPeriod;

  static GameResultPerPeriodBuilder fromJSON(
      GamePeriod period, Map<dynamic, dynamic> data) {
    return GameResultPerPeriodBuilder()
      ..period = period.toBuilder()
      ..score = GameScore.fromJSON(data);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    score.toJSON(ret);
    return ret;
  }
}

abstract class GameResultDetails
    with GameResultSharedDetails
    implements Built<GameResultDetails, GameResultDetailsBuilder> {
  BuiltMap<GamePeriod, GameResultPerPeriod> get scores;

  //CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> get scores =
  //    new CanonicalizedMap((GamePeriod p) => p.toIndex());
  GameResult get result;
  GameInProgress get inProgress;
  GamePeriod get currentPeriod; // Null until the game started.
  GameDivisionsType get divisions; // = GameDivisionsType.Halves;
  GamePeriodTime get time;

  GameResultDetails._();
  factory GameResultDetails([updates(GameResultDetailsBuilder b)]) =
      _$GameResultDetails;

  static const String _SCORES = 'scores';
  static const String _RESULT = 'result';
  static const String _INPROGRESS = 'inProgress';
  static const String _PERIOD = 'period';
  static const String _DIVISIONS = 'divisions';
  static const String _TIME_DETAILS = 'timeDetails';

  static GameResultDetailsBuilder fromJSON(Map<dynamic, dynamic> data) {
    GameResultDetailsBuilder builder = GameResultDetailsBuilder();
    if (data.containsKey(_SCORES)) {
      Map<dynamic, dynamic> scoreData = data[_SCORES];
      CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> newResults =
          new CanonicalizedMap((GamePeriod p) => p.toIndex());
      scoreData.forEach((dynamic periodStd, dynamic data) {
        GamePeriod period = GamePeriod.fromIndex(periodStd);
        GameResultPerPeriod newResult =
            GameResultPerPeriod.fromJSON(period, data).build();
        builder.scores[period] = newResult;
        //newResults[period] = newResult;
      });
      //scores = newResults;
    }
    if (data[_INPROGRESS] == null) {
      builder.inProgress = GameInProgress.NotStarted;
    } else {
      String str = data[_INPROGRESS];
      if (!str.startsWith('GameInProgress')) {
        builder.inProgress = GameInProgress.NotStarted;
      } else {
        builder.inProgress = GameInProgress.values
            .firstWhere((e) => e.toString() == data[_INPROGRESS]);
      }
    }
    builder.result = GameResult.values.firstWhere(
        (e) => e.toString() == data[_RESULT],
        orElse: () => GameResult.Unknown);
    if (builder.result == null) {
      builder.result = GameResult.Unknown;
    }
    if (data[_PERIOD] is String) {
      builder.currentPeriod = GamePeriod.fromIndex(data[_PERIOD]).toBuilder();
    }
    if (data.containsKey(_DIVISIONS) && data[_DIVISIONS] != null) {
      builder.divisions = GameDivisionsType.values
          .firstWhere((e) => e.toString() == data[_DIVISIONS]);
    }
    if (data.containsKey(_TIME_DETAILS)) {
      builder.time = GamePeriodTime.fromJSON(data[_TIME_DETAILS]);
    } else {
      builder.time = GamePeriodTimeBuilder()..timeCountUp = false;
    }
    return builder;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    Map<String, dynamic> retScores = {};
    for (GameResultPerPeriod p in scores.values) {
      Map<String, dynamic> periodExtra = p.toJSON();
      retScores[p.period.toIndex()] = periodExtra;
    }
    ret[_SCORES] = retScores;
    ret[_RESULT] = result.toString();
    ret[_INPROGRESS] = inProgress.toString();
    ret[_PERIOD] = currentPeriod?.toIndex() ?? "";
    ret[_TIME_DETAILS] = time.toJSON();
    ret[_DIVISIONS] =
        divisions?.toString() ?? GameDivisionsType.Halves.toString();
    return ret;
  }

  ///
  /// Result for the regulation period.
  /// (can be null!)
  ///
  GameResultPerPeriod get regulationResult =>
      scores.containsKey(GamePeriod.regulation)
          ? scores[GamePeriod.regulation]
          : null;

  ///
  /// Result for the overtime period.
  /// (can be null!)
  ///
  GameResultPerPeriod get overtimeResult =>
      scores.containsKey(GamePeriod.overtime)
          ? scores[GamePeriod.overtime]
          : null;

  ///
  /// Result for the penalty period.
  /// (can be null!)
  ///
  GameResultPerPeriod get penaltyResult =>
      scores.containsKey(GamePeriod.penalty)
          ? scores[GamePeriod.penalty]
          : null;

  ///
  /// If this game is currently finished.
  ///
  bool get isGameFinished => inProgress == GameInProgress.Final;

  @override
  String toString() {
    return 'GameResultDetails{scores: $scores, result: $result, '
        'inProgress: $inProgress, period: $currentPeriod, time: $time}';
  }
}
