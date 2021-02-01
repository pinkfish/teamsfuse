class SearchRequest {
  final String index;
  final String query;
  final int hitsPerPage;
  final int? page;
  final int? offset;
  final int? length;
  final bool getRankingInfo;
  final Iterable<String>? attributesToRetrieve;
  final Iterable<String>? restrictSearchableAttributes;
  final String? filters;

  SearchRequest(this.index, this.query,
      {this.hitsPerPage = 10,
      this.getRankingInfo = true,
      this.length,
      this.offset,
      this.attributesToRetrieve,
      this.filters,
      this.page,
      this.restrictSearchableAttributes});

  String makeBody() {
    String str =
        '{"query": "$query", "hitsPerPage": $hitsPerPage, "getRankingInfo": $getRankingInfo';
    if (page != null) {
      str += ', "page": $page';
    }
    if (offset != null) {
      str += ', "offset": $offset';
    }
    if (length != null) {
      str += ', "length": $length';
    }
    if (filters != null) {
      str += ', "filters": $filters';
    }
    if (attributesToRetrieve != null) {
      str +=
          ', "attributesToRetrieve": [${attributesToRetrieve!.map((String s) => '"$s"').join(', ')}]';
    }
    if (restrictSearchableAttributes != null) {
      str +=
          ', "restrictSearchableAttributes": [${restrictSearchableAttributes!.map((String s) => '"$s"').join(', ')}]';
    }
    return str + '}';
  }
}
