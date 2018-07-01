part of firestore_mobile;

///
/// The entry point for accessing a Firestore, this is generic for web vs
/// mobile.
///
class Firestore extends wfs.FirestoreWrapper {
  wfs.AuthWrapper authWrapper;

  /// Gets a [CollectionReference] for the specified Firestore path.
  wfs.CollectionReferenceWrapper collection(String path) {
    return new CollectionReference(fs.Firestore.instance.collection(path));
  }

  /// Gets a [DocumentReference] for the specified Firestore path.
  wfs.DocumentReferenceWrapper document(String path) {
    return new DocumentReference(fs.Firestore.instance.document(path));
  }

  @override
  wfs.StorageReferenceWrapper storageRef() {
    return new StorageReference(st.FirebaseStorage.instance.ref());
  }

  wfs.AuthWrapper get auth {
    if (authWrapper == null) {
      authWrapper = new Auth();
    }
    return authWrapper;
  }
}
