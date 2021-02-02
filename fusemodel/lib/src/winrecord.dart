import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializer.dart';

part 'winrecord.g.dart';

abstract class WinRecord implements Built<WinRecord, WinRecordBuilder> {
  num get win;
  num get loss;
  num get tie;

  WinRecord._();
  factory WinRecord([updates(WinRecordBuilder b)]) = _$WinRecord;

  Map<String, dynamic> toMap() {
    return dataSerializers.serializeWith(WinRecord.serializer, this);
  }

  static WinRecord fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(WinRecord.serializer, jsonData);
  }

  static Serializer<WinRecord> get serializer => _$winRecordSerializer;
}
