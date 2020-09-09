import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import '../serializer.dart';
import 'gameresult.dart';
import 'gamesharedata.dart';

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
  String get uid;
  String get sharedDataUid;
  num get arriveTime;
  String get notes;
  BuiltList<String> get opponentUids;
  String get seasonUid;
  String get teamUid;
  BuiltList<String> get allTeamUids;
  String get uniform;
  String get seriesId;
  GameResultDetails get result;
  BuiltMap<String, Attendance> get attendance;
  bool get trackAttendance;
  GameSharedData get sharedData;
  @nullable
  String get leagueOpponentUid;

  Game._();
  factory Game([updates(GameBuilder b)]) = _$Game;

  bool get homegame => sharedData.officialResults.homeTeamLeagueUid == teamUid;

  TZDateTime get tzArriveTime => new TZDateTime.fromMillisecondsSinceEpoch(
      sharedData.location, arriveTime);

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
  static void _initializeBuilder(GameBuilder b) => b..trackAttendance = true;

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Game.serializer, this);
  }

  static Game fromMap(
      Map<String, dynamic> jsonData, GameSharedData sharedData) {
    return serializers
        .deserializeWith(Game.serializer, jsonData)
        .rebuild((b) => b..sharedData = sharedData.toBuilder());
  }

  static Serializer<Game> get serializer => _$gameSerializer;

  @override
  String toString() {
    return 'Game{uid: $uid, '
        'arriveTime: $tzArriveTime, '
        'notes: $notes, opponentUids: $opponentUids, seasonUid: $seasonUid, '
        'teamUid: $teamUid, uniform: $uniform, seriesId: $seriesId, '
        'result: $result, attendance: $attendance, sharedData: $sharedData}';
  }
}
