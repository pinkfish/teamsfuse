part of firestore_wrapper;

abstract class StorageUploadTaskWrapper {
  Future<UploadTaskSnapshotWrapper> get future;
}

class UploadTaskSnapshotWrapper {
  UploadTaskSnapshotWrapper({this.downloadUrl});
  final Uri downloadUrl;
}
