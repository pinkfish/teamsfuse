part of firestore_mobile;

class Transaction extends wfs.TransactionWrapper {
  fs.Transaction transaction;

  Transaction(this.transaction);

  Future<wfs.DocumentSnapshotWrapper> get(
      wfs.DocumentReferenceWrapper ref) async {
    if (ref is DocumentReference) {
      fs.DocumentSnapshot snap = await transaction.get(ref._doc);
      return new DocumentSnapshot(doc: snap);
    }
    throw ArgumentError("Not a DocumentReference");
  }

  Future<void> delete(wfs.DocumentReferenceWrapper ref) async {
    if (ref is DocumentReference) {
      await transaction.delete(ref._doc);
    }
    throw ArgumentError("Not a DocumentReference");
  }

  Future<void> update(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    if (ref is DocumentReference) {
      await transaction.update(ref._doc, data);
    }
    throw ArgumentError("Not a DocumentReference");
  }

  Future<void> set(
      wfs.DocumentReferenceWrapper ref, Map<String, dynamic> data) async {
    if (ref is DocumentReference) {
      await transaction.update(ref._doc, data);
    }
    throw ArgumentError("Not a DocumentReference");
  }
}
