import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'relationship.g.dart';

///
/// The relationship the player has with the users.
///
class Relationship extends EnumClass {
  static Serializer<Relationship> get serializer => _$relationshipSerializer;

  /// If this player is a me player.
  static const Relationship Me = _$Me;

  /// If this player is a parent.
  static const Relationship Parent = _$Parent;

  /// If this player is a guardian
  static const Relationship Guardian = _$Guardian;

  /// If this player-> user connection is a friend.
  static const Relationship Friend = _$Friend;

  const Relationship._(String name) : super(name);

  /// The values associated with the relationship.
  static BuiltSet<Relationship> get values => _$RelationshipValues;

  /// Return the value of the relationship if the string is supplied.
  static Relationship valueOf(String name) => _$RelationshipValueOf(name);
}
