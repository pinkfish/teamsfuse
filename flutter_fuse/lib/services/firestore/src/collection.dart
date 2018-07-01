part of firestore_mobile;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [Query]).
class CollectionReference extends wfs.CollectionReferenceWrapper {
  fs.CollectionReference _doc;

  CollectionReference(this._doc);

  /// ID of the referenced collection.
  String get id => _doc.id;

  /// A string containing the slash-separated path to this  CollectionReference
  /// (relative to the root of the database).
  String get path => _doc.path;

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  wfs.DocumentReferenceWrapper document([String path]) {
    return new DocumentReference(_doc.document(path));
  }

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<wfs.DocumentReferenceWrapper> add(Map<String, dynamic> data) async {
    return new DocumentReference(await _doc.add(data));
  }

  @override
  wfs.QueryWrapper orderBy(String field, {bool descending: false}) {
    return new Query(_doc.orderBy(field, descending: descending));
  }

  @override
  wfs.QueryWrapper limit(num limit) {
    return new Query(_doc.limit(limit.toInt()));
  }

  @override
  wfs.QueryWrapper where(String field,
      {dynamic isEqualTo,
      dynamic isLessThan,
      dynamic isLessThanOrEqualTo,
      dynamic isGreaterThan,
      dynamic isGreaterThanOrEqualTo,
      bool isNull}) {
    return new Query(_doc.where(field,
        isEqualTo: isEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo));
  }

  @override
  Future<wfs.QuerySnapshotWrapper> getDocuments() async {
    fs.QuerySnapshot snap = await _doc.getDocuments();
    return new wfs.QuerySnapshotWrapper(
      documents: snap.documents
          .map((fs.DocumentSnapshot snap) => new DocumentSnapshot(doc: snap))
          .toList(),
      documentChanges: snap.documentChanges
          .map(
            (fs.DocumentChange change) => new wfs.DocumentChangeWrapper(
                  document: new DocumentSnapshot(doc: change.document),
                  oldIndex: change.oldIndex,
                  newIndex: change.newIndex,
                  type: Query.getType(change.type),
                ),
          )
          .toList(),
    );
  }

  @override
  Stream<wfs.QuerySnapshotWrapper> snapshots() {
    Stream<wfs.QuerySnapshotWrapper> str =
        _doc.snapshots().transform(new QuerySnapshotStreamTransformer());
    print("$str $_doc");
    return str;
  }
}

class QuerySnapshotStreamTransformer
    extends StreamTransformerBase<fs.QuerySnapshot, wfs.QuerySnapshotWrapper> {
  StreamController<wfs.QuerySnapshotWrapper> _controller;

  StreamSubscription _subscription;

  // Original Stream
  Stream<fs.QuerySnapshot> _stream;

  QuerySnapshotStreamTransformer() {
    _controller = new StreamController<wfs.QuerySnapshotWrapper>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  /**
   * Transformation
   */

  void onData(fs.QuerySnapshot data) {
    _controller.add(new wfs.QuerySnapshotWrapper(
      documents: data.documents
          .map((fs.DocumentSnapshot snap) => new DocumentSnapshot(doc: snap))
          .toList(),
      documentChanges: data.documentChanges
          .map(
            (fs.DocumentChange change) => new wfs.DocumentChangeWrapper(
                  document: new DocumentSnapshot(doc: change.document),
                  oldIndex: change.oldIndex,
                  newIndex: change.newIndex,
                  type: Query.getType(change.type),
                ),
          )
          .toList(),
    ));
  }

  /**
   * Bind
   */
  Stream<wfs.QuerySnapshotWrapper> bind(Stream<fs.QuerySnapshot> stream) {
    this._stream = stream;
    return _controller.stream;
  }
}
