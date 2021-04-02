import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:timezone/timezone.dart';

import '../serializer.dart';
import 'gameofficialresults.dart';
import 'gameplace.dart';

part 'gamesharedata.g.dart';

///
///  The event type.
///
class EventType extends EnumClass {
  static Serializer<EventType> get serializer => _$eventTypeSerializer;

  /// Game event
  static const EventType Game = _$game;

  /// Practice event
  static const EventType Practice = _$practice;

  /// Any other type of event.
  static const EventType Event = _$event;

  const EventType._(String name) : super(name);

  static BuiltSet<EventType> get values => _$EventTypeValues;

  static EventType valueOf(String name) => _$EventTypeValueOf(name);
}

///
/// In the case of league games, this is the bit that is shared across all
/// the games.
///
abstract class GameSharedData
    implements Built<GameSharedData, GameSharedDataBuilder> {
  ///  Name of the event. This is only valid in a special event.
  String get name;

  /// The uid for the event.
  String get uid;

  /// The time the event starts at.
  DateTime get time;

  /// The timezone the event is in.
  String get timezone;

  /// The end time for the event.
  DateTime get endTime;

  /// The type of the event.
  EventType get type;

  /// The place the event is held at.
  GamePlace get place;

  /// The official results for this game (only in a league/tournament).
  GameOfficialResults get officialResult;

  /// The league associated with this game, null if there is none.
  @nullable
  String get leagueUid;

  /// The division in the league associated with this game, null if there is none.
  @nullable
  String get leagueDivisionUid;

  GameSharedData._();
  factory GameSharedData([Function(GameSharedDataBuilder b) updates]) =
      _$GameSharedData;
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GameSharedData.serializer, this);
  }

  /// Defaults for the state.  Always default to no games loaded.
  static void _initializeBuilder(GameSharedDataBuilder b) => b..name = '';

  static GameSharedData fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(GameSharedData.serializer, jsonData);
  }

  static Serializer<GameSharedData> get serializer =>
      _$gameSharedDataSerializer;

  Location get location {
    return getLocation(timezone);
  }

  TZDateTime get tzTime => TZDateTime.from(time, location);
  TZDateTime get tzEndTime => TZDateTime.from(time, location);

  static const String officialResultField = 'officialResult';
  static const String typeField = 'type';
  static const String leagueDivisionUidField = 'leagueDivisionUid';
}
