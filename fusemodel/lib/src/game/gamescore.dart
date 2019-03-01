import '../common.dart';

class GameScore {
  GameScore({this.ptsFor, this.ptsAgainst, this.intermediate = true});
  GameScore.copy(GameScore copy) {
    this.ptsFor = copy.ptsFor;
    this.ptsAgainst = copy.ptsAgainst;
  }

  num ptsFor;
  num ptsAgainst;
  bool intermediate;

  static const String PTS_FOR = 'ptsFor';
  static const String _PTS_AGAINST = 'ptsAgainst';
  static const String _INTERMEDIATE = 'intermediate';

  GameScore.fromJSON(Map<dynamic, dynamic> data) {
    ptsAgainst = getNum(data[_PTS_AGAINST]);
    ptsFor = getNum(data[PTS_FOR]);
    intermediate = getBool(data[_INTERMEDIATE]);
  }

  void toJSON(Map<String, dynamic> data) {
    data[PTS_FOR] = ptsFor;
    data[_PTS_AGAINST] = ptsAgainst;
    data[_INTERMEDIATE] = intermediate;
  }

  String toString() {
    return "GameScore[ ptsFor: $ptsFor, ptsAgainst: $ptsAgainst, intermediate $intermediate]";
  }
}
