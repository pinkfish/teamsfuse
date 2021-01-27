part of firestore_mobile;

///
/// The entry point for accessing a Firestore, this is generic for web vs
/// mobile.
///
class Firestore extends wfs.FirestoreWrapper {
  final wfs.AuthWrapper _authWrapper = Auth();

  /// Gets a [CollectionReference] for the specified Firestore path.
  @override
  wfs.CollectionReferenceWrapper collection(String path) {
    return CollectionReference(fs.FirebaseFirestore.instance.collection(path));
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  @override
  wfs.DocumentReferenceWrapper document(String path) {
    return DocumentReference(fs.FirebaseFirestore.instance.doc(path));
  }

  @override
  wfs.StorageReferenceWrapper storageRef() {
    return StorageReference(st.FirebaseStorage.instance.ref());
  }

  @override
  wfs.AuthWrapper get auth {
    return _authWrapper;
  }

  @override
  Future<Map<String, dynamic>> runTransaction(
      wfs.TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) {
    return fs.FirebaseFirestore.instance.runTransaction((transaction) {
      var t = Transaction(transaction);
      return transactionHandler(t);
    });
  }

  dynamic get fieldValueServerTimestamp {
    return fs.FieldValue.serverTimestamp();
  }

  dynamic get fieldValueDelete {
    return fs.FieldValue.delete();
  }
}
