import 'common.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { Game, Practice, Event }
enum GameResult { Win, Loss, Tie, Unknown, InProgress }
enum Attendance { Yes, No, Maybe }
enum GameInProgress {
  NotStarted,
  First,
  Second,
  Third,
  Fourth,
  Fifth,
  Sixth,
  Seventh,
  Eighth,
  Nineth,
  Tenth,
  Half,
  Final
}

class GameResultDetails {
  num ptsFor;
  num ptsAgainst;
  GameResult result;
  GameInProgress inProgress;

  GameResultDetails() {
    ptsAgainst = 0;
    ptsFor = 0;
    result = GameResult.Unknown;
    inProgress = GameInProgress.NotStarted;
  }

  GameResultDetails.copy(GameResultDetails copy) {
    ptsAgainst = copy.ptsAgainst;
    ptsFor = copy.ptsFor;
    result = copy.result;
    inProgress = copy.inProgress;
  }

  static const String _PTS_FOR = 'ptsFor';
  static const String _PTS_AGAINST = 'ptsAgainst';
  static const String _RESULT = 'result';
  static const String _INPROGRESS = 'inProgress';

  void fromJSON(Map<String, dynamic> data) {
    ptsFor = getNum(data[_PTS_FOR]);
    ptsAgainst = getNum(data[_PTS_AGAINST]);
    if (data[_INPROGRESS] == null) {
      inProgress = GameInProgress.NotStarted;
    } else {
      String str = data[_INPROGRESS];
      if (!str.startsWith('GameInProgress')) {
        inProgress = GameInProgress.NotStarted;
      } else {
        inProgress = GameInProgress.values
            .firstWhere((e) => e.toString() == data[_INPROGRESS]);
      }
    }
    result = GameResult.values.firstWhere((e) => e.toString() == data[_RESULT]);
    if (result == null) {
      result = GameResult.Unknown;
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_PTS_FOR] = ptsFor;
    ret[_PTS_AGAINST] = ptsAgainst;
    ret[_RESULT] = result.toString();
    ret[_INPROGRESS] = inProgress.toString();
    return ret;
  }
}

class GamePlace {
  String name;
  String placeId;
  String address;
  String notes;
  num latitude;
  num longitude;

  GamePlace() {
    latitude = 0;
    longitude = 0;
  }

  GamePlace.copy(GamePlace copy) {
    name = copy.name;
    placeId = copy.placeId;
    address = copy.address;
    notes = copy.notes;
    latitude = copy.latitude;
    longitude = copy.longitude;
  }

  static const String _PLACEID = 'placeId';
  static const String _ADDRESS = 'address';
  static const String _LONGITUDE = 'longitude';
  static const String _LATITUDE = 'latitude';

  void fromJSON(Map<String, dynamic> data) {
    name = getString(data[NAME]);
    placeId = getString(data[_PLACEID]);
    address = getString(data[_ADDRESS]);
    notes = getString(data[NOTES]);
    longitude = getNum(data[_LONGITUDE]);
    latitude = getNum(data[_LATITUDE]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_PLACEID] = placeId;
    ret[_ADDRESS] = address;
    ret[NOTES] = notes;
    ret[_LATITUDE] = latitude;
    ret[_LONGITUDE] = longitude;
    return ret;
  }
}

class Game {
  String uid;
  num time;
  String _timezone;
  num arriveTime;
  num endTime;
  String notes;
  String opponentUid;
  String seasonUid;
  String teamUid;
  String uniform;
  String seriesId;
  EventType type;
  bool homegame;
  GameResultDetails result;
  GamePlace place;
  Map<String, Attendance> attendance;
  Location _location;
  bool trackAttendance;

  Game() {
    homegame = false;
    attendance = new Map<String, Attendance>();
    trackAttendance = true;
  }

  Game.copy(Game copy) {
    uid = copy.uid;
    _timezone = copy.timezone;
    arriveTime = copy.arriveTime;
    endTime = copy.endTime;
    notes = copy.notes;
    opponentUid = copy.opponentUid;
    seasonUid = copy.seasonUid;
    teamUid = copy.teamUid;
    uniform = copy.uniform;
    type = copy.type;
    homegame = copy.homegame;
    seriesId = copy.seriesId;
    result = new GameResultDetails.copy(copy.result);
    place = new GamePlace.copy(copy.place);
    attendance = new Map<String, Attendance>.from(copy.attendance);
    trackAttendance = copy.trackAttendance;
  }

  Game.newGame(this.type) {
    time = new DateTime.now().millisecondsSinceEpoch;
    arriveTime = arriveTime = time;
    endTime = time;
    timezone = local.toString();
    result = new GameResultDetails();
    place = new GamePlace();
    attendance = new Map<String, Attendance>();
    trackAttendance = true;
  }

  void set timezone(String value) {
    _timezone = value;
    _location = null;
  }

  String get timezone {
    return _timezone;
  }

  TZDateTime get tzTime {
    if (_location == null) {
      _location = getLocation(this.timezone);
    }
    return new TZDateTime.fromMillisecondsSinceEpoch(_location, time);
  }

  TZDateTime get tzArriveTime {
    if (_location == null) {
      _location = getLocation(this.timezone);
    }
    return new TZDateTime.fromMillisecondsSinceEpoch(_location, arriveTime);
  }

  TZDateTime get tzEndTime {
    if (_location == null) {
      _location = getLocation(this.timezone);
    }
    return new TZDateTime.fromMillisecondsSinceEpoch(_location, endTime);
  }

  static const String _TIMEZONE = 'timezone';
  static const String _TIME = 'time';
  static const String _ENDTIME = 'endTime';
  static const String _OPPONENTUID = 'opponentUid';
  static const String _SEASONUID = 'seasonUid';
  static const String _UNIFORM = 'uniform';
  static const String _HOMEGAME = 'homegame';
  static const String _TYPE = 'type';
  static const String _RESULT = 'result';
  static const String _PLACE = 'place';
  static const String _ATTENDANCE = 'attendance';
  static const String _ATTENDANCEVALUE = 'value';
  static const String TEAMUID = 'teamUid';
  static const String _SERIESID = 'seriesId';
  static const String _TRACKATTENDANCE = 'trackAttendance';

  void fromJSON(String gameUid, Map<String, dynamic> data) {
    uid = gameUid;
    timezone = getString(data[_TIMEZONE]);
    time = getNum(data[_TIME]);
    arriveTime = getNum(data[ARRIVEEARLY]);
    if (arriveTime == 0) {
      arriveTime = time;
    }
    endTime = getNum(data[_ENDTIME]);
    if (endTime == 0) {
      endTime = time;
    }
    notes = getString(data[NOTES]);
    opponentUid = getString(data[_OPPONENTUID]);
    seasonUid = getString(data[_SEASONUID]);
    uniform = getString(data[_UNIFORM]);
    homegame = getBool(data[_HOMEGAME]);
    teamUid = getString(data[TEAMUID]);
    seriesId = getString(data[_SERIESID]);
    trackAttendance =
        data[_TRACKATTENDANCE] == null || getBool(data[_TRACKATTENDANCE]);
    type = EventType.values.firstWhere((e) => e.toString() == data[_TYPE]);
    GameResultDetails details = new GameResultDetails();
    details.fromJSON(data[_RESULT]);
    result = details;
    GamePlace place = new GamePlace();
    place.fromJSON(data[_PLACE]);
    this.place = place;

    print('Update Game $uid');
    // Work out attendance.
    Map<String, Attendance> newAttendanceData = new Map<String, Attendance>();
    Map<String, dynamic> attendanceData = data[_ATTENDANCE];
    if (attendanceData != null) {
      attendanceData.forEach((String key, dynamic data) {
        newAttendanceData[key] = Attendance.values
            .firstWhere((e) => e.toString() == data[_ATTENDANCEVALUE]);
      });
    }
    attendance = newAttendanceData;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_TYPE] = type.toString();
    ret[_TIMEZONE] = timezone;
    ret[_TIME] = time;
    ret[ARRIVEEARLY] = arriveTime;
    ret[_ENDTIME] = endTime;
    ret[NOTES] = notes;
    ret[_OPPONENTUID] = opponentUid;
    ret[_SEASONUID] = seasonUid;
    ret[_UNIFORM] = uniform;
    ret[_HOMEGAME] = homegame;
    ret[_TYPE] = type.toString();
    ret[_RESULT] = result.toJSON();
    ret[_PLACE] = place.toJSON();
    ret[TEAMUID] = teamUid;
    ret[_SERIESID] = seriesId;
    ret[_TRACKATTENDANCE] = trackAttendance;
    Map<String, dynamic> attendanceData = new Map<String, dynamic>();
    attendance.forEach((String key, Attendance value) {
      Map<String, dynamic> attendanceInner = new Map<String, dynamic>();
      attendanceInner[_ATTENDANCEVALUE] = value.toString();
      attendanceData[key] = attendanceInner;
    });
    ret[_ATTENDANCE] = attendanceData;

    return ret;
  }

  void close() {}

  Future<void> updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(GAMES_COLLECTION);
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON());
      this.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(uid).updateData(toJSON());
    }
  }

  Future<void> updateFirestoreAttendence(
      String playerUid, Attendance attend) async {
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(uid);

    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_ATTENDANCE + "." + playerUid + "." + _ATTENDANCEVALUE] =
        attend.toString();
    await ref.updateData(data);
  }

  Future<void> updateFirestoreGameResult(GameResultDetails result) async {
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(uid);

    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_RESULT] = result.toJSON();
    await ref.updateData(data);
  }
}
