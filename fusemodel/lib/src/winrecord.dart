import 'common.dart';

class WinRecord {
  num win;
  num loss;
  num tie;

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
