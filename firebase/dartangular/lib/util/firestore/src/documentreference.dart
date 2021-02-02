part of firestore_web;

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
  int get hashCode;

  /// Slash-delimited path representing the database location of this query.
  @override
  String get path => _doc.path;

  /// This document's given or generated ID in the collection.
  @override
  String get documentID => _doc.id;

  /// Writes to the document referred to by this [DocumentReference].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge: false}) {
    fs.SetOptions opt = new fs.SetOptions(merge: merge);
    return _doc.set(data, opt);
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  @override
  Future<void> updateData(Map<String, dynamic> data) {
    return setData(data, merge: true);
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  @override
  Future<wfs.DocumentSnapshotWrapper> get() async {
    return new DocumentSnapshot(doc: await _doc.get());
  }

  /// Deletes the document referred to by this [DocumentReference].
  @override
  Future<void> delete() {
    return _doc.delete();
  }

  /// Returns the reference of a collection contained inside of this
  /// document.
  @override
  wfs.CollectionReferenceWrapper collection(String collectionPath) {
    return new CollectionReference(_doc.collection(collectionPath));
  }

  /// Notifies of documents at this location
  @override
  Stream<wfs.DocumentSnapshotWrapper> snapshots() {
    return _doc.onSnapshot.transform(new DocumentSnapshotStreamTransformer());
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
          _subscription?.pause();
        },
        onResume: () {
          _subscription?.resume();
        });
  }

  void _onListen() {
    _subscription = _stream?.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  void onData(fs.DocumentSnapshot data) {
    _controller.add(new DocumentSnapshot(doc: data));
  }

  @override
  Stream<wfs.DocumentSnapshotWrapper> bind(Stream<fs.DocumentSnapshot> stream) {
    _stream = stream;
    return _controller.stream;
  }
}
