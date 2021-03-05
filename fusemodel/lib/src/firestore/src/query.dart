part of firestore_wrapper;

/// Represents a query over the data at a particular location.
abstract class QueryWrapper {
  /// Notifies of query results at this location
  // TODO(jackson): Reduce code duplication with [DocumentReference]
  Stream<QuerySnapshotWrapper> snapshots();

  /// Fetch the documents for this query
  Future<QuerySnapshotWrapper> getDocuments();

  /// Creates and returns a new [Query] with additional filter on specified
  /// [field].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  QueryWrapper where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  });

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  QueryWrapper orderBy(String field, {bool descending = false});

  /// The point in which in the query should start at.
  QueryWrapper startAt(dynamic arg);

  QueryWrapper limit(int num);
}
