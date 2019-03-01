part of firestore_wrapper;

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshotWrapper {
  /// Gets a list of all the documents included in this snapshot
  final List<DocumentSnapshotWrapper> documents;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  final List<DocumentChangeWrapper> documentChanges;

  QuerySnapshotWrapper({this.documents, this.documentChanges})
      : assert(documentChanges != null),
        assert(documents != null);
}
