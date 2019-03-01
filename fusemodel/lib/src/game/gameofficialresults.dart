import 'gameperiod.dart';
import 'gameresult.dart';
import 'package:collection/collection.dart';

enum OfficialResult { HomeTeamWon, AwayTeamWon, Tie, NotStarted, InProgress }

///
/// The offical results we have for this game.  This only exists when the
/// game is in a tournament or a league.
///
class GameOfficialResults {
  final CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> scores =
      new CanonicalizedMap((GamePeriod p) => p.toIndex());

  /// The team uid, this pointed to a leagueortourneamentteam data.
  String homeTeamLeagueUid;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  String awayTeamLeagueUid;

  OfficialResult result;

  static const String _OFFICIALRESULT = 'officialResult';
  static const String _SCORES = 'scores';
  static const String HOMETEAMUID = 'homeTeamUid';
  static const String AWAYTEAMUID = 'awayTeamUid';

  GameOfficialResults(this.homeTeamLeagueUid, this.awayTeamLeagueUid,
      {this.result = OfficialResult.NotStarted});

  GameOfficialResults.copy(GameOfficialResults copy)
      : homeTeamLeagueUid = copy.homeTeamLeagueUid,
        awayTeamLeagueUid = copy.awayTeamLeagueUid,
        result = copy.result {
    for (GamePeriod p in copy.scores.keys) {
      scores[p] = GameResultPerPeriod.copy(copy.scores[p]);
    }
  }

  GameOfficialResults.fromJSON(Map<dynamic, dynamic> data)
      : result = OfficialResult.values.firstWhere(
            (e) =>
                e.toString() == data[_OFFICIALRESULT] ??
                OfficialResult.NotStarted.toString(),
            orElse: () => OfficialResult.NotStarted),
        homeTeamLeagueUid = data[HOMETEAMUID],
        awayTeamLeagueUid = data[AWAYTEAMUID] {
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
      scores.addAll(newResults);
    }
    ;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = {};
    Map<String, dynamic> retScores = {};
    for (GameResultPerPeriod p in scores.values) {
      Map<String, dynamic> periodExtra = p.toJSON();
      retScores[p.period.toIndex()] = periodExtra;
    }
    ret[_SCORES] = retScores;
    ret[_OFFICIALRESULT] = result.toString();
    ret[AWAYTEAMUID] = awayTeamLeagueUid;
    ret[HOMETEAMUID] = homeTeamLeagueUid;
    return ret;
  }
}
