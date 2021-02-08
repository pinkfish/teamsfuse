import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';

part 'gameplace.g.dart';

///
/// The place the game is held at.
///
abstract class GamePlace implements Built<GamePlace, GamePlaceBuilder> {
  String get name;
  String get placeId;
  String get address;
  String get notes;
  @BuiltValueField(wireName: 'lat')
  num get latitude;
  @BuiltValueField(wireName: 'long')
  num get longitude;
  bool get unknown;

  GamePlace._();
  factory GamePlace([updates(GamePlaceBuilder b)]) = _$GamePlace;

  static void _initializeBuilder(GamePlaceBuilder b) => b
    ..name = ""
    ..placeId = ""
    ..address = ""
    ..notes = ""..unknown=true..latitude=0..longitude=0;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(GamePlace.serializer, this);
  }

  static GamePlace fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(GamePlace.serializer, jsonData);
  }

  static Serializer<GamePlace> get serializer => _$gamePlaceSerializer;
}
