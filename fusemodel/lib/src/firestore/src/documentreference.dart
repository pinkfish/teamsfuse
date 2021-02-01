part of firestore_wrapper;

/// A [DocumentReference] refers to a document location in a Firestore database
/// and can be used to write, read, or listen to the location.
///
/// The document at the referenced location may or may not exist.
/// A [DocumentReference] can also be used to create a [CollectionReference]
/// to a subcollection.
abstract class DocumentReferenceWrapper {
  @override
  int get hashCode;

  /// Slash-delimited path representing the database location of this query.
  String get path;

  /// This document's given or generated ID in the collection.
  String get documentID;

  /// Writes to the document referred to by this [DocumentReference].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  Future<void> setData(Map<String, dynamic> data, {bool merge: false});

  /// Updates fields in the document referred to by this [DocumentReference].
  ///
  /// If no document exists yet, the update will fail.
  Future<void> updateData(Map<String, dynamic> data);

  /// Reads the document referenced by this [DocumentReference].
  ///
  /// If no document exists, the read will return null.
  Future<DocumentSnapshotWrapper> get();

  /// Deletes the document referred to by this [DocumentReference].
  Future<void> delete();

  /// Returns the reference of a collection contained inside of this
  /// document.
  CollectionReferenceWrapper collection(String collectionPath);

  /// Notifies of documents at this location
  // TODO(jackson): Reduce code duplication with [Query]
  Stream<DocumentSnapshotWrapper> snapshots();
}
