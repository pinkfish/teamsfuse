import 'package:fusemodel/fusemodel.dart';

///
/// This class converts from the offical results on a game
/// to the results for this specific team.
///
class GameFromOfficial extends GameResultSharedDetails{
  final Game game;
  final String awayTeamLeageUid;

  final GameResultPerPeriod _finalResult;
  final GameResultPerPeriod _overtimeResult;
  final GameResultPerPeriod _penaltyResult;

  GameFromOfficial(this.game, this.awayTeamLeageUid)
      : _finalResult = _swapResult(
            game.sharedData.officialResults.scores,
            GamePeriod.regulation,
            game.sharedData.officialResults.homeTeamLeagueUid !=
                awayTeamLeageUid),
        _overtimeResult = _swapResult(
            game.sharedData.officialResults.scores,
            GamePeriod.overtime,
            game.sharedData.officialResults.homeTeamLeagueUid !=
                awayTeamLeageUid),
        _penaltyResult = _swapResult(
            game.sharedData.officialResults.scores,
            GamePeriod.penalty,
            game.sharedData.officialResults.homeTeamLeagueUid !=
                awayTeamLeageUid);

  /// If the game is finished.
  bool get isGameFinished =>
      game.sharedData.officialResults.result != OfficialResult.InProgress &&
      game.sharedData.officialResults.result != OfficialResult.NotStarted;

  /// Is this a home game?
  bool get isHomeGame =>
      game.sharedData.officialResults.homeTeamLeagueUid != awayTeamLeageUid;

  /// The regulation result for the game
  GameResultPerPeriod get regulationResult => _finalResult;

  /// The overtime result for the game.
  GameResultPerPeriod get overtimeResult => _overtimeResult;

  /// The penalty result for the game.
  GameResultPerPeriod get penaltyResult => _penaltyResult;

  /// Figure out if this is the same as the official results.
  bool _isSameAs(GameResultPerPeriod regulationResult,
      GameResultPerPeriod overtimeResult, GameResultPerPeriod penaltyResult) {
    return _compareResults(_finalResult, regulationResult) &&
        _compareResults(_overtimeResult, overtimeResult) &&
        _compareResults(_penaltyResult, penaltyResult);
  }

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
      Map<GamePeriod, GameResultPerPeriod> results,
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
    return GameResultPerPeriod(
      score: GameScore(
          ptsAgainst: scores.score.ptsFor, ptsFor: scores.score.ptsAgainst),
      period: scores.period,
    );
  }

  GameResult get result {
    switch (game.sharedData.officialResults.result) {
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
  }
}
