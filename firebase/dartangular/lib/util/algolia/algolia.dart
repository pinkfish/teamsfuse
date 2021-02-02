import 'dart:async';
import 'dart:convert';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import 'request.dart';
import 'searchresult.dart';

export 'request.dart';
export 'searchitem.dart';
export 'searchresult.dart';

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

  Future<Map<String, dynamic>> get(String index, String objectId) async {
    String url =
        "${_applicationId}-dsn.algolia.net/1/indexes/${index}/${objectId}";
    http.Response response = await _client.post(url, headers: {
      'X-Algolia-API-Key': _applicationKey,
      'X-Algolia-Application-Id': _applicationId,
    });
    dynamic data = json.decode(response.body);
    return data as Map<String, dynamic>;
  }
}
