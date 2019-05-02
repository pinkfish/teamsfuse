import 'package:built_value/built_value.dart';

import '../common.dart';

part 'gamescore.g.dart';

abstract class GameScore implements Built<GameScore, GameScoreBuilder> {
  GameScore._();
  factory GameScore([updates(GameScoreBuilder b)]) = _$GameScore;

  num get ptsFor;
  num get ptsAgainst;
  bool get intermediate;

  static const String PTS_FOR = 'ptsFor';
  static const String _PTS_AGAINST = 'ptsAgainst';
  static const String _INTERMEDIATE = 'intermediate';

  static GameScoreBuilder fromJSON(Map<dynamic, dynamic> data) {
    return GameScoreBuilder()
      ..ptsAgainst = getNum(data[_PTS_AGAINST])
      ..ptsFor = getNum(data[PTS_FOR])
      ..intermediate = getBool(data[_INTERMEDIATE]);
  }

  void toJSON(Map<String, dynamic> data) {
    data[PTS_FOR] = ptsFor;
    data[_PTS_AGAINST] = ptsAgainst;
    data[_INTERMEDIATE] = intermediate;
  }

  String toString() {
    return "GameScore[ ptsFor: $ptsFor, ptsAgainst: $ptsAgainst, intermediate $intermediate]";
  }
}
