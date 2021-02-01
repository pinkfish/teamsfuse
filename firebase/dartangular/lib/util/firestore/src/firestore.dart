part of firestore_web;

///
/// The entry point for accessing a Firestore, this is generic for web vs
/// mobile.
///
class Firestore extends wfs.FirestoreWrapper {
  wfs.AuthWrapper? authWrapper;

  /// Gets a [CollectionReference] for the specified Firestore path.
  @override
  wfs.CollectionReferenceWrapper collection(String path) {
    return new CollectionReference(fb.firestore().collection(path));
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  @override
  wfs.DocumentReferenceWrapper document(String path) {
    return new DocumentReference(fb.firestore().doc(path));
  }

  @override
  wfs.StorageReferenceWrapper storageRef() {
    return new StorageReference(fb.storage().ref());
  }

  @override
  wfs.AuthWrapper get auth {
    if (authWrapper == null) {
      authWrapper = new Auth();
    }
    return authWrapper!;
  }

  @override
  // TODO: implement fieldValueDelete
  get fieldValueDelete => null;

  @override
  get fieldValueServerTimestamp => fb.ServerValue.TIMESTAMP;

  @override
  Future<Map<String, dynamic>> runTransaction(transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    var v = await fb.firestore().runTransaction((t) {
      transactionHandler(_MyTransactionWrapper(t));
    });
    return v as Map<String, dynamic>;
  }
}

class _MyTransactionWrapper extends wfs.TransactionWrapper {
  fs.Transaction _t;

  _MyTransactionWrapper(this._t);

  @override
  Future<void> delete(wfs.DocumentReferenceWrapper ref) async {
    var r = ref as DocumentReference;
    await _t.delete(r._doc);
    return;
  }

  @override
  Future<wfs.DocumentSnapshotWrapper> get(
      wfs.DocumentReferenceWrapper ref) async {
    var r = ref as DocumentReference;
    var newData = await _t.get(r._doc);
    return DocumentSnapshot(doc: newData);
  }

  @override
  Future<void> set(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    var r = ref as DocumentReference;
    await _t.set(r._doc, data);
    return;
  }

  @override
  Future<void> update(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    var r = ref as DocumentReference;
    await _t.update(r._doc, data: data);
    return;
  }
}
