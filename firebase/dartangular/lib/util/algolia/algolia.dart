import 'dart:async';
import 'package:http/http.dart' as http;
import 'searchresult.dart';
import 'dart:convert';
import 'package:http/browser_client.dart';
export 'searchresult.dart';
import 'request.dart';
export 'request.dart';

class Algolia {
  final String _applicationId;
  final String _applicationKey;
  final http.Client _client;

  Algolia(this._applicationId, this._applicationKey, {http.Client client})
      : _client = client ?? BrowserClient();

  Future<SearchResult> search(SearchRequest search) async {
    String url =
        "https://${_applicationId}-dsn.algolia.net/1/indexes/${search.index}/query";
    http.Response response = await _client.post(url,
        headers: {
          'X-Algolia-API-Key': _applicationKey,
          'X-Algolia-Application-Id': _applicationId,
        },
        body: search.makeBody());
    dynamic data = json.decode(response.body);
    return new SearchResult.fromJSON(data as Map<String, dynamic>);
  }
}
