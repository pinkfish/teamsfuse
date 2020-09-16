import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import '../common.dart';
import '../serializer.dart';
import 'gameofficialresults.dart';

part 'gamesharedata.g.dart';

//  The event type.
class EventType extends EnumClass {
  static Serializer<EventType> get serializer => _$eventTypeSerializer;

  static const EventType Game = _$game;
  static const EventType Practice = _$practice;
  static const EventType Event = _$event;

  const EventType._(String name) : super(name);

  static BuiltSet<EventType> get values => _$EventTypeValues;

  static EventType valueOf(String name) => _$EventTypeValueOf(name);
}

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
  GameOfficialResults get officialResult;

  /// The league associated with this game, null if there is none.
  @nullable
  String get leagueUid;

  /// The divison in the league assocoiated with this game, null if there is none.
  @nullable
  String get leagueDivisionUid;

  GameSharedData._();
  factory GameSharedData([updates(GameSharedDataBuilder b)]) = _$GameSharedData;
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(GameSharedData.serializer, this);
  }

  static GameSharedData fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(GameSharedData.serializer, jsonData);
  }

  static Serializer<GameSharedData> get serializer =>
      _$gameSharedDataSerializer;

  Location get location {
    return getLocation(this.timezone);
  }

  TZDateTime get tzTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, time);
  TZDateTime get tzEndTime =>
      new TZDateTime.fromMillisecondsSinceEpoch(location, endTime);

  static const String OFFICIALRESULT = 'officialResult';
  static const String TYPE = 'type';
  static const String LEAGUEDIVISIONUID = 'leagueDivisonUid';
}
