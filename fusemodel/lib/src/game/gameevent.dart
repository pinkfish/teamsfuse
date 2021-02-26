import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'gameeventtype.dart';
import 'gamefoultype.dart';
import 'gameperiod.dart';

part 'gameevent.g.dart';

///
/// Events in a game.  This tracks all the things that happen in a game
/// so it can be graphed amongst other things.
///
abstract class GameEvent implements Built<GameEvent, GameEventBuilder> {
  /// The uid of the event
  @nullable
  String get uid;

  /// The timestamp of the event/
  DateTime get timestamp;

  /// The type of the event.
  GameEventType get type;

  /// The points assoociated with the event/
  int get points;

  /// The game uid the event is in.
  String get gameUid;

  /// The player uid that caused the event.
  String get playerUid;

  /// If this event is for an opponent or player.
  bool get opponent;

  /// The period the event is in.
  GamePeriod get period;

  /// The point on the timeline the event occured.
  Duration get eventTimeline;

  /// Where on the court the show was taken from.,
  @nullable
  GameEventLocation get courtLocation;

  /// The player being replaced, if a sub event.
  @nullable
  String get replacementPlayerUid;

  /// The type of the foul.
  @nullable
  GameFoulType get foulType;

  /// The player that did the assist.
  @nullable
  String get assistPlayerUid;

  static void _initializeBuilder(GameEventBuilder b) =>
      b..eventTimeline = Duration(seconds: 0);

  GameEvent._();

  /// Factor to create the event.
  factory GameEvent([updates(GameEventBuilder b)]) = _$GameEvent;

  /// Nice mapping for the event.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GameEvent.serializer, this);
  }

  /// Deserialize the event.
  static GameEvent fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(GameEvent.serializer, jsonData);
  }

  /// The serialized to use for the event.
  static Serializer<GameEvent> get serializer => _$gameEventSerializer;
}

///
/// The x,y location of the shot on the basketball key.
///
abstract class GameEventLocation
    implements Built<GameEventLocation, GameEventLocationBuilder> {
  /// x location on the court.
  double get x;

  /// y location on the court.
  double get y;

  GameEventLocation._();

  /// Factory to make the the location.
  factory GameEventLocation([updates(GameEventLocationBuilder b)]) =
      _$GameEventLocation;

  /// Serialize the map.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GameEventLocation.serializer, this);
  }

  /// Deserialize the map.
  static GameEventLocation fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        GameEventLocation.serializer, jsonData);
  }

  /// The serializer to use for the location.
  static Serializer<GameEventLocation> get serializer =>
      _$gameEventLocationSerializer;
}
