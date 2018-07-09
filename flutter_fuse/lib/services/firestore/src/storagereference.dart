part of firestore_mobile;

class StorageReference extends wfs.StorageReferenceWrapper {
  st.StorageReference _ref;

  StorageReference(this._ref);

  @override
  String get path {
    return _ref.path;
  }

  @override
  Future<wfs.StorageMetadata> updateMetadata(wfs.StorageMetadata metadata) {
    st.StorageMetadata newMetadata = new st.StorageMetadata(
      cacheControl: metadata.cacheControl,
      contentDisposition: metadata.contentDisposition,
      contentEncoding: metadata.contentEncoding,
      contentLanguage: metadata.contentLanguage,
      contentType: metadata.contentType,
      customMetadata: metadata.customMetadata,
    );
    return _ref
        .updateMetadata(newMetadata)
        .then((st.StorageMetadata updatedMetadata) {
      return new wfs.StorageMetadata(
          customMetadata: updatedMetadata.customMetadata,
          contentType: updatedMetadata.contentType,
          contentLanguage: updatedMetadata.contentLanguage,
          contentEncoding: updatedMetadata.contentEncoding,
          contentDisposition: updatedMetadata.contentDisposition,
          cacheControl: updatedMetadata.cacheControl);
    });
  }

  @override
  Future<wfs.StorageMetadata> getMetadata() {}

  @override
  Future<void> delete() {
    return _ref.delete();
  }

  @override
  Future<dynamic> getDownloadURL() {
    return _ref.getDownloadURL();
  }

  @override
  Future<String> getName() async {
    return _ref.getName();
  }

  @override
  Future<String> getPath() async {
    return _ref.getPath();
  }

  @override
  Future<String> getBucket() async {
    return _ref.getBucket();
  }

  @override
  wfs.StorageUploadTaskWrapper putData(Uint8List data,
      [wfs.StorageMetadata metadata]) {
    return new StorageUploadTask(_ref.putData(data));
  }

  @override
  wfs.StorageUploadTaskWrapper putFile(File file,
      [wfs.StorageMetadata metadata]) {
    return new StorageUploadTask(_ref.putFile(file));
  }

  @override
  wfs.StorageUploadTaskWrapper put(File file, [wfs.StorageMetadata metadata]) {
    return new StorageUploadTask(_ref.put(file));
  }

  @override
  wfs.StorageReferenceWrapper child(String path) {
    return new StorageReference(_ref.child(path));
  }
}

class StorageUploadTask extends wfs.StorageUploadTaskWrapper {
  st.StorageUploadTask _task;

  StorageUploadTask(this._task);

  @override
  Future<wfs.UploadTaskSnapshotWrapper> get future {
    return _task.future.then((st.UploadTaskSnapshot f) {
      return new wfs.UploadTaskSnapshotWrapper(downloadUrl: f.downloadUrl);
    });
  }
}