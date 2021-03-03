import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../screens/publicclubhome.dart';
import '../services/algolia.dart';
import '../services/messagespublic.dart';

///
/// Show the search results
///
class SearchResults extends StatelessWidget {
  /// The results to display.
  final List<AlgoliaResult> results;

  /// Create the list of search results.
  SearchResults({@required this.results});

  Widget _createResult(BuildContext context, AlgoliaResult result) {
    switch (result.type) {
      case ResultType.club:
        return ListTile(
          title: Text(result.name),
          leading: Icon(MdiIcons.cardsClub),
          onTap: () => Navigator.pushNamed(context,
              "Public/${PublicTab.club.toString().replaceAll('PublicTab.', '')}/$result.uid"),
        );
      case ResultType.team:
        return ListTile(title: Text(result.name), leading: Icon(Icons.people));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Text(MessagesPublic.of(context).noResults);
    }
    return ListView(
      children: results.map((r) => _createResult(context, r)),
    );
  }
}
