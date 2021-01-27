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

  /// Creates a new [StorageReference] initialized at the root
  /// Firebase Storage location.
  StorageReferenceWrapper storageRef();

  // Runs a transaction.dart.
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)});

  /// Returns the auth wrapper to deal with the auth system.
  AuthWrapper get auth;

  /// Gets the value to put on a field to set it up with the server timestamp
  dynamic get fieldValueServerTimestamp;

  /// Gets the value to put on a field to set it to delete itself.
  dynamic get fieldValueDelete;
}
