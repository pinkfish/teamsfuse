part of firestore_mobile;

/// Represents a query over the data at a particular location.
class Query extends wfs.QueryWrapper {
  Query(this._doc);

  fs.Query _doc;

  /// Notifies of query results at this location
  @override
  Stream<wfs.QuerySnapshotWrapper> snapshots() {
    return _doc.snapshots().transform(QuerySnapshotStreamTransformer());
  }

  /// Fetch the documents for this query
  @override
  Future<wfs.QuerySnapshotWrapper> getDocuments() async {
    fs.QuerySnapshot query = await _doc.getDocuments();
    return wfs.QuerySnapshotWrapper(
      documents: query.documents
          .map((fs.DocumentSnapshot snap) => DocumentSnapshot(doc: snap))
          .toList(),
      documentChanges: query.documentChanges
          .map(
            (fs.DocumentChange change) => wfs.DocumentChangeWrapper(
              document: DocumentSnapshot(doc: change.document),
              oldIndex: change.oldIndex,
              newIndex: change.newIndex,
              type: getType(change.type),
            ),
          )
          .toList(),
    );
  }

  static wfs.DocumentChangeTypeWrapper getType(fs.DocumentChangeType str) {
    switch (str) {
      case fs.DocumentChangeType.added:
        return wfs.DocumentChangeTypeWrapper.added;
      case fs.DocumentChangeType.removed:
        return wfs.DocumentChangeTypeWrapper.removed;
      case fs.DocumentChangeType.modified:
        return wfs.DocumentChangeTypeWrapper.modified;
    }
    return null;
  }

  /// Creates and returns a [Query] with additional filter on specified
  /// [field].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  @override
  wfs.QueryWrapper where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  }) {
    return Query(_doc.where(field,
        isEqualTo: isEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo));
  }

  /// Creates and returns a [Query] that's additionally sorted by the specified
  /// [field].
  @override
  wfs.QueryWrapper orderBy(String field, {bool descending: false}) {
    return Query(_doc.orderBy(field, descending: descending));
  }

  @override
  wfs.QueryWrapper limit(int num) {
    return Query(_doc.limit(num));
  }
}
