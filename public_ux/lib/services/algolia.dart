import 'package:algolia/algolia.dart';

/// The type of the result from the search
enum ResultType { team, club }

/// The result to display.
class AlgoliaResult {
  /// The type of the result
  final ResultType type;

  /// The uid of the item.
  final String uid;

  /// The name to display.
  final String name;

  /// Extra data about the result.
  final Map<String, dynamic> data;

  /// Create a new result with the right data.
  AlgoliaResult(this.type, this.uid, this.name, this.data);
}

///
/// Injectable class to handle finding the search pieces.
///
class AlgoliaSearch {
  final Algolia _algolia = Algolia.init(
    apiKey: 'b4f1e771f1fb06628a1c8b8b4ab04bbf',
    applicationId: 'Y6FMHKGRPD',
  );

  ///
  /// Search algolia and result the current set of results.
  ///
  Future<List<AlgoliaResult>> search(String query) async {
    ///
    /// Perform Query
    ///
    final result = _algolia.instance.index('teams').search(query);

    // Get Result/Objects
    try {
      final snap = await result.getObjects();
      if (snap.empty) {
        return [];
      }
      return snap.hits
          .map<AlgoliaResult>((d) => _makeResult(d))
          .where((d) => d != null)
          .toList();
    } catch (e, stack) {
      print(e);
      print(stack);
      return [];
    }
  }

  AlgoliaResult _makeResult(AlgoliaObjectSnapshot result) {
    print("Make result ${result.objectID}");
    if (result.objectID.startsWith('C')) {
      return AlgoliaResult(ResultType.club, result.objectID.substring(1),
          result.data['name'], result.data);
    }
    if (result.objectID.startsWith('T')) {
      return AlgoliaResult(ResultType.team, result.objectID.substring(1),
          result.data['name'], result.data);
    }
    return null;
  }
}
