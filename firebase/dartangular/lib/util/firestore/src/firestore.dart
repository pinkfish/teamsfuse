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
      {Duration timeout = const Duration(seconds: 5)}) {
    fb.firestore().runTransaction(transactionHandler);
    // TODO: implement runTransaction
    throw UnimplementedError();
  }
}
