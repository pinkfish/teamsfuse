import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializer.dart';

part 'winrecord.g.dart';

///
/// The win record for the team.  Built automatically.
///
abstract class WinRecord implements Built<WinRecord, WinRecordBuilder> {
  /// How many wins.
  num get win;

  /// How many losses
  num get loss;

  /// How many ties.
  num get tie;

  WinRecord._();

  /// Factory to create the win record.
  factory WinRecord([updates(WinRecordBuilder b)]) = _$WinRecord;

  /// Makes a nice map of the class.
  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(WinRecord.serializer, this);
  }

  /// Pulls json data in and makes a nice WinRecord from the data.
  static WinRecord fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(WinRecord.serializer, jsonData);
  }

  /// The serializer for the class.
  static Serializer<WinRecord> get serializer => _$winRecordSerializer;
}
