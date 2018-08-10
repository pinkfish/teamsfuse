part of firestore_mobile;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
class DocumentReference extends wfs.DocumentReferenceWrapper {
  final fs.DocumentReference _doc;

  DocumentReference(this._doc);

  @override
  bool operator ==(dynamic o);

  @override
  int get hashCode;

  /// Slash-delimited path representing the database location of this query.
  String get path => _doc.path;

  /// This document's given or generated ID in the collection.
  String get documentID => _doc.documentID;

  /// Writes to the document referred to by this [DocumentReference].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  Future<void> setData(Map<String, dynamic> data, {bool merge: false}) {
    return _doc.setData(data, merge: merge);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(Map<String, dynamic> data) {
    return _doc.updateData(data);
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<wfs.DocumentSnapshotWrapper> get() async {
    fs.DocumentSnapshot snap = await _doc.get();
    if (snap != null) {
      return new DocumentSnapshot(doc: snap);
    }
    return null;
  }

  /// Deletes the document referred to by this [DocumentReference].
  Future<void> delete() {
    return _doc.delete();
  }

  /// Returns the reference of a collection contained inside of this
  /// document.
  wfs.CollectionReferenceWrapper collection(String collectionPath) {
    return new CollectionReference(_doc.collection(collectionPath));
  }

  /// Notifies of documents at this location
  // TODO(jackson): Reduce code duplication with [Query]
  Stream<wfs.DocumentSnapshotWrapper> snapshots() {
    return _doc.snapshots().transform(new DocumentSnapshotStreamTransformer());
  }
}

class DocumentSnapshotStreamTransformer extends StreamTransformerBase<
    fs.DocumentSnapshot, wfs.DocumentSnapshotWrapper> {
  StreamController<wfs.DocumentSnapshotWrapper> _controller;

  StreamSubscription _subscription;

  // Original Stream
  Stream<fs.DocumentSnapshot> _stream;

  DocumentSnapshotStreamTransformer() {
    _controller = new StreamController<wfs.DocumentSnapshotWrapper>(
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

  void onData(fs.DocumentSnapshot data) {
    _controller.add(new DocumentSnapshot(doc: data));
  }

  /**
   * Bind
   */
  Stream<wfs.DocumentSnapshotWrapper> bind(Stream<fs.DocumentSnapshot> stream) {
    this._stream = stream;
    return _controller.stream;
  }
}
