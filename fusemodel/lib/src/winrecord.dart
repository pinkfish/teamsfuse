import 'common.dart';
import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

part 'winrecord.g.dart';

abstract class WinRecord implements Built<WinRecord, WinRecordBuilder> {
  num get win;
  num get loss;
  num get tie;
  WinRecord._();
  factory WinRecord([updates(WinRecordBuilder b)]) = _$WinRecord;

  static const String _WIN = 'win';
  static const String _LOSS = 'loss';
  static const String _TIE = 'tie';

  static WinRecordBuilder fromJSON(Map<dynamic, dynamic> data) {
    WinRecordBuilder builder = WinRecordBuilder();
    builder.win = getNum(data[_WIN]);
    builder.loss = getNum(data[_LOSS]);
    builder.tie = getNum(data[_TIE]);
    return builder;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[_TIE] = tie;
    ret[_LOSS] = loss;
    ret[_WIN] = win;
    return ret;
  }
}
/*
  WinRecord() {
    win = 0;
    loss = 0;
    tie = 0;
  }

  WinRecord.copy(WinRecord copy) {
    win = copy.win;
    loss = copy.loss;
    tie = copy.tie;
  }

  static const String _WIN = 'win';
  static const String _LOSS = 'loss';
  static const String _TIE = 'tie';

  WinRecord.fromJSON(Map<dynamic, dynamic> data) {
    win = getNum(data[_WIN]);
    loss = getNum(data[_LOSS]);
    tie = getNum(data[_TIE]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[_TIE] = tie;
    ret[_LOSS] = loss;
    ret[_WIN] = win;
    return ret;
  }
}
*/
