part of firestore_mobile;

class Transaction extends wfs.TransactionWrapper {
  Transaction(this.transaction);

  fs.Transaction transaction;

  @override
  Future<wfs.DocumentSnapshotWrapper> get(
      wfs.DocumentReferenceWrapper ref) async {
    if (ref is DocumentReference) {
      fs.DocumentSnapshot snap = await transaction.get(ref._doc);
      return new DocumentSnapshot(doc: snap);
    }
    throw ArgumentError("Not a DocumentReference");
  }

  @override
  Future<void> delete(wfs.DocumentReferenceWrapper ref) async {
    if (ref is DocumentReference) {
      await transaction.delete(ref._doc);
    }
    throw ArgumentError("Not a DocumentReference");
  }

  @override
  Future<void> update(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    if (ref is DocumentReference) {
      await transaction.update(ref._doc, data);
    }
    throw ArgumentError("Not a DocumentReference");
  }

  @override
  Future<void> set(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    if (ref is DocumentReference) {
      await transaction.update(ref._doc, data);
    }
    throw ArgumentError("Not a DocumentReference");
  }
}
