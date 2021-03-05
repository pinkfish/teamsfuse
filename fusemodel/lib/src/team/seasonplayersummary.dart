import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../player/playersummarydata.dart';
import '../serializer.dart';

part 'seasonplayersummary.g.dart';

///
/// This is the player summary for the season.
///
abstract class SeasonPlayerSummary
    implements Built<SeasonPlayerSummary, SeasonPlayerSummaryBuilder> {
  PlayerSummaryData get basketballSummary;

  SeasonPlayerSummary._();

  factory SeasonPlayerSummary(
      [Function(SeasonPlayerSummaryBuilder b) updates]) = _$SeasonPlayerSummary;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(SeasonPlayerSummary.serializer, this);
  }

  static SeasonPlayerSummary fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        SeasonPlayerSummary.serializer, jsonData);
  }

  static Serializer<SeasonPlayerSummary> get serializer =>
      _$seasonPlayerSummarySerializer;
}
