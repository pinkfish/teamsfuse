import '../common.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import '../userdatabasedata.dart';
import 'gameofficialresults.dart';

enum EventType { Game, Practice, Event }

class GamePlace {
  String name;
  String placeId;
  String address;
  String notes;
  num latitude;
  num longitude;
  bool unknown;

  GamePlace(
      {this.name,
        this.placeId = '',
        this.address = '',
        this.notes = '',
        this.unknown = true,
        this.latitude = 0,
        this.longitude = 0});

  GamePlace.copy(GamePlace copy) {
    name = copy.name;
    placeId = copy.placeId;
    address = copy.address;
    notes = copy.notes;
    latitude = copy.latitude;
    longitude = copy.longitude;
    unknown = copy.unknown;
  }

  static const String _PLACEID = 'placeId';
  static const String _ADDRESS = 'address';
  static const String _LONGITUDE = 'long';
  static const String _LATITUDE = 'lat';
  static const String _UNKNOWN = 'unknown';

  GamePlace.fromJSON(Map<dynamic, dynamic> data) {
    name = getString(data[NAME]);
    placeId = getString(data[_PLACEID]);
    address = getString(data[_ADDRESS]);
    notes = getString(data[NOTES]);
    longitude = getNum(data[_LONGITUDE]);
    latitude = getNum(data[_LATITUDE]);
    unknown = getBool(data[_UNKNOWN]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_PLACEID] = placeId;
    ret[_ADDRESS] = address;
    ret[NOTES] = notes;
    ret[_LATITUDE] = latitude;
    ret[_LONGITUDE] = longitude;
    ret[_UNKNOWN] = unknown;
    return ret;
  }

  @override
  String toString() {
    return 'GamePlace{name: $name, placeId: $placeId, address: $address, '
        'notes: $notes, latitude: $latitude, longitude: $longitude, '
        'unknown: $unknown}';
  }
}

///
/// In the case of league games, this is the bit that is shared across all
/// the games.
///
class GameSharedData {
  // This is only valid in a special event.
  String name;
  String uid;
  num time;
  String _timezone;
  num endTime;
  EventType type;
  GamePlace place;
  GameOfficialResults officialResults;
  String leagueUid;
  String leagueDivisionUid;

  // Derived data
  Location _location;

  GameSharedData(
      String homeTeamUid,
      String awayTeamUid, {
        this.name = "",
        this.uid,
        num time,
        num endTime,
        GamePlace place,
        GameOfficialResults officalResults,
        String timezone,
        this.type,
        this.leagueUid,
        this.leagueDivisionUid,
      })  : this.place = place ?? new GamePlace(),
        this.officialResults =
            officalResults ?? new GameOfficialResults(homeTeamUid, awayTeamUid),
        this.time = time ?? new DateTime.now().millisecondsSinceEpoch,
        this.endTime = endTime ?? new DateTime.now().millisecondsSinceEpoch,
        _timezone = timezone ?? local.toString();

  GameSharedData.copy(GameSharedData copy) {
    uid = copy.uid;
    time = copy.time;
    _timezone = copy._timezone;
    _location = copy._location;
    leagueUid = copy.leagueUid;
    endTime = copy.endTime;
    type = copy.type;
    place = new GamePlace.copy(copy.place);
    name = copy.name;
    leagueDivisionUid = copy.leagueDivisionUid;
    officialResults = new GameOfficialResults.copy(copy.officialResults);
  }

  GameSharedData.fromJSON(String uid, Map<String, dynamic> data) {
    this.uid = uid;
    time = getNum(data[_TIME]);
    endTime = getNum(data[_ENDTIME]);
    _timezone = getString(data[_TIMEZONE]);
    if (endTime == 0) {
      endTime = time;
    }

    type = EventType.values.firstWhere((e) => e.toString() == data[TYPE],
        orElse: () => EventType.Game);
    GamePlace place =
    new GamePlace.fromJSON(data[_PLACE] as Map<dynamic, dynamic>);
    this.place = place;
    name = getString(data[NAME]);
    if (data.containsKey(OFFICIALRESULT)) {
      officialResults = new GameOfficialResults.fromJSON(data[OFFICIALRESULT]);
    } else {
      officialResults = new GameOfficialResults(null, null);
    }

    leagueUid = data[_LEAGUEUID];
    leagueDivisionUid = data[LEAGUEDIVISIONUID];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};
    data[_TIME] = time;
    data[_ENDTIME] = endTime;
    data[_PLACE] = place.toJSON();
    data[TYPE] = type.toString();
    data[NAME] = name;
    data[_TIMEZONE] = _timezone;
    data[_LEAGUEUID] = leagueUid;
    data[LEAGUEDIVISIONUID] = leagueDivisionUid;
    if (officialResults != null) {
      data[OFFICIALRESULT] = officialResults.toJSON();
    }
    return data;
  }

  set timezone(String value) {
    _timezone = value;
    _location = null;
  }

  String get timezone {
    return _timezone;
  }

  Location get location {
    if (_location == null) {
      _location = getLocation(this.timezone);
    }
    return _location;
  }

  void updateFrom(GameSharedData copy) {
    uid = copy.uid;
    time = copy.time;
    _timezone = copy._timezone;
    _location = copy._location;
    endTime = copy.endTime;
    type = copy.type;
    place = new GamePlace.copy(copy.place);
    name = copy.name;
    leagueDivisionUid = copy.leagueDivisionUid;
    leagueUid = copy.leagueUid;
    officialResults = new GameOfficialResults.copy(copy.officialResults);
  }

  TZDateTime get tzTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, time);
  TZDateTime get tzEndTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, endTime);

  static const String OFFICIALRESULT = 'officialResult';
  static const String _TIME = 'time';
  static const String _ENDTIME = 'endTime';
  static const String TYPE = 'type';
  static const String _PLACE = 'place';
  static const String _TIMEZONE = 'timezone';
  static const String _LEAGUEUID = 'leagueUid';
  static const String LEAGUEDIVISIONUID = 'leagueDivisonUid';

  Future<void> deleteCompletelyFromFirestore() {
    return UserDatabaseData.instance.updateModel
        .deleteFirestoreSharedGame(this);
  }

  Future<String> updateFirestore() {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreSharedGame(this);
  }

  Future<void> updateFirestoreResult(GameOfficialResults result) {
    // TODO: Do something in here :)
    UserDatabaseData.instance.updateModel
        .updateFirestoreOfficalGameResult(this, result);
  }

  @override
  String toString() {
    return 'GameSharedData{uid: $uid, time: $tzTime, _timezone: $_timezone, '
        'endTime: $tzEndTime, leagueUid: $leagueUid, '
        'leagueDivisionUid: $leagueDivisionUid, '
        'name: $name, type: $type, officalResults: $officialResults, '
        'officalResult: $officialResults, place: $place}';
  }
}
