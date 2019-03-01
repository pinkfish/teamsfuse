part of firestore_wrapper;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [Query]).
abstract class CollectionReferenceWrapper extends QueryWrapper {
  /// ID of the referenced collection.
  String get id;

  /// A string containing the slash-separated path to this  CollectionReference
  /// (relative to the root of the database).
  String get path;

  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentReferenceWrapper document([String path]);

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocumentReferenceWrapper> add(Map<String, dynamic> data);
}