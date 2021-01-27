import 'package:built_collection/built_collection.dart';

import 'gameofficialresults.dart';
import 'gameperiod.dart';
import 'gameresult.dart';
import 'gameresultshareddetails.dart';
import 'gamescore.dart';
import 'gamesharedata.dart';

///
/// This class converts from the offical results on a game
/// to the results for this specific team.
///
class GameFromOfficial extends GameResultSharedDetails {
  final GameSharedData game;
  final String awayTeamLeageUid;

  final GameResultPerPeriod _finalResult;
  final GameResultPerPeriod _overtimeResult;
  final GameResultPerPeriod _penaltyResult;

  GameFromOfficial(this.game, this.awayTeamLeageUid)
      : _finalResult = _swapResult(
            game.officialResult.scores,
            GamePeriod.regulation1,
            game.officialResult.homeTeamLeagueUid != awayTeamLeageUid),
        _overtimeResult = _swapResult(
            game.officialResult.scores,
            GamePeriod.overtime1,
            game.officialResult.homeTeamLeagueUid != awayTeamLeageUid),
        _penaltyResult = _swapResult(
            game.officialResult.scores,
            GamePeriod.penalty,
            game.officialResult.homeTeamLeagueUid != awayTeamLeageUid);

  /// If the game is finished.
  bool get isGameFinished =>
      game.officialResult.result != OfficialResult.InProgress &&
      game.officialResult.result != OfficialResult.NotStarted;

  /// Is this a home game?
  bool get isHomeGame =>
      game.officialResult.homeTeamLeagueUid != awayTeamLeageUid;

  /// The regulation result for the game
  GameResultPerPeriod get regulationResult => _finalResult;

  /// The overtime result for the game.
  GameResultPerPeriod get overtimeResult => _overtimeResult;

  /// The penalty result for the game.
  GameResultPerPeriod get penaltyResult => _penaltyResult;

  /// Figure out if this is the same as the official results.
  bool isSameAs(GameResultSharedDetails result) {
    return _compareResults(_finalResult, result.regulationResult) &&
        _compareResults(_overtimeResult, result.overtimeResult) &&
        _compareResults(_penaltyResult, result.penaltyResult);
  }

  ///
  /// Compares the results of official vs team results.
  ///
  bool _compareResults(
      GameResultPerPeriod offical, GameResultPerPeriod teamBased) {
    if (offical == null && teamBased == null) {
      return true;
    }
    if (offical == null && teamBased != null) {
      return false;
    }
    if (offical != null && teamBased == null) {
      return false;
    }
    return offical.score.ptsFor == teamBased.score.ptsFor &&
        offical.score.ptsAgainst == teamBased.score.ptsAgainst;
  }

  static GameResultPerPeriod _swapResult(
      BuiltMap<GamePeriod, GameResultPerPeriod> results,
      GamePeriod period,
      bool isHomeGame) {
    GameResultPerPeriod scores;
    if (!results.containsKey(period)) {
      return null;
    }
    scores = results[period];
    if (isHomeGame) {
      return scores;
    }
    GameScoreBuilder scoreBuilder = GameScoreBuilder()
      ..ptsAgainst = scores.score.ptsFor
      ..ptsFor = scores.score.ptsAgainst
      ..intermediate = scores.score.intermediate;
    return GameResultPerPeriod(
      (b) => b
        ..score = scoreBuilder
        ..period = scores.period.toBuilder(),
    );
  }

  GameResult get result {
    switch (game.officialResult.result) {
      case OfficialResult.HomeTeamWon:
        if (isHomeGame) {
          return GameResult.Win;
        }
        return GameResult.Loss;
      case OfficialResult.AwayTeamWon:
        if (isHomeGame) {
          return GameResult.Loss;
        }
        return GameResult.Win;
      case OfficialResult.Tie:
        return GameResult.Tie;
      case OfficialResult.InProgress:
      case OfficialResult.NotStarted:
        return GameResult.Unknown;
    }
    return GameResult.Unknown;
  }
}
