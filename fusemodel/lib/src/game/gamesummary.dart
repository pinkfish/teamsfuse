import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';

part 'gamesummary.g.dart';

abstract class GameSummary implements Built<GameSummary, GameSummaryBuilder> {
  int get pointsFor;
  int get pointsAgainst;

  bool get finished;

  GameSummary._();
  factory GameSummary([updates(GameSummaryBuilder b)]) = _$GameSummary;

  static void _initializeBuilder(GameSummaryBuilder b) => b
    ..finished = false
    ..pointsFor = 0
    ..pointsAgainst = 0;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GameSummary.serializer, this);
  }

  static GameSummary fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(GameSummary.serializer, jsonData);
  }

  static Serializer<GameSummary> get serializer => _$gameSummarySerializer;
}
