part of firestore_web;

class StorageReference extends wfs.StorageReferenceWrapper {
  fb.StorageReference _ref;

  StorageReference(this._ref);

  @override
  String get path {
    return _ref.fullPath;
  }

  @override
  Future<wfs.StorageMetadata> updateMetadata(wfs.StorageMetadata metadata) {
    fb.SettableMetadata newMetadata = new fb.SettableMetadata(
      cacheControl: metadata.cacheControl,
      contentDisposition: metadata.contentDisposition,
      contentEncoding: metadata.contentEncoding,
      contentLanguage: metadata.contentLanguage,
      contentType: metadata.contentType,
      customMetadata: metadata.customMetadata,
    );
    return _ref
        .updateMetadata(newMetadata)
        .then((fb.FullMetadata updatedMetadata) {
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
  Future<wfs.StorageMetadata> getMetadata() async {
    fb.FullMetadata metadata = await _ref.getMetadata();
    return new wfs.StorageMetadata(
        bucket: metadata.bucket,
        name: metadata.name,
        path: metadata.fullPath,
        md5Hash: metadata.md5Hash,
        metadataGeneration: metadata.generation,
        customMetadata: metadata.customMetadata,
        updatedTimeMillis: metadata.updated.millisecondsSinceEpoch,
        contentLanguage: metadata.contentLanguage,
        contentDisposition: metadata.contentDisposition,
        contentEncoding: metadata.contentEncoding,
        contentType: metadata.contentType,
        cacheControl: metadata.cacheControl,
        creationTimeMillis: metadata.timeCreated.millisecondsSinceEpoch,
        generation: metadata.generation,
        sizeBytes: metadata.size);
  }

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
    return _ref.name;
  }

  @override
  Future<String> getPath() async {
    return _ref.fullPath;
  }

  @override
  Future<String> getBucket() async {
    return _ref.bucket;
  }

  @override
  wfs.StorageUploadTaskWrapper putData(Uint8List data,
      [wfs.StorageMetadata? metadata]) {
    return new StorageUploadTask(_ref.put(data));
  }

  @override
  wfs.StorageUploadTaskWrapper putFile(File file,
      [wfs.StorageMetadata? metadata]) {
    return new StorageUploadTask(_ref.put(file.readAsBytesSync()));
  }

  @override
  wfs.StorageUploadTaskWrapper put(File file, [wfs.StorageMetadata? metadata]) {
    return new StorageUploadTask(_ref.put(file.readAsBytesSync()));
  }

  @override
  wfs.StorageReferenceWrapper child(String path) {
    return new StorageReference(_ref.child(path));
  }
}

class StorageUploadTask extends wfs.StorageUploadTaskWrapper {
  fb.UploadTask _task;

  StorageUploadTask(this._task);

  @override
  Future<wfs.UploadTaskSnapshotWrapper> get future {
    return _task.future.then((fb.UploadTaskSnapshot f) async {
      return new wfs.UploadTaskSnapshotWrapper(
          downloadUrl: await f.ref.getDownloadURL());
    });
  }
}
