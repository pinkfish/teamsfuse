import 'searchitem.dart';

class SearchResult {
  final int page;
  final int nbHits;
  final int nbPages;
  final int hitsPerPage;
  final int processingTimeMs;
  final String query;
  final String parsedQuery;
  final String params;
  final String serverUsed;
  final String indexUsed;
  final Iterable<SearchItem> items;

  SearchResult.fromJSON(Map<String, dynamic> data)
      : page = data['page'] as int ?? 0,
        nbHits = data['nbHits'] as int ?? 0,
        nbPages = data['nbPages'] as int ?? 0,
        hitsPerPage = data['hitsPerPage'] as int ?? 0,
        processingTimeMs = data['processingTimeMs'] as int ?? 0,
        query = data['query'] as String ?? "",
        parsedQuery = data['parsed_query'] as String ?? '',
        params = data['params'] as String ?? '',
        serverUsed = data['serverUsed'] as String ?? '',
        indexUsed = data['indexUsed'] as String ?? '',
        items = (data['hits'] as Iterable<dynamic>)
            .map((dynamic data) => SearchItem(data as Map<String, dynamic>));

  @override
  String toString() {
    return 'SearchResult{page: $page, '
        'nbHits: $nbHits, '
        'nbPages: $nbPages, '
        'hitsPerPage: $hitsPerPage, '
        'processingTimeMs: $processingTimeMs, '
        'query: $query, '
        'parsedQuery: $parsedQuery, '
        'params: $params, '
        'items: $items}';
  }
}
