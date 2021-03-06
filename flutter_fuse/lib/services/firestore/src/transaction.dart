part of firestore_mobile;

///
/// Wrapper for the transaction.
class Transaction extends wfs.TransactionWrapper {
  /// Constructor for the wrapper.
  Transaction(this._transaction);

  final fs.Transaction _transaction;

  @override
  Future<wfs.DocumentSnapshotWrapper> get(
      wfs.DocumentReferenceWrapper ref) async {
    if (ref is MyDocumentReference) {
      var snap = await _transaction.get(ref._doc);
      return DocumentSnapshot(snap);
    }

    throw ArgumentError('${ref.runtimeType} Not a DocumentReference');
  }

  @override
  Future<void> delete(wfs.DocumentReferenceWrapper ref) async {
    if (ref is MyDocumentReference) {
      return _transaction.delete(ref._doc);
    }
    throw ArgumentError('${ref.runtimeType} Not a DocumentReference');
  }

  @override
  Future<void> update(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    if (ref is MyDocumentReference) {
      return _transaction.update(ref._doc, data);
    }
    throw ArgumentError('${ref.runtimeType} Not a DocumentReference');
  }

  @override
  Future<void> set(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    if (ref is MyDocumentReference) {
      return _transaction.set(ref._doc, data);
    }
    throw ArgumentError('${ref.runtimeType} Not a DocumentReference');
  }
}
