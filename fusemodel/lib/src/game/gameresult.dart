import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'gameperiod.dart';
import 'gameresultshareddetails.dart';
import 'gamescore.dart';

part 'gameresult.g.dart';

class GameResult extends EnumClass {
  static Serializer<GameResult> get serializer => _$gameResultSerializer;

  static const GameResult Win = _$win;
  static const GameResult Loss = _$loss;
  static const GameResult Tie = _$penalty;
  static const GameResult Unknown = _$unknown;

  const GameResult._(String name) : super(name);

  static BuiltSet<GameResult> get values => _$GameResultalues;

  static GameResult valueOf(String name) => _$GameResultValueOf(name);
}

class GameInProgress extends EnumClass {
  static Serializer<GameInProgress> get serializer =>
      _$gameInProgressSerializer;

  static const GameInProgress NotStarted = _$NotStarted;
  static const GameInProgress InProgress = _$InProgress;
  static const GameInProgress Final = _$Final;

  const GameInProgress._(String name) : super(name);

  static BuiltSet<GameInProgress> get values => _$GameInProgressValues;

  static GameInProgress valueOf(String name) => _$GameInProgressValueOf(name);

  static List<GameInProgress> valuesByIndex = [
    GameInProgress.NotStarted,
    GameInProgress.InProgress,
    GameInProgress.Final,
  ];

  static int getIndex(GameInProgress g) => valuesByIndex.indexOf(g);
}

class GameDivisionsType extends EnumClass {
  static Serializer<GameDivisionsType> get serializer =>
      _$gameDivisionsTypeSerializer;

  static const GameDivisionsType Halves = _$Halves;
  static const GameDivisionsType Quarters = _$Quarters;
  static const GameDivisionsType Thirds = _$Thirds;

  const GameDivisionsType._(String name) : super(name);

  static BuiltSet<GameDivisionsType> get values => _$GameDivisionsTypeValues;

  static GameDivisionsType valueOf(String name) =>
      _$GameDivisionsTypeValueOf(name);
}

///
/// The result of the game per period.
///
abstract class GameResultPerPeriod
    implements Built<GameResultPerPeriod, GameResultPerPeriodBuilder> {
  GamePeriod get period;

  GameScore get score;

  GameResultPerPeriod._();

  factory GameResultPerPeriod([updates(GameResultPerPeriodBuilder b)]) =
      _$GameResultPerPeriod;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameResultPerPeriod.serializer, this);
  }

  static GameResultPerPeriod fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(
        GameResultPerPeriod.serializer, jsonData);
  }

  static Serializer<GameResultPerPeriod> get serializer =>
      _$gameResultPerPeriodSerializer;
}

abstract class GameResultDetails
    with GameResultSharedDetails
    implements Built<GameResultDetails, GameResultDetailsBuilder> {
  @BuiltValueField(wireName: "scores")
  BuiltMap<String, GameResultPerPeriod> get scoresInternal;

  GameResult get result;

  GameInProgress get inProgress;

  GamePeriod get currentPeriod; // Null until the game started.
  GameDivisionsType get divisions; // = GameDivisionsType.Halves;
  GamePeriodTime get time;

  @memoized
  BuiltMap<GamePeriod, GameResultPerPeriod> get scores =>
      BuiltMap(scoresInternal
          .map((k, v) => MapEntry(GamePeriod.fromIndex(k), v))
          .rebuild((b) {
        // Turn a 'final' into a 'regulation'.
        if (scoresInternal.containsKey("Final")) {
          b[GamePeriod.regulation1] = b[GamePeriod.finalPeriod];
        }
        return b;
      }));

  GameResultDetails._();

  factory GameResultDetails([updates(GameResultDetailsBuilder b)]) =
      _$GameResultDetails;

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameResultDetailsBuilder b) =>
      b..currentPeriod = GamePeriod.regulation1.toBuilder();

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameResultDetails.serializer, this);
  }

  static GameResultDetails fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameResultDetails.serializer, jsonData);
  }

  static Serializer<GameResultDetails> get serializer =>
      _$gameResultDetailsSerializer;

  ///
  /// Result for the regulation period.
  /// (can be null!)
  ///
  @memoized
  GameResultPerPeriod get regulationResult =>
      scores.containsKey(GamePeriod.regulation1)
          ? scores[GamePeriod.regulation1]
          : null;

  ///
  /// Result for the overtime period.
  /// (can be null!)
  ///
  @memoized
  GameResultPerPeriod get overtimeResult =>
      scores.containsKey(GamePeriod.overtime1)
          ? scores[GamePeriod.overtime1]
          : null;

  ///
  /// Result for the penalty period.
  /// (can be null!)
  ///
  @memoized
  GameResultPerPeriod get penaltyResult =>
      scores.containsKey(GamePeriod.penalty)
          ? scores[GamePeriod.penalty]
          : null;

  ///
  /// If this game is currently finished.
  ///
  @memoized
  bool get isGameFinished => inProgress == GameInProgress.Final;

  @override
  String toString() {
    return 'GameResultDetails{scores: $scores, result: $result, '
        'inProgress: $inProgress, period: $currentPeriod, time: $time}';
  }
}
