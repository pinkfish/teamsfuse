import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_ux/services/algolia.dart';

import 'searchbox.dart';
import 'searchresults.dart';

///
/// Search widget with the box and results.
///
class Search extends StatefulWidget {
  /// The initial query for the search widget.
  final String initialQuery;

  /// Create the search widget.
  Search({@required this.initialQuery});

  @override
  State<StatefulWidget> createState() {
    return _SearchState();
  }
}

class _SearchState extends State<Search> {
  String _query;
  List<AlgoliaResult> _results;

  void _updateSearch(String query) async {
    _query = query.trim();
    // Navigate the state.
    Navigator.pushNamed(context, '/Search/${Uri.encodeQueryComponent(query)}');
    if (_query.isNotEmpty) {
      // Update the navigation url to include the query.
      final algolia = RepositoryProvider.of<AlgoliaSearch>(context);
      final results = await algolia.search(_query);
      setState(() => _results = results);
    } else {
      setState(() => _results = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SearchBox(
        onSearchChanged: (q) => _updateSearch(q),
        initialQuery: _query,
      ),
      Expanded(
        child: SearchResults(results: _results),
      ),
    ]);
  }
}