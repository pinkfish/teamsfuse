part of firestore_mobile;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshot extends wfs.DocumentSnapshotWrapper {
  DocumentSnapshot({this.doc})
      : super(
            documentID: doc.exists ? doc.documentID : null,
            data: doc.exists ? doc.data() : null,
            exists: doc.exists);

  fs.DocumentSnapshot doc;

  /// The reference that produced this snapshot
  @override
  DocumentReference get reference => new DocumentReference(doc.reference);
}
