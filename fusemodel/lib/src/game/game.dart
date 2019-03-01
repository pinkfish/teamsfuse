import '../common.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import '../userdatabasedata.dart';
import 'gamelog.dart';
import 'gameresult.dart';
import 'gamesharedata.dart';

enum Attendance { Yes, No, Maybe }

///
/// This is the game details and it is kept in a team specific format, so that
/// the view of the same game for different teams will look different.
///
class Game {
  String uid;
  String sharedDataUid;
  num arriveTime;
  String notes;
  List<String> opponentUids;
  String seasonUid;
  String teamUid;
  List<String> allTeamUids;
  String uniform;
  String seriesId;
  GameResultDetails result;
  Map<String, Attendance> attendance;
  bool trackAttendance;
  List<GameLog> _gameLogs;
  GameSharedData sharedData;
  final String leagueOpponentUid;

  Stream<UpdateReason> thisGameStream;
  Stream<List<GameLog>> thisGameLogStream;
  StreamSubscription<dynamic> _gameLogSubcription;
  StreamController<UpdateReason> _updateThisGame =
      new StreamController<UpdateReason>();
  StreamController<List<GameLog>> _updateThisLogGame =
      new StreamController<List<GameLog>>();

  Game(String homeTeamUid, String awayTeamUid,
      {this.uid,
      num arriveTime,
      GameSharedData sharedData,
      this.notes = "",
      this.trackAttendance = true,
      this.uniform = "",
      this.seriesId,
      this.leagueOpponentUid,
      GameResultDetails result,
      Map<String, Attendance> attendance})
      : this.sharedData =
            sharedData ?? new GameSharedData(homeTeamUid, awayTeamUid),
        this.result = result ?? new GameResultDetails(),
        this.attendance = attendance ?? <String, Attendance>{},
        this.arriveTime =
            arriveTime ?? new DateTime.now().millisecondsSinceEpoch {
    thisGameStream = _updateThisGame.stream.asBroadcastStream();
    thisGameLogStream = _updateThisLogGame.stream.asBroadcastStream();
  }

  Game.copy(Game copy) : leagueOpponentUid = copy.leagueOpponentUid {
    uid = copy.uid;
    arriveTime = copy.arriveTime;
    notes = copy.notes;
    opponentUids = copy.opponentUids;
    allTeamUids = copy.allTeamUids;
    seasonUid = copy.seasonUid;
    teamUid = copy.teamUid;
    uniform = copy.uniform;
    seriesId = copy.seriesId;
    result = new GameResultDetails.copy(copy.result);
    attendance = new Map<String, Attendance>.from(copy.attendance);
    trackAttendance = copy.trackAttendance;
    if (_gameLogs != null) {
      _gameLogs = new List.from(copy._gameLogs);
    }
    sharedData = new GameSharedData.copy(copy.sharedData);
    thisGameStream = _updateThisGame.stream.asBroadcastStream();
    thisGameLogStream = _updateThisLogGame.stream.asBroadcastStream();
  }

  Game.fromJSON(String teamContext, String gameUid, Map<String, dynamic> data,
      GameSharedData inputSharedData)
      : leagueOpponentUid = data[LEAGUEOPPONENTUID] {
    assert(inputSharedData != null);
    uid = gameUid;
    sharedDataUid = getString(data[SHAREDDATAUID]);
    if (arriveTime == 0) {
      arriveTime = sharedData.time;
    }
    sharedData = inputSharedData;
    seasonUid = getString(data[SEASONUID]);
    uniform = getString(data[_UNIFORM]);
    teamUid = getString(data[TEAMUID]);
    opponentUids = [getString(data[OPPONENTUID])];
    allTeamUids = [teamUid, opponentUids[0]];
    arriveTime = getNum(data[ARRIVALTIME]);
    notes = getString(data[NOTES]);
    GameResultDetails details = new GameResultDetails();
    details.fromJSON(data[RESULT] as Map<dynamic, dynamic>);
    result = details;
    trackAttendance =
        data[_TRACKATTENDANCE] == null || getBool(data[_TRACKATTENDANCE]);
    seriesId = getString(data[_SERIESID]);

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
            newAttendanceData[key.toString()] = Attendance.values.firstWhere(
                (e) => e.toString() == attendanceData[key][ATTENDANCEVALUE]);
          }
        }
      }
    }
    attendance = newAttendanceData;
    thisGameStream = _updateThisGame.stream.asBroadcastStream();
    thisGameLogStream = _updateThisLogGame.stream.asBroadcastStream();
  }

  void updateFrom(Game copy) {
    uid = copy.uid;
    arriveTime = copy.arriveTime;
    notes = copy.notes;
    opponentUids = copy.opponentUids;
    allTeamUids = copy.allTeamUids;
    seasonUid = copy.seasonUid;
    teamUid = copy.teamUid;
    uniform = copy.uniform;
    seriesId = copy.seriesId;
    result = new GameResultDetails.copy(copy.result);
    attendance = new Map<String, Attendance>.from(copy.attendance);
    trackAttendance = copy.trackAttendance;
    if (_gameLogs != null) {
      _gameLogs = new List.from(copy._gameLogs);
    }
  }

  bool get homegame => sharedData.officialResults.homeTeamLeagueUid == teamUid;
  set homegame(bool val) => val
      ? sharedData.leagueUid != null
          ? sharedData.officialResults.homeTeamLeagueUid = teamUid
          : null
      : sharedData.leagueUid != null
          ? sharedData.officialResults.homeTeamLeagueUid =
              opponentUids.length > 0 ? opponentUids[0] : ""
          : null;

  List<GameLog> get logs => _gameLogs ?? [];

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

  void markGameChanged() {
    _updateThisGame?.add(UpdateReason.Update);
  }

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

  void close() {
    _updateThisGame?.close();
    _updateThisGame = null;
    _gameLogs?.clear();
    _updateThisGame = null;
    _gameLogSubcription?.cancel();
    _updateThisLogGame?.close();
    _updateThisLogGame = null;
  }

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

  @override
  String toString() {
    return 'Game{uid: $uid, '
        'arriveTime: $tzArriveTime, '
        'notes: $notes, opponentUids: $opponentUids, seasonUid: $seasonUid, '
        'teamUid: $teamUid, uniform: $uniform, seriesId: $seriesId, '
        'result: $result, attendance: $attendance, sharedData: $sharedData}';
  }

  /// We are hashed based on the uid.
  @override
  int get hashCode => uid.hashCode;

  ///
  /// Equal if the uid is the same.  Compare to string to handle removal from
  /// sets
  ///
  @override
  bool operator ==(Object other) =>
      other is Game && other.uid == uid || other is String && uid == other;
}
