part of firestore_wrapper;

/// Metadata for a [StorageReference]. Metadata stores default attributes such as
/// size and content type.
class StorageMetadata {
  StorageMetadata({
    this.bucket,
    this.generation,
    this.metadataGeneration,
    this.name,
    this.path,
    this.sizeBytes,
    this.creationTimeMillis,
    this.updatedTimeMillis,
    this.md5Hash,
    this.customMetadata,
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.contentType,
  });

  /// The owning Google Cloud Storage bucket for the [StorageReference].
  final String bucket;

  /// A version String indicating what version of the [StorageReference].
  final String generation;

  /// A version String indicating the version of this [StorageMetadata].
  final String metadataGeneration;

  /// The path of the [StorageReference] object.
  final String path;

  /// A simple name of the [StorageReference] object.
  final String name;

  /// The stored Size in bytes of the [StorageReference] object.
  final int sizeBytes;

  /// The time the [StorageReference] was created in milliseconds since the epoch.
  final int creationTimeMillis;

  /// The time the [StorageReference] was last updated in milliseconds since the epoch.
  final int updatedTimeMillis;

  /// The MD5Hash of the [StorageReference] object.
  final String md5Hash;

  /// The Cache Control setting of the [StorageReference].
  final String cacheControl;

  /// The content disposition of the [StorageReference].
  final String contentDisposition;

  /// The content encoding for the [StorageReference].
  final String contentEncoding;

  /// The content language for the StorageReference, specified as a 2-letter
  /// lowercase language code defined by ISO 639-1.
  final String contentLanguage;

  /// The content type (MIME type) of the [StorageReference].
  final String contentType;

  /// An unmodifiable map with custom metadata for the [StorageReference].
  final Map<String, String> customMetadata;
}