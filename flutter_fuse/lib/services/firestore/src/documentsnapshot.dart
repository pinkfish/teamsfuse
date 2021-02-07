part of firestore_mobile;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
@immutable
class DocumentSnapshot extends wfs.DocumentSnapshotWrapper {
  /// Constructor for the snapshot.
  DocumentSnapshot(this._doc)
      : super(
            documentID: _doc.exists ? _doc.id : null,
            data: _doc.exists ? _doc.data() : null,
            exists: _doc.exists);

  final fs.DocumentSnapshot _doc;

  /// The reference that produced this snapshot
  @override
  MyDocumentReference get reference => MyDocumentReference(_doc.reference);
}
