import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'playertype.g.dart';

///
/// The type of the player.
///
class PlayerType extends EnumClass {
  /// The serializer for the player type.
  static Serializer<PlayerType> get serializer => _$playerTypeSerializer;

  /// If this player is a me player.
  static const PlayerType player = _$player;

  /// If this player is a opponent.
  static const PlayerType opponent = _$opponent;

  /// If this player is a guest
  static const PlayerType guest = _$guest;

  const PlayerType._(String name) : super(name);

  /// The values associated with the relationship.
  static BuiltSet<PlayerType> get values => _$PlayerTypeValues;

  /// Return the value of the relationship if the string is supplied.
  static PlayerType valueOf(String name) => _$PlayerTypeValueOf(name);
}
