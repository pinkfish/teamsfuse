import 'package:flutter/material.dart';

import '../services/messagespublic.dart';

///
/// The search box to displkay for doing a fun search
///
class SearchBox extends StatelessWidget {
  // controls the text label we use as a search bar
  final TextEditingController _filter;

  /// When the value changes in the search box.
  final ValueChanged<String> onSearchChanged;

  /// The initial query for the search widget.
  final String initialQuery;

  /// Create a search box.
  SearchBox({@required this.initialQuery, @required this.onSearchChanged})
      : _filter = TextEditingController(text: initialQuery);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.search),
      Expanded(
        child: TextField(
          controller: _filter,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: MessagesPublic.of(context).search,
          ),
          onChanged: onSearchChanged,
        ),
      ),
    ]);
  }
}
