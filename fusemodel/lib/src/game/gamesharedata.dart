import 'package:built_value/built_value.dart';
import 'package:timezone/timezone.dart';

import '../common.dart';
import 'gameofficialresults.dart';

part 'gamesharedata.g.dart';

enum EventType { Game, Practice, Event }

abstract class GamePlace implements Built<GamePlace, GamePlaceBuilder> {
  String get name;
  String get placeId;
  String get address;
  String get notes;
  num get latitude;
  num get longitude;
  bool get unknown;

  GamePlace._();
  factory GamePlace([updates(GamePlaceBuilder b)]) = _$GamePlace;

  static const String _PLACEID = 'placeId';
  static const String _ADDRESS = 'address';
  static const String _LONGITUDE = 'long';
  static const String _LATITUDE = 'lat';
  static const String _UNKNOWN = 'unknown';

  static GamePlaceBuilder fromJSON(Map<dynamic, dynamic> data) {
    return GamePlaceBuilder()
      ..name = getString(data[NAME])
      ..placeId = getString(data[_PLACEID])
      ..address = getString(data[_ADDRESS])
      ..notes = getString(data[NOTES])
      ..longitude = getNum(data[_LONGITUDE])
      ..latitude = getNum(data[_LATITUDE])
      ..unknown = getBool(data[_UNKNOWN]);
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
}

///
/// In the case of league games, this is the bit that is shared across all
/// the games.
///
abstract class GameSharedData
    implements Built<GameSharedData, GameSharedDataBuilder> {
  // This is only valid in a special event.
  String get name;
  String get uid;
  num get time;
  String get timezone;
  num get endTime;
  EventType get type;
  GamePlace get place;
  GameOfficialResults get officialResults;

  /// The league associated with this game, null if there is none.
  @nullable
  String get leagueUid;

  /// The divison in the league assocoiated with this game, null if there is none.
  @nullable
  String get leagueDivisionUid;

  GameSharedData._();
  factory GameSharedData([updates(GameSharedDataBuilder b)]) = _$GameSharedData;

  static GameSharedDataBuilder fromJSON(
      String uid, Map<dynamic, dynamic> data) {
    assert(uid != null);
    GameSharedDataBuilder builder = GameSharedDataBuilder()
      ..uid = uid
      ..time = getNum(data[_TIME])
      ..endTime = getNum(data[_ENDTIME])
      ..timezone = getString(data[_TIMEZONE])
      ..type = EventType.values.firstWhere((e) => e.toString() == data[TYPE],
          orElse: () => EventType.Game)
      ..place = GamePlace.fromJSON(data[_PLACE] as Map<dynamic, dynamic>)
      ..name = getString(data[NAME])
      ..leagueUid = data[_LEAGUEUID]
      ..leagueDivisionUid = data[LEAGUEDIVISIONUID];
    if (builder.endTime == 0) {
      builder.endTime = builder.time;
    }

    if (data.containsKey(OFFICIALRESULT)) {
      builder.officialResults =
          GameOfficialResults.fromJSON(data[OFFICIALRESULT]);
    } else {
      builder.officialResults = GameOfficialResultsBuilder()
        ..result = OfficialResult.NotStarted;
    }

    return builder;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = <String, dynamic>{};
    data[_TIME] = time;
    data[_ENDTIME] = endTime;
    data[_PLACE] = place.toJSON();
    data[TYPE] = type.toString();
    data[NAME] = name;
    data[_TIMEZONE] = timezone;
    data[_LEAGUEUID] = leagueUid;
    data[LEAGUEDIVISIONUID] = leagueDivisionUid;
    if (officialResults != null) {
      data[OFFICIALRESULT] = officialResults.toJSON();
    }
    return data;
  }

  Location get location {
    return getLocation(this.timezone);
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
}
