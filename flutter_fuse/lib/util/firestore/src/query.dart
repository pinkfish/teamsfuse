part of firestore_wrapper;

/// Represents a query over the data at a particular location.
abstract class QueryWrapper {

  /// Notifies of query results at this location
  // TODO(jackson): Reduce code duplication with [DocumentReference]
  Stream<QuerySnapshotWrapper> snapshots();

  /// Fetch the documents for this query
  Future<QuerySnapshotWrapper> getDocuments();

  /// Obtains a CollectionReference corresponding to this query's location.
  CollectionReferenceWrapper reference();

  /// Creates and returns a new [Query] with additional filter on specified
  /// [field].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  QueryWrapper where(String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  });

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  QueryWrapper orderBy(String field, {bool descending: false});

  /// Takes a list of [values], creates and returns a new [Query] that starts after
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAt].
  QueryWrapper startAfter(List<dynamic> values);

  /// Takes a list of [values], creates and returns a new [Query] that starts at
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [startAfter].
  QueryWrapper startAt(List<dynamic> values);

  /// Takes a list of [values], creates and returns a new [Query] that ends at the
  /// provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endBefore].
  QueryWrapper endAt(List<dynamic> values);

  /// Takes a list of [values], creates and returns a new [Query] that ends before
  /// the provided fields relative to the order of the query.
  ///
  /// The [values] must be in order of [orderBy] filters.
  ///
  /// Cannot be used in combination with [endAt].
  QueryWrapper endBefore(List<dynamic> values);

  /// Creates and returns a new Query that's additionally limited to only return up
  /// to the specified number of documents.
  QueryWrapper limit(int length);
}