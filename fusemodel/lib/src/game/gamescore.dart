import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';

part 'gamescore.g.dart';

///
/// The score for the game.
///
abstract class GameScore implements Built<GameScore, GameScoreBuilder> {
  GameScore._();

  /// Factory to make the score.
  factory GameScore([Function(GameScoreBuilder b) updates]) = _$GameScore;

  /// Points for the game.
  num get ptsFor;

  /// Points against in the game.
  num get ptsAgainst;

  /// If this is a partial result.
  bool get intermediate;

  /// The key index for ptsFor.
  static const String PTS_FOR = 'ptsFor';

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameScoreBuilder b) => b
    ..ptsFor = 0
    ..ptsAgainst = 0
    ..intermediate = false;

  /// Serialize the score.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GameScore.serializer, this);
  }

  /// Desearcialize the score.
  static GameScore fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(GameScore.serializer, jsonData);
  }

  /// The serializer for the score.
  static Serializer<GameScore> get serializer => _$gameScoreSerializer;

  @override
  String toString() {
    return 'GameScore[ ptsFor: $ptsFor, ptsAgainst: $ptsAgainst, intermediate $intermediate]';
  }
}
