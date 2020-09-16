part of firestore_mobile;

///
/// The entry point for accessing a Firestore, this is generic for web vs
/// mobile.
///
class Firestore extends wfs.FirestoreWrapper {
  wfs.AuthWrapper authWrapper;

  Firestore() {}

  /// Gets a [CollectionReference] for the specified Firestore path.
  @override
  wfs.CollectionReferenceWrapper collection(String path) {
    return CollectionReference(fs.FirebaseFirestore.instance.collection(path));
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  @override
  wfs.DocumentReferenceWrapper document(String path) {
    return DocumentReference(fs.FirebaseFirestore.instance.document(path));
  }

  @override
  wfs.StorageReferenceWrapper storageRef() {
    return StorageReference(st.FirebaseStorage.instance.ref());
  }

  @override
  wfs.AuthWrapper get auth {
    if (authWrapper == null) {
      authWrapper = Auth();
    }
    return authWrapper;
  }

  @override
  Future<Map<String, dynamic>> runTransaction(
      wfs.TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    return fs.FirebaseFirestore.instance
        .runTransaction((fs.Transaction transaction) {
      var t = Transaction(transaction);
      return transactionHandler(t);
    });
  }
}
