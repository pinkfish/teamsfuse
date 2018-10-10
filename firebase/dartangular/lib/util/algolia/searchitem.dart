enum MatchLevel { none, full, unknown }

class ResultPiece {
  final String fieldName;
  final String value;
  final MatchLevel matchLevel;
  ResultPiece(this.fieldName, Map<String, dynamic> data)
      : value = data['value'] as String,
        matchLevel = MatchLevel.values.firstWhere(
            (MatchLevel l) =>
                l.toString() == "MatchLevel." + (data['matchLevel'] as String),
            orElse: () => MatchLevel.unknown);

  @override
  String toString() {
    return 'ResultPiece{fieldName: $fieldName, '
        'value: $value, '
        'matchLevel: $matchLevel}';
  }
}

class HighlightResult {
  final Map<String, ResultPiece> result;

  HighlightResult(Map<String, dynamic> data)
      : result = (data as Map<String, dynamic>).map(
            (String fieldName, dynamic data) => MapEntry(fieldName,
                ResultPiece(fieldName, data as Map<String, dynamic>)));

  @override
  String toString() {
    return 'HighlightResult{result: $result}';
  }
}

class RankingInfo {
  final int nbTypos;
  final int firstMatchedWord;
  final int proximityDistance;
  final int userScore;
  final int geoDistance;
  final int geoPrecision;
  final int nbExactWords;

  RankingInfo(Map<String, dynamic> data)
      : nbTypos = data['nbTypes'] as int ?? 0,
        firstMatchedWord = data['firstMatchedWord'] as int ?? 0,
        proximityDistance = data['proximityDistance'] as int ?? 0,
        userScore = data['userScore'] as int ?? 0,
        geoDistance = data['geoDistance'] as int ?? 0,
        geoPrecision = data['geoPrecision'] as int ?? 0,
        nbExactWords = data['nbExactWords'] as int ?? 0;

  @override
  String toString() {
    return 'RankingInfo{nbTypos: $nbTypos, '
        'firstMatchedWord: $firstMatchedWord, '
        'proximityDistance: $proximityDistance, '
        'userScore: $userScore, '
        'geoDistance: $geoDistance, '
        'geoPrecision: $geoPrecision, '
        'nbExactWords: $nbExactWords}';
  }
}

class SearchItem {
  // This is the data associated with this entry.
  final Map<String, dynamic> data;
  final RankingInfo rankingInfo;
  final HighlightResult highlightResult;

  SearchItem(Map<String, dynamic> inData)
      : data = Map.unmodifiable(Map<String, dynamic>.fromIterable(
            inData.keys.where((String str) => str[0] != '_'),
            key: (dynamic it) => it as String,
            value: (dynamic it) => inData[it])),
        rankingInfo =
            new RankingInfo(inData['_rankingInfo'] as Map<String, dynamic>),
        highlightResult = new HighlightResult(
            inData['_highlightResult'] as Map<String, dynamic>);

  @override
  String toString() {
    return 'SearchItem{data: $data, rankingInfo: $rankingInfo, '
        'highlightResult: $highlightResult}';
  }
}
