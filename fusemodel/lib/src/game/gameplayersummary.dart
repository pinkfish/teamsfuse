import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../player.dart';
import '../serializer.dart';
import 'gameperiod.dart';

part 'gameplayersummary.g.dart';

///
/// This is the player summary for the game.  Tracks per period
/// details about the game.
///
abstract class GamePlayerSummary
    implements Built<GamePlayerSummary, GamePlayerSummaryBuilder> {
  /// Per period stats and results.
  BuiltMap<GamePeriod, PlayerSummaryData> get perPeriod;

  /// If the person is currently player.
  bool get currentlyPlaying;

  /// If the person is playing.
  bool get playing;

  /// The jersey number for the player.
  String get jerseyNumber;

  static void _initializeBuilder(GamePlayerSummaryBuilder b) => b
    ..currentlyPlaying = false
    ..playing = true
    ..jerseyNumber = '';

  GamePlayerSummary._();

  factory GamePlayerSummary([Function(GamePlayerSummaryBuilder b) updates]) =
      _$GamePlayerSummary;

  /// Seriallize the summary.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GamePlayerSummary.serializer, this);
  }

  /// Deserailize the player.
  static GamePlayerSummary fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        GamePlayerSummary.serializer, jsonData);
  }

  /// The serializer fot eh player.
  static Serializer<GamePlayerSummary> get serializer =>
      _$gamePlayerSummarySerializer;

  /// Pull the summary togather from all the periods.
  @memoized
  PlayerSummaryData get fullData {
    var b = PlayerSummaryDataBuilder();
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
