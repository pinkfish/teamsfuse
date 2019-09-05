import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:timezone/timezone.dart';

import '../common.dart';
import 'gameresult.dart';
import 'gamesharedata.dart';

part 'game.g.dart';

enum Attendance { Yes, No, Maybe }

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

  static GameBuilder fromJSON(String teamContext, String gameUid,
      Map<String, dynamic> data, GameSharedData inputSharedData) {
    assert(inputSharedData != null);

    GameBuilder builder = GameBuilder()
      ..leagueOpponentUid = data[LEAGUEOPPONENTUID]
      ..uid = gameUid
      ..sharedDataUid = getString(data[SHAREDDATAUID])
      ..arriveTime = data[ARRIVALTIME] == null || getNum(data[ARRIVALTIME]) == 0
          ? inputSharedData.time
          : getNum(data[ARRIVALTIME])
      ..sharedData = inputSharedData.toBuilder()
      ..seasonUid = getString(data[SEASONUID])
      ..uniform = getString(data[_UNIFORM])
      ..teamUid = getString(data[TEAMUID])
      ..opponentUids = BuiltList.of([getString(data[OPPONENTUID])]).toBuilder()
      ..arriveTime = getNum(data[ARRIVALTIME])
      ..notes = getString(data[NOTES])
      ..result =
          GameResultDetails.fromJSON(data[RESULT] as Map<dynamic, dynamic>)
      ..trackAttendance =
          data[_TRACKATTENDANCE] == null || getBool(data[_TRACKATTENDANCE])
      ..seriesId = getString(data[_SERIESID]);
    builder.allTeamUids.add(builder.teamUid);
    builder.allTeamUids.add(builder.opponentUids[0]);

    // Work out attendance for our team only.
    Map<String, Attendance> newAttendanceData = new Map<String, Attendance>();
    Map<dynamic, dynamic> attendanceData =
        data[ATTENDANCE] as Map<dynamic, dynamic>;
    if (attendanceData != null) {
      for (String key in attendanceData.keys) {
        if (attendanceData[key] is Map &&
            attendanceData[key].containsKey(ATTENDANCEVALUE)) {
          if (attendanceData[key][ATTENDANCEVALUE] is String &&
              attendanceData[key][ATTENDANCEVALUE].startsWith("Attendance")) {
            builder.attendance[key.toString()] = Attendance.values.firstWhere(
                (e) => e.toString() == attendanceData[key][ATTENDANCEVALUE]);
          }
        }
      }
    }
    return builder;
  }

  bool get homegame => sharedData.officialResults.homeTeamLeagueUid == teamUid;
  /*
  set homegame(bool val) => val
      ? sharedData.leagueUid != null
          ? sharedData.officialResults.homeTeamLeagueUid = teamUid
          : null
      : sharedData.leagueUid != null
          ? sharedData.officialResults.homeTeamLeagueUid =
              opponentUids.length > 0 ? opponentUids[0] : ""
          : null;
          */

  TZDateTime get tzArriveTime => new TZDateTime.fromMillisecondsSinceEpoch(
      sharedData.location, arriveTime);

  static const String SEASONUID = 'seasonUid';
  static const String _UNIFORM = 'uniform';
  static const String RESULT = 'result';
  static const String ATTENDANCE = 'attendance';
  static const String ATTENDANCEVALUE = 'value';
  static const String TEAMUID = 'teamUid';
  static const String _SERIESID = 'seriesId';
  static const String _TRACKATTENDANCE = 'trackAttendance';
  static const String OPPONENTUID = 'opponentUid';
  static const String SHAREDDATAUID = 'sharedDataUid';
  static const String LEAGUEOPPONENTUID = 'leagueOpponentUid';
  static const String GAMESHAREDDATA = 'sharedData';

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[ARRIVALTIME] = arriveTime;
    ret[NOTES] = notes;
    ret[SEASONUID] = seasonUid;
    ret[_UNIFORM] = uniform;
    ret[LEAGUEOPPONENTUID] = leagueOpponentUid;
    // My teamuid.
    ret[TEAMUID] = teamUid;
    // Set the team specific values.
    ret[NOTES] = notes;
    ret[_TRACKATTENDANCE] = trackAttendance;
    ret[RESULT] = result.toJSON();
    ret[SHAREDDATAUID] = sharedDataUid;
    if (opponentUids.length > 0) {
      ret[OPPONENTUID] = opponentUids[0];
    }

    ret[_SERIESID] = seriesId;
    attendance.forEach((String key, Attendance value) {
      Map<String, dynamic> attendanceInner = new Map<String, dynamic>();
      attendanceInner[ATTENDANCEVALUE] = value.toString();
      // Only update the attendence for our team.
      ret[ATTENDANCE + "." + key] = attendanceInner;
    });

    return ret;
  }

  /*
  void updateLogs(List<GameLog> logs) {
    _gameLogs = logs;
    _updateThisLogGame.add(_gameLogs);
  }

  Future<void> updateFirestore(bool sharedData) {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreGame(this, sharedData);
  }

  Future<void> updateFirestoreAttendence(String playerUid, Attendance attend) {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreGameAttendence(this, playerUid, attend);
  }

  Future<void> updateFirestoreResult(GameResultDetails result) {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreGameResult(this, result);
  }

  Future<void> deleteFromFirestore() {
    return UserDatabaseData.instance.updateModel.deleteFirestoreGame(this);
  }

  Future<String> addGameLog(GameLog log) {
    return UserDatabaseData.instance.updateModel.addFirestoreGameLog(this, log);
  }

  Future<List<GameLog>> loadGameLogs() async {
    if (_gameLogs != null) {
      return _gameLogs;
    }
    GameLogReturnData data =
        UserDatabaseData.instance.updateModel.readGameLogs(this);
    _gameLogSubcription = data.myLogStream;
    List<GameLog> logs = await data.logs;
    _gameLogs = logs;
    _updateThisLogGame.add(_gameLogs);
    return logs;
  }
  */

  @override
  String toString() {
    return 'Game{uid: $uid, '
        'arriveTime: $tzArriveTime, '
        'notes: $notes, opponentUids: $opponentUids, seasonUid: $seasonUid, '
        'teamUid: $teamUid, uniform: $uniform, seriesId: $seriesId, '
        'result: $result, attendance: $attendance, sharedData: $sharedData}';
  }

  /// We are hashed based on the uid.
  //@override
  //int get hashCode => uid.hashCode;

  ///
  /// Equal if the uid is the same.  Compare to string to handle removal from
  /// sets
  ///
  //@override
  //bool operator ==(Object other) =>
  //   other is Game && other.uid == uid || other is String && uid == other;
}
