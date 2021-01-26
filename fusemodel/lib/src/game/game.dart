import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import '../serializer.dart';
import 'gameperiod.dart';
import 'gameplayersummary.dart';
import 'gameresult.dart';
import 'gamesharedata.dart';
import 'gamesummary.dart';

part 'game.g.dart';

///
/// Tracking the attendance for the game.
///
class Attendance extends EnumClass {
  static Serializer<Attendance> get serializer => _$attendanceSerializer;

  static const Attendance Yes = _$Yes;
  static const Attendance No = _$No;
  static const Attendance Maybe = _$Maybe;

  const Attendance._(String name) : super(name);

  static BuiltSet<Attendance> get values => _$AttendanceValues;

  static Attendance valueOf(String name) => _$AttendanceValueOf(name);
}

///
/// This is the game details and it is kept in a team specific format, so that
/// the view of the same game for different teams will look different.
///
abstract class Game implements Built<Game, GameBuilder> {
  GamePeriod get currentPeriod;
  String get uid;
  @BuiltValueField(wireName: SHAREDDATAUID)
  String get sharedDataUid;
  num get arrivalTime;
  String get notes;
  @BuiltValueField(wireName: OPPONENTUID)
  String get opponentUid;
  String get seasonUid;
  @BuiltValueField(wireName: TEAMUID)
  String get teamUid;
  String get uniform;
  @nullable
  String get seriesId;
  @BuiltValueField(wireName: RESULT)
  GameResultDetails get result;
  BuiltMap<String, Attendance> get attendance;
  bool get trackAttendance;
  GameSharedData get sharedData;
  @nullable
  String get leagueOpponentUid;

  /// Summary for this specific player.
  BuiltMap<String, GamePlayerSummary> get players;

  /// Summary for this specific opponent.
  BuiltMap<String, GamePlayerSummary> get opponents;

  /// Summary for the overall game (this is only pts for vs against).
  GameSummary get summary;

  /// Total summary for the game for this players.
  GamePlayerSummary get playerSummaery;

  /// Total summary for the game for the opponents.
  GamePlayerSummary get opponentSummary;

  /// Tracks when this game is running from.  This is used when the
  /// game starts to track the current position in the game.
  @nullable
  DateTime get runningFrom;

  @memoized
  BuiltList<String> get allTeamUids {
    if (opponentUid.isNotEmpty) {
      return BuiltList.of([teamUid, opponentUid]);
    }
    return BuiltList.of([
      teamUid,
    ]);
  }

  Game._();
  factory Game([updates(GameBuilder b)]) = _$Game;

  bool get homegame => sharedData.officialResult.homeTeamLeagueUid == teamUid;

  TZDateTime get tzArriveTime => new TZDateTime.fromMillisecondsSinceEpoch(
      sharedData.location, arrivalTime);

  static const String SEASONUID = 'seasonUid';
  static const String RESULT = 'result';
  static const String ATTENDANCE = 'attendance';
  static const String ATTENDANCEVALUE = 'value';
  static const String TEAMUID = 'teamUid';
  static const String OPPONENTUID = 'opponentUid';
  static const String SHAREDDATAUID = 'sharedDataUid';
  static const String LEAGUEOPPONENTUID = 'leagueOpponentUid';
  static const String GAMESHAREDDATA = 'sharedData';

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameBuilder b) => b
    ..trackAttendance = true
    ..opponentUid = ""
    ..currentPeriod = GamePeriod.notStarted.toBuilder();

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Game.serializer, this);
  }

  static Game fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(Game.serializer, jsonData);
  }

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
