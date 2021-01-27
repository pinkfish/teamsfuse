import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'relationship.g.dart';

///
/// The relationship the player has with the users.
///
class Relationship extends EnumClass {
  static Serializer<Relationship> get serializer => _$relationshipSerializer;

  static const Relationship Me = _$Me;
  static const Relationship Parent = _$Parent;
  static const Relationship Guardian = _$Guardian;
  static const Relationship Friend = _$Friend;

  const Relationship._(String name) : super(name);

  static BuiltSet<Relationship> get values => _$RelationshipValues;

  static Relationship valueOf(String name) => _$RelationshipValueOf(name);
}
