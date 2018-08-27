part of firestore_wrapper;

abstract class StorageReferenceWrapper {
  /// Returns a new instance of [StorageReference] pointing to a child
  /// location of the current reference.
  StorageReferenceWrapper child(String path);


  /// This method is deprecated. Please use [putFile] instead.
  ///
  /// Asynchronously uploads a file to the currently specified
  /// [StorageReference], with an optional [metadata].
  @deprecated
  StorageUploadTaskWrapper put(File file, [StorageMetadata metadata]);

  /// Asynchronously uploads a file to the currently specified
  /// [StorageReference], with an optional [metadata].
  StorageUploadTaskWrapper putFile(File file, [StorageMetadata metadata]) ;

  /// Asynchronously uploads byte data to the currently specified
  /// [StorageReference], with an optional [metadata].
  StorageUploadTaskWrapper putData(Uint8List data, [StorageMetadata metadata]);

  /// Returns the Google Cloud Storage bucket that holds this object.
  Future<String> getBucket();

  /// Returns the full path to this object, not including the Google Cloud
  /// Storage bucket.
  Future<String> getPath();

  /// Returns the short name of this object.
  Future<String> getName();

  /// Asynchronously retrieves a long lived download URL with a revokable token.
  /// This can be used to share the file with others, but can be revoked by a
  /// developer in the Firebase Console if desired.
  Future<dynamic> getDownloadURL();

  Future<void> delete();

  /// Retrieves metadata associated with an object at this [StorageReference].
  Future<StorageMetadata> getMetadata();

  /// Updates the metadata associated with this [StorageReference].
  ///
  /// Returns a [Future] that will complete to the updated [StorageMetadata].
  ///
  /// This method ignores fields of [metadata] that cannot be set by the public
  /// [StorageMetadata] constructor. Writable metadata properties can be deleted
  /// by passing the empty string.
  Future<StorageMetadata> updateMetadata(StorageMetadata metadata) ;

  String get path;
}