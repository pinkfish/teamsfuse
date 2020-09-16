import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';

part 'gamescore.g.dart';

abstract class GameScore implements Built<GameScore, GameScoreBuilder> {
  GameScore._();
  factory GameScore([updates(GameScoreBuilder b)]) = _$GameScore;

  num get ptsFor;
  num get ptsAgainst;
  bool get intermediate;

  static const String PTS_FOR = 'ptsFor';

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameScoreBuilder b) => b
    ..ptsFor = 0
    ..ptsAgainst = 0
    ..intermediate = false;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameScore.serializer, this);
  }

  static GameScore fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameScore.serializer, jsonData);
  }

  static Serializer<GameScore> get serializer => _$gameScoreSerializer;

  String toString() {
    return "GameScore[ ptsFor: $ptsFor, ptsAgainst: $ptsAgainst, intermediate $intermediate]";
  }
}
