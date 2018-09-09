part of firestore_mobile;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot extends wfs.DocumentSnapshotWrapper {
  fs.DocumentSnapshot doc;

  DocumentSnapshot({this.doc})
      : super(documentID: doc.exists ? doc.documentID : null, data: doc.exists ? doc.data : null, exists: doc.exists);

  /// The reference that produced this snapshot
  @override
  DocumentReference get reference => new DocumentReference(doc.reference);
}
