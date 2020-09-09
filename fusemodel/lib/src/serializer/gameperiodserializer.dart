import 'package:built_value/serializer.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Deserialize the invite types correctly.
///
class GamePeriodSerializer implements PrimitiveSerializer<GamePeriod> {
  @override
  GamePeriod deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized is String) {
      return GamePeriod.fromIndex(serialized);
    }
    throw ArgumentError('Unknow GamePeriod type');
  }

  @override
  Object serialize(Serializers serializers, GamePeriod object,
      {FullType specifiedType = FullType.unspecified}) {
    return object.toString();
  }

  @override
  Iterable<Type> get types => [GamePeriod];

  @override
  String get wireName => "GamePeriod";
}
