part of firestore_web;

/// Represents a query over the data at a particular location.
class Query extends wfs.QueryWrapper {
  fs.Query _doc;

  Query(this._doc);

  Stream<wfs.QuerySnapshotWrapper> snapshots() {
    return this._doc.onSnapshot.transform(new QuerySnapshotStreamTransformer());
  }

  /// Fetch the documents for this query
  Future<wfs.QuerySnapshotWrapper> getDocuments() async {
    fs.QuerySnapshot query = await _doc.get();
    return new wfs.QuerySnapshotWrapper(
      documents: query.docs
          .map((fs.DocumentSnapshot snap) => new DocumentSnapshot(doc: snap))
          .toList(),
      documentChanges: query.docChanges
          .map(
            (fs.DocumentChange change) => new wfs.DocumentChangeWrapper(
                  document: new DocumentSnapshot(doc: change.doc),
                  oldIndex: change.oldIndex,
                  newIndex: change.newIndex,
                  type: getType(change.type),
                ),
          )
          .toList(),
    );
  }

  static wfs.DocumentChangeTypeWrapper getType(String str) {}

  /// Creates and returns a new [Query] with additional filter on specified
  /// [field].
  ///
  /// Only documents satisfying provided condition are included in the result
  /// set.
  wfs.QueryWrapper where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    bool isNull,
  }) {
    Query ret = this;
    if (isEqualTo != null) {
      ret = new Query(_doc.where(field, "==", isEqualTo));
    }
    if (isLessThan != null) {
      ret = new Query(_doc.where(field, "<", isLessThan));
    }
    if (isLessThanOrEqualTo != null) {
      ret = new Query(_doc.where(field, "<=", isLessThanOrEqualTo));
    }
    if (isGreaterThan != null) {
      ret = new Query(_doc.where(field, ">", isGreaterThan));
    }
    if (isGreaterThanOrEqualTo != null) {
      ret = new Query(_doc.where(field, ">=", isGreaterThanOrEqualTo));
    }
    if (isNull != null) {
      assert(
          isNull,
          'isNull can only be set to true. '
          'Use isEqualTo to filter on non-null values.');
      {
        ret = new Query(_doc.where(field, "==", null));
      }
    }

    return ret;
  }

  /// Creates and returns a new [Query] that's additionally sorted by the specified
  /// [field].
  wfs.QueryWrapper orderBy(String field, {bool descending: false}) {
    return new Query(_doc.orderBy(field, descending ? "desc" : "asc"));
  }

  @override
  wfs.QueryWrapper limit(int num) {
    return new Query(_doc.limit(num));
  }
}
