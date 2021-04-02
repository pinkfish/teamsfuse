import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:clock/clock.dart';
import 'package:timezone/timezone.dart';

import '../serializer.dart';
import 'gameperiod.dart';
import 'gameplayersummary.dart';
import 'gameresult.dart';
import 'gamesharedata.dart';

part 'game.g.dart';

///
/// Tracking the attendance for the game.
///
class Attendance extends EnumClass {
  /// The serializer for the attendence enum
  static Serializer<Attendance> get serializer => _$attendanceSerializer;

  /// Yes for attendance.
  static const Attendance Yes = _$Yes;

  /// No for attendance.
  static const Attendance No = _$No;

  /// Maybe for attendance.
  static const Attendance Maybe = _$Maybe;

  const Attendance._(String name) : super(name);

  /// The values of the enum.
  static BuiltSet<Attendance> get values => _$AttendanceValues;

  /// The value from the string.
  static Attendance valueOf(String name) => _$AttendanceValueOf(name);
}

///
/// This is the game details and it is kept in a team specific format, so that
/// the view of the same game for different teams will look different.
///
abstract class Game implements Built<Game, GameBuilder> {
  /// Uid of the game
  String get uid;

  /// The data uid for the shared parts of this.
  @BuiltValueField(wireName: sharedDataUidField)
  String get sharedDataUid;

  /// When people should arrive.
  DateTime get arrivalTime;

  /// Notes about the game
  String get notes;

  /// The opponent for the game
  @BuiltValueField(wireName: opponentUidField)
  String get opponentUid;

  /// The season for the game
  String get seasonUid;

  /// The team the game is associated with.
  @BuiltValueField(wireName: teamUidField)
  String get teamUid;

  /// The uniforms for the team
  String get uniform;

  /// The series of games, if this is a series.
  @nullable
  String get seriesId;

  /// The result of the game, broken down by period.
  @BuiltValueField(wireName: resultField)
  GameResultDetails get result;

  /// If people attended the game
  BuiltMap<String, Attendance> get attendance;

  /// If we should track attendance
  bool get trackAttendance;

  /// The shared information about the game
  GameSharedData get sharedData;

  /// The opponent for the game if it is in a league.
  @nullable
  String get leagueOpponentUid;

  /// Summary for this specific player.
  @BuiltValueField(wireName: playersField)
  BuiltMap<String, GamePlayerSummary> get players;

  /// Summary for this specific opponent.
  @BuiltValueField(wireName: opponentField)
  BuiltMap<String, GamePlayerSummary> get opponents;

  /// Total summary for the game for this players.
  GamePlayerSummary get playerSummary;

  /// Total summary for the game for the opponents.
  GamePlayerSummary get opponentSummary;

  /// Tracks when this game is running from.  This is used when the
  /// game starts to track the current position in the game.
  @nullable
  DateTime get runningFrom;

  /// How long into the game we are currently.
  Duration get gameTime;

  /// List of players to ignore from the season set.
  BuiltList<String> get ignoreFromSeason;

  /// All the uids for the team, including the opponent.
  @memoized
  BuiltList<String> get allTeamUids {
    if (opponentUid.isNotEmpty) {
      return BuiltList.of([teamUid, opponentUid]);
    }
    return BuiltList.of([
      teamUid,
    ]);
  }

  ///
  /// Return the player summary for the player, null does not exist.
  ///
  GamePlayerSummary getPlayerSummary(String playerUid) {
    if (players.containsKey(playerUid)) {
      return players[playerUid];
    }
    if (opponents.containsKey(playerUid)) {
      return opponents[playerUid];
    }
    return null;
  }

  /// The current time of the game, used when making events.
  Duration get currentGameTime {
    var diff = 0;
    if (runningFrom != null) {
      diff += clock.now().difference(runningFrom).inSeconds;
    }
    diff += gameTime.inSeconds;
    return Duration(seconds: diff);
  }

  Game._();

  /// The factory to create the game.
  factory Game([Function(GameBuilder b) updates]) = _$Game;

  /// If this is a home game or not.
  bool get homeGame => sharedData.officialResult.homeTeamLeagueUid == teamUid;

  /// The arrival time for the game in the right timezone.
  TZDateTime get tzArriveTime =>
      TZDateTime.from(arrivalTime, sharedData.location);

  /// The field for the seasonUid.
  static const String seasonUidField = 'seasonUid';

  /// The field for the result.
  static const String resultField = 'result';

  /// The field for the attendance.
  static const String attendanceField = 'attendance';

  /// The field for the attendance value.
  static const String attendanceValueField = 'value';

  /// The field for the teamUid.
  static const String teamUidField = 'teamUid';

  /// The field for the oppponentUid
  static const String opponentUidField = 'opponentUid';

  /// The field for the sharedDataUid
  static const String sharedDataUidField = 'sharedDataUid';

  /// The field for the leagueOpponentUid.
  static const String leagueOpponentUidField = 'leagueOpponentUid';

  /// The field for the game shared data.
  static const String gameSharedDataField = 'sharedData';

  /// The field for the opponents.
  static const String opponentField = 'opponents';

  /// The field for the players.
  static const String playersField = 'players';

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameBuilder b) => b
    ..trackAttendance = true
    ..opponentUid = ''
    ..result.currentPeriod = GamePeriod.notStarted.toBuilder()
    ..gameTime = Duration()
    ..playerSummary = GamePlayerSummaryBuilder()
    ..opponentSummary = GamePlayerSummaryBuilder();

  /// Serialize the game to a map.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(Game.serializer, this);
  }

  /// Deserialize the game from a map.
  static Game fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(Game.serializer, jsonData);
  }

  /// The serializer to use.
  static Serializer<Game> get serializer => _$gameSerializer;

  @override
  String toString() {
    return 'Game{uid: $uid, '
        'arriveTime: $tzArriveTime, '
        'notes: $notes, opponentUid: $opponentUid, seasonUid: $seasonUid, '
        'teamUid: $teamUid, uniform: $uniform, seriesId: $seriesId, '
        'result: $result, attendance: $attendance, sharedData: $sharedData}';
  }
}
