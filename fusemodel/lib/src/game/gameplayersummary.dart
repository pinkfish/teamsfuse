import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import '../player.dart';
import 'gameperiod.dart';

part 'gameplayersummary.g.dart';

///
/// This is the player summary for the game.  Tracks per period
/// details about the game.
///
abstract class GamePlayerSummary
    implements Built<GamePlayerSummary, GamePlayerSummaryBuilder> {
  BuiltMap<GamePeriod, PlayerSummaryData> get perPeriod;

  bool get currentlyPlaying;

  bool get playing;

  static void _initializeBuilder(GamePlayerSummaryBuilder b) => b
    ..currentlyPlaying = false
    ..playing = true;

  GamePlayerSummary._();

  factory GamePlayerSummary([updates(GamePlayerSummaryBuilder b)]) =
      _$GamePlayerSummary;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GamePlayerSummary.serializer, this);
  }

  static GamePlayerSummary fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GamePlayerSummary.serializer, jsonData);
  }

  static Serializer<GamePlayerSummary> get serializer =>
      _$gamePlayerSummarySerializer;

  @memoized
  PlayerSummaryData get fullData {
    PlayerSummaryDataBuilder b = PlayerSummaryDataBuilder();
    for (var s in perPeriod.values) {
      b.steals += s.steals;
      b.turnovers += s.turnovers;
      b.assists += s.assists;
      b.blocks += s.blocks;
      b.defensiveRebounds += s.defensiveRebounds;
      b.offensiveRebounds += s.offensiveRebounds;
      b.fouls += s.fouls;
      b.one.made += s.one.made;
      b.one.attempts += s.one.attempts;
      b.two.made += s.two.made;
      b.two.attempts += s.two.attempts;
      b.three.made += s.three.made;
      b.three.attempts += s.three.attempts;
    }
    return b.build();
  }
}