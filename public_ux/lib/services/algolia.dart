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
    applicationId: 'b4f1e771f1fb06628a1c8b8b4ab04bbf',
    apiKey: 'Y6FMHKGRPD',
  );

  ///
  /// Search algolia and result the current set of results.
  ///
  Future<List<AlgoliaResult>> search(String query) async {
    ///
    /// Perform Query
    ///
    AlgoliaQuery result = _algolia.instance.index('contacts').search(query);

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await result.getObjects();
    if (snap.empty) {
      return [];
    }
    return snap.hits
        .map<AlgoliaResult>((d) => _makeResult(d))
        .where((d) => d != null);
  }

  AlgoliaResult _makeResult(AlgoliaObjectSnapshot result) {
    if (result.index.startsWith("C")) {
      return AlgoliaResult(ResultType.club, result.index.substring(1),
          result.data["name"], result.data);
    }
    if (result.index.startsWith("T")) {
      return AlgoliaResult(ResultType.team, result.index.substring(1),
          result.data["name"], result.data);
    }
    return null;
  }
}
