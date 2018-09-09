part of firestore_wrapper;

/// A DocumentSnapshot contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the data property or by using subscript
/// syntax to access a specific field.
abstract class DocumentSnapshotWrapper {
  DocumentSnapshotWrapper({this.documentID, this.data, this.exists})
      : assert(exists != null);

  /// The reference that produced this snapshot
  DocumentReferenceWrapper get reference;

  /// Contains all the data of this snapshot
  final Map<String, dynamic> data;

  /// Reads individual values from the snapshot
  dynamic operator [](String key) => data[key];

  /// Returns the ID of the snapshot's document
  final String documentID;

  /// Returns `true` if the document exists.
  final bool exists;
}
