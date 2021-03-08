import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../screens/publicclubhome.dart';
import '../services/algolia.dart';

///
/// Show the search result card.
///
class SearchResult extends StatelessWidget {
  /// The results to display.
  final AlgoliaResult result;

  final ValueChanged<String> onTapped;

  /// Create the list of search results.
  SearchResult({@required this.result, this.onTapped});

  Widget _createResult(BuildContext context, AlgoliaResult result) {
    switch (result.type) {
      case ResultType.club:
        return ListTile(
          title: Text(result.name),
          leading: Icon(MdiIcons.cardsClub),
          onTap: () =>
              onTapped('Public/${PublicClubTab.club.name}/${result.uid}'),
        );
      case ResultType.team:
        return ListTile(title: Text(result.name), leading: Icon(Icons.people));
      default:
        return ListTile(title: Text(result.name), leading: Icon(Icons.help));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _createResult(context, result);
  }
}
