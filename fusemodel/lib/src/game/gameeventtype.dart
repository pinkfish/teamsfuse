import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'gameeventtype.g.dart';

///
/// The type of the game event.
///
class GameEventType extends EnumClass {
  static Serializer<GameEventType> get serializer => _$gameEventTypeSerializer;

  /// Made the shot.
  static const GameEventType Made = _$made;

  /// Missed the shot.
  static const GameEventType Missed = _$missed;

  /// Foul called on them.
  static const GameEventType Foul = _$foul;

  /// Sub called (person in/out).
  static const GameEventType Sub = _$sub;

  /// Offensive rebound called.
  static const GameEventType OffensiveRebound = _$offensiveRebound;

  /// Defensive rebound.
  static const GameEventType DefensiveRebound = _$defensiveRebound;

  /// Blocked shot.
  static const GameEventType Block = _$block;

  /// Stole the ball.
  static const GameEventType Steal = _$steal;

  /// Caused a turnover.
  static const GameEventType Turnover = _$turnover;

  /// Start of the period.
  static const GameEventType PeriodStart = _$periodStart;

  /// End of the period,
  static const GameEventType PeriodEnd = _$periodEnd;

  /// Start of a timeout.
  static const GameEventType TimeoutStart = _$timeoutStart;

  /// End of the timeout.
  static const GameEventType TimeoutEnd = _$timeoutEnd;

  /// No event.
  static const GameEventType EmptyEvent = _$emptyEvent;

  /// Someone sent a message.
  static const GameEventType Message = _$message;

  /// Set the score to a specific value.
  static const GameEventType ScoreSet = _$scoreSet;

  /// Jump ball called for the player.
  static const GameEventType JumpBall = _$jumpBall;

  const GameEventType._(String name) : super(name);

  static BuiltSet<GameEventType> get values => _$values;

  static GameEventType valueOf(String name) => _$valueOf(name);
}
