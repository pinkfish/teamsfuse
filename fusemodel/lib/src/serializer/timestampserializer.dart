import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

///
/// Timestamp wrapper for handling timestamps in firestore.
///
class Timestamp extends DateTime {
  /// Create the timestamp from microsectons.
  Timestamp.fromMicrosecondsSinceEpoch(int microsecondsSinceEpoch)
      : super.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch, isUtc: true);

  /// CReate the timestamp right now.
  Timestamp.now() : super.now();

  /// Create from a datetime object (in utc).
  Timestamp.fromDateTime(DateTime t)
      : super.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch, isUtc: true);

  /// Make sure toUtc() still converts to a timestamp.
  Timestamp toUtc() {
    return Timestamp.fromDateTime(super.toUtc());
  }
}

/// Serializer for [Timestamp].
///
/// An exception will be thrown on attempt to serialize local DateTime
/// instances; you must use UTC.
class TimestampSerializer implements PrimitiveSerializer<Timestamp> {
  final bool structured = false;
  @override
  final Iterable<Type> types = BuiltList<Type>([Timestamp]);
  @override
  final String wireName = 'Timestamp';

  @override
  Object serialize(Serializers serializers, Timestamp dateTime,
      {FullType specifiedType = FullType.unspecified}) {
    print("Serializer $dateTime");
    if (!dateTime.isUtc) {
      throw ArgumentError.value(
          dateTime, 'dateTime', 'Must be in utc for serialization.');
    }

    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    int nanoseconds = (dateTime.microsecondsSinceEpoch % 1000000) * 1000;
    return "Timestamp(seconds=$seconds, nanonseconds=$nanoseconds)";
  }

  @override
  Timestamp deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    print("Deserialize $serialized");
    String bit = serialized.toString();
    bit = bit.replaceAll("Timestamp(", "");
    bit = bit.replaceAll(")", "");
    var parts = bit.split(",");
    int totalTs = 0;
    print("Decode $parts");
    for (var p in parts) {
      p = p.trim();
      print("$p");
      var num = int.parse(p.split("=")[1]);
      if (p.startsWith("seconds")) {
        totalTs += num * 1000000;
      }
      if (p.startsWith("nanoseconds")) {
        totalTs += num ~/ 1000;
      }
    }

    Timestamp ret = Timestamp.fromMicrosecondsSinceEpoch(totalTs);
    return ret;
  }
}
