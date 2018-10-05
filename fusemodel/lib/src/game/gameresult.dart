import 'gameperiod.dart';
import 'gamescore.dart';
import 'package:collection/collection.dart';
import 'gameresultshareddetails.dart';

enum GameResult { Win, Loss, Tie, Unknown }
enum GameInProgress { NotStarted, InProgress, Final }
enum GameDivisionsType { Halves, Quarters, Thirds }

class GameResultPerPeriod {
  GameResultPerPeriod({this.period, this.score});
  GameResultPerPeriod.copy(GameResultPerPeriod res) {
    period = res.period;
    score = new GameScore(
        ptsFor: res.score.ptsFor, ptsAgainst: res.score.ptsAgainst);
  }
  GamePeriod period;
  GameScore score = new GameScore();

  GameResultPerPeriod.fromJSON(GamePeriod period, Map<dynamic, dynamic> data) {
    this.period = period;
    score = new GameScore.fromJSON(data);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    score.toJSON(ret);
    return ret;
  }

  String toString() {
    return "GameResultPerPeriod[ $period, $score]";
  }
}

class GameResultDetails extends GameResultSharedDetails {
  CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> scores =
  new CanonicalizedMap((GamePeriod p) => p.toIndex());
  GameResult result;
  GameInProgress inProgress;
  GamePeriod currentPeriod; // Null until the game started.
  GameDivisionsType divisions = GameDivisionsType.Halves;
  GamePeriodTime time = new GamePeriodTime();

  GameResultDetails() {
    result = GameResult.Unknown;
    inProgress = GameInProgress.NotStarted;
    GamePeriod per =
    new GamePeriod(type: GamePeriodType.Regulation, periodNumber: 0);
    scores[per] = new GameResultPerPeriod(
        period: per, score: new GameScore(ptsAgainst: 0, ptsFor: 0));
  }

  GameResultDetails.copy(GameResultDetails copy) {
    copy.scores.values.forEach((GameResultPerPeriod per) {
      this.scores[new GamePeriod.copy(per.period)] =
      new GameResultPerPeriod.copy(per);
    });
    result = copy.result;
    inProgress = copy.inProgress;
    divisions = copy.divisions;
    if (divisions == null) {
      divisions = GameDivisionsType.Halves;
    }
    currentPeriod = copy.currentPeriod;
    time = new GamePeriodTime.copy(copy.time);
  }

  static const String _SCORES = 'scores';
  static const String _RESULT = 'result';
  static const String _INPROGRESS = 'inProgress';
  static const String _PERIOD = 'period';
  static const String _DIVISIONS = 'divisions';
  static const String _TIME_DETAILS = 'timeDetails';

  void fromJSON(Map<dynamic, dynamic> data) {
    if (data.containsKey(_SCORES)) {
      Map<dynamic, dynamic> scoreData = data[_SCORES];
      CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> newResults =
      new CanonicalizedMap((GamePeriod p) => p.toIndex());
      scoreData.forEach((dynamic periodStd, dynamic data) {
        GamePeriod period = GamePeriod.fromIndex(periodStd);
        GameResultPerPeriod newResult =
        new GameResultPerPeriod.fromJSON(period, data);

        newResults[period] = newResult;
      });
      scores = newResults;
    }
    if (data[_INPROGRESS] == null) {
      inProgress = GameInProgress.NotStarted;
    } else {
      String str = data[_INPROGRESS];
      if (!str.startsWith('GameInProgress')) {
        inProgress = GameInProgress.NotStarted;
      } else {
        inProgress = GameInProgress.values
            .firstWhere((e) => e.toString() == data[_INPROGRESS]);
      }
    }
    result = GameResult.values.firstWhere((e) => e.toString() == data[_RESULT],
        orElse: () => GameResult.Unknown);
    if (result == null) {
      result = GameResult.Unknown;
    }
    if (data[_PERIOD] is String) {
      currentPeriod = GamePeriod.fromIndex(data[_PERIOD]);
    }
    if (data.containsKey(_DIVISIONS) && data[_DIVISIONS] != null) {
      divisions = GameDivisionsType.values
          .firstWhere((e) => e.toString() == data[_DIVISIONS]);
    }
    if (data.containsKey(_TIME_DETAILS)) {
      time.fromJSON(data[_TIME_DETAILS]);
    } else {
      time.fromJSON({});
    }
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
  bool get isGameFinished =>
      inProgress == GameInProgress.Final;

  @override
  String toString() {
    return 'GameResultDetails{scores: $scores, result: $result, '
        'inProgress: $inProgress, period: $currentPeriod, time: $time}';
  }
}
