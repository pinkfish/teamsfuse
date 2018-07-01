
part of firestore_wrapper;

///
/// The entry point for accessing a Firestore, this is generic for web vs
/// mobile.
///
abstract class FirestoreWrapper {
  /// Gets a [CollectionReference] for the specified Firestore path.
  CollectionReferenceWrapper collection(String path);

  /// Gets a [DocumentReference] for the specified Firestore path.
  DocumentReferenceWrapper document(String path);
}