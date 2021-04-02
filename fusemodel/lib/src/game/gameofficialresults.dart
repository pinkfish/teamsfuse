import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'gameperiod.dart';
import 'gameresult.dart';

part 'gameofficialresults.g.dart';

///
/// The offical result for the game
///
class OfficialResult extends EnumClass {
  static Serializer<OfficialResult> get serializer =>
      _$officialResultSerializer;

  static const OfficialResult HomeTeamWon = _$homeTeamWon;
  static const OfficialResult AwayTeamWon = _$awayTeamWon;
  static const OfficialResult Tie = _$tie;
  static const OfficialResult NotStarted = _$notStarted;
  static const OfficialResult InProgress = _$inProgress;

  const OfficialResult._(String name) : super(name);

  static BuiltSet<OfficialResult> get values => _$OfficialResultValues;

  static OfficialResult valueOf(String name) => _$OfficialResultValueOf(name);
}

///
/// The offical results we have for this game.  This only exists when the
/// game is in a tournament or a league.
///
abstract class GameOfficialResults
    implements Built<GameOfficialResults, GameOfficialResultsBuilder> {
  @BuiltValueField(wireName: 'scores')
  BuiltMap<String, GameResultPerPeriod> get scoresInternal;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  @nullable
  @BuiltValueField(wireName: 'homeTeamUid')
  String get homeTeamLeagueUid;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  @nullable
  @BuiltValueField(wireName: 'awayTeamUid')
  String get awayTeamLeagueUid;

  /// The official result for the game.
  OfficialResult get result;

  @memoized
  BuiltMap<GamePeriod, GameResultPerPeriod> get scores =>
      BuiltMap(scoresInternal
          .map((k, v) => MapEntry(GamePeriod.fromIndex(k), v))
          .rebuild((b) {
        if (scoresInternal.containsKey('Final')) {
          b[GamePeriod.regulation1] = b[GamePeriod.finalPeriod];
        }
        return b;
      }));

  static const String homeTeamUidField = 'homeTeamUid';
  static const String awayTeamUidField = 'awayTeamUid';

  GameOfficialResults._();
  factory GameOfficialResults(
      [Function(GameOfficialResultsBuilder b) updates]) = _$GameOfficialResults;

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameOfficialResultsBuilder b) =>
      b..result = OfficialResult.NotStarted;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GameOfficialResults.serializer, this);
  }

  static GameOfficialResults fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        GameOfficialResults.serializer, jsonData);
  }

  static Serializer<GameOfficialResults> get serializer =>
      _$gameOfficialResultsSerializer;
}
