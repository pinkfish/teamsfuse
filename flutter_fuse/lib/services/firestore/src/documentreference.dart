part of firestore_mobile;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
@immutable
class MyDocumentReference extends wfs.DocumentReferenceWrapper {
  /// Constructor.
  MyDocumentReference(this._doc);

  final fs.DocumentReference _doc;

  @override
  bool operator ==(dynamic o);

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
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return _doc.set(data, fs.SetOptions(merge: merge));
  }

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  @override
  Future<void> updateData(Map<String, dynamic> data) {
    return _doc.update(data);
  }

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  @override
  Future<wfs.DocumentSnapshotWrapper> get() async {
    var snap = await _doc.get();
    if (snap != null) {
      return DocumentSnapshot(snap);
    }
    return null;
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
    return CollectionReference(_doc.collection(collectionPath));
  }

  /// Notifies of documents at this location
  @override
  Stream<wfs.DocumentSnapshotWrapper> snapshots() {
    return _doc.snapshots().transform(_DocumentSnapshotStreamTransformer(this));
  }
}

class _DocumentSnapshotStreamTransformer extends StreamTransformerBase<
    fs.DocumentSnapshot, wfs.DocumentSnapshotWrapper> {
  _DocumentSnapshotStreamTransformer(this.ref) {
    _controller = StreamController<wfs.DocumentSnapshotWrapper>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  final MyDocumentReference ref;
  StreamController<wfs.DocumentSnapshotWrapper> _controller;

  StreamSubscription<fs.DocumentSnapshot> _subscription;

  // Original Stream
  Stream<fs.DocumentSnapshot> _stream;

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
  //

  void onData(fs.DocumentSnapshot data) {
    _controller.add(DocumentSnapshot(data));
  }

  ///
  ///Bind
  ///
  @override
  Stream<wfs.DocumentSnapshotWrapper> bind(Stream<fs.DocumentSnapshot> stream) {
    _stream = stream;
    return _controller.stream;
  }
}
