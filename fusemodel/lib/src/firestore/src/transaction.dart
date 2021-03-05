part of firestore_wrapper;

typedef TransactionHandler = Future<Map<String, dynamic>> Function(
    TransactionWrapper transaction);

///
/// Wrapper class to handle transactions through firestore.
/// This is valid inside the transaction callback method and it is commited when the function ends.
///
abstract class TransactionWrapper {
  /// Gets the document data.
  Future<DocumentSnapshotWrapper> get(DocumentReferenceWrapper ref);

  /// Delete the specific document
  Future<void> delete(DocumentReferenceWrapper ref);

  /// Update the current doc.
  Future<void> update(DocumentReferenceWrapper ref, Map<String, dynamic> data);

  /// Sets the new data for the doc.
  Future<void> set(DocumentReferenceWrapper ref, Map<String, dynamic> data);
}
