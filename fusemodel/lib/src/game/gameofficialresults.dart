import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:collection/collection.dart';

import 'gameperiod.dart';
import 'gameresult.dart';

part 'gameofficialresults.g.dart';

enum OfficialResult { HomeTeamWon, AwayTeamWon, Tie, NotStarted, InProgress }

///
/// The offical results we have for this game.  This only exists when the
/// game is in a tournament or a league.
///
abstract class GameOfficialResults
    implements Built<GameOfficialResults, GameOfficialResultsBuilder> {
  //final CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> scores =
  //    new CanonicalizedMap((GamePeriod p) => p.toIndex());
  BuiltMap<GamePeriod, GameResultPerPeriod> get scores;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  String get homeTeamLeagueUid;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  String get awayTeamLeagueUid;

  OfficialResult get result;

  static const String _OFFICIALRESULT = 'officialResult';
  static const String _SCORES = 'scores';
  static const String HOMETEAMUID = 'homeTeamUid';
  static const String AWAYTEAMUID = 'awayTeamUid';

  GameOfficialResults._();
  factory GameOfficialResults([updates(GameOfficialResultsBuilder b)]) =
      _$GameOfficialResults;

  static GameOfficialResultsBuilder fromJSON(Map<dynamic, dynamic> data) {
    GameOfficialResultsBuilder builder = GameOfficialResultsBuilder();
    builder
      ..result = OfficialResult.values.firstWhere(
          (e) =>
              e.toString() == data[_OFFICIALRESULT] ??
              OfficialResult.NotStarted.toString(),
          orElse: () => OfficialResult.NotStarted)
      ..homeTeamLeagueUid = data[HOMETEAMUID]
      ..awayTeamLeagueUid = data[AWAYTEAMUID];
    if (data.containsKey(_SCORES)) {
      Map<dynamic, dynamic> scoreData = data[_SCORES];
      CanonicalizedMap<String, GamePeriod, GameResultPerPeriod> newResults =
          new CanonicalizedMap((GamePeriod p) => p.toIndex());
      scoreData.forEach((dynamic periodStd, dynamic data) {
        GamePeriod period = GamePeriod.fromIndex(periodStd);
        GameResultPerPeriod newResult =
            GameResultPerPeriod.fromJSON(period, data).build();

        builder.scores[period] = newResult;
      });
      //scores.addAll(newResults);
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
    ret[_OFFICIALRESULT] = result.toString();
    ret[AWAYTEAMUID] = awayTeamLeagueUid;
    ret[HOMETEAMUID] = homeTeamLeagueUid;
    return ret;
  }
}
