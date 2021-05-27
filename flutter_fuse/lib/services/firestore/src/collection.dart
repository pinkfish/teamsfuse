part of firestore_mobile;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [Query]).
class CollectionReference extends wfs.CollectionReferenceWrapper {
  /// Wrapper constructor.
  CollectionReference(this._doc);

  final fs.CollectionReference _doc;

  /// ID of the referenced collection.
  @override
  String get id => _doc.id;

  /// A string containing the slash-separated path to this  CollectionReference
  /// (relative to the root of the database).
  @override
  String get path => _doc.path;

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  @override
  wfs.DocumentReferenceWrapper document([String path]) {
    return MyDocumentReference(_doc.doc(path));
  }

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  @override
  Future<wfs.DocumentReferenceWrapper> add(Map<String, dynamic> data) async {
    return MyDocumentReference(await _doc.add(data));
  }

  @override
  wfs.QueryWrapper orderBy(String field, {bool descending = false}) {
    return Query(_doc.orderBy(field, descending: descending));
  }

  @override
  wfs.QueryWrapper limit(num limit) {
    return Query(_doc.limit(limit.toInt()));
  }

  @override
  wfs.QueryWrapper startAt(dynamic data) {
    return Query(_doc.startAt(data));
  }

  @override
  wfs.QueryWrapper where(String field,
      {dynamic isEqualTo,
      dynamic isLessThan,
      dynamic isLessThanOrEqualTo,
      dynamic isGreaterThan,
      dynamic isGreaterThanOrEqualTo,
      bool isNull}) {
    return Query(_doc.where(field,
        isEqualTo: isEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo));
  }

  @override
  Future<wfs.QuerySnapshotWrapper> getDocuments() async {
    var snap = await _doc.get();
    return wfs.QuerySnapshotWrapper(
      documents: snap.docs.map((snap) => DocumentSnapshot(snap)).toList(),
      documentChanges: snap.docChanges
          .map(
            (change) => wfs.DocumentChangeWrapper(
              document: DocumentSnapshot(change.doc),
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
    var str = _doc.snapshots().transform(_QuerySnapshotStreamTransformer());
    return str;
  }
}

class _QuerySnapshotStreamTransformer extends StreamTransformerBase<
    fs.QuerySnapshot<Map<String, dynamic>>, wfs.QuerySnapshotWrapper> {
  _QuerySnapshotStreamTransformer() {
    _controller = StreamController<wfs.QuerySnapshotWrapper>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  StreamController<wfs.QuerySnapshotWrapper> _controller;

  StreamSubscription<fs.QuerySnapshot> _subscription;

  // Original Stream
  Stream<fs.QuerySnapshot> _stream;

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  ///
  /// Transformation
  ///

  void onData(fs.QuerySnapshot data) {
    _controller.add(wfs.QuerySnapshotWrapper(
      documents: data.docs.map((snap) => DocumentSnapshot(snap)).toList(),
      documentChanges: data.docChanges
          .map(
            (change) => wfs.DocumentChangeWrapper(
              document: DocumentSnapshot(change.doc),
              oldIndex: change.oldIndex,
              newIndex: change.newIndex,
              type: Query.getType(change.type),
            ),
          )
          .toList(),
    ));
  }

  ///
  /// Bind
  ///
  @override
  Stream<wfs.QuerySnapshotWrapper> bind(Stream<fs.QuerySnapshot> stream) {
    _stream = stream;
    return _controller.stream;
  }
}
