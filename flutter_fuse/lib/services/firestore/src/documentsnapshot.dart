part of firestore_mobile;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot extends wfs.DocumentSnapshotWrapper {
  fs.DocumentSnapshot doc;

  DocumentSnapshot({this.doc})
      : super(documentID: doc.documentID, data: doc.data, exists: doc.exists);

  /// The reference that produced this snapshot
  DocumentReference get reference => new DocumentReference(doc.reference);
}
