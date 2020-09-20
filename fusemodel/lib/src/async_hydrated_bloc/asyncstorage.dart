import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive/src/hive_impl.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

/// Interface which is used to persist and retrieve state changes.
abstract class AsyncStorage {
  /// Returns value for key
  Future<dynamic> read(String key);

  /// Persists key value pair
  Future<void> write(String key, dynamic value);

  /// Deletes key value pair
  Future<void> delete(String key);

  /// Clears all key value pairs from storage
  Future<void> clear();
}

/// {@template hydrated_cubit_storage}
/// Implementation of [Storage] which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
/// {@endtemplate}
class AsyncHydratedStorage implements AsyncStorage {
  final String boxName;

  static Directory storageDirectory;
  static HydratedCipher encryptionCipher;

  /// Returns an instance of [HydratedStorage].
  /// [storageDirectory] can optionally be provided.
  /// By default, [getTemporaryDirectory] is used.
  ///
  /// With [encryptionCipher] you can provide custom encryption.
  /// Following snippet shows how to make default one:
  /// ```dart
  /// import 'package:crypto/crypto.dart';
  /// import 'package:hydrated_cubit/hydrated_cubit.dart';
  ///
  /// const password = 'hydration';
  /// final byteskey = sha256.convert(utf8.encode(password)).bytes;
  /// return HydratedAesCipher(byteskey);
  /// ```
  AsyncHydratedStorage(this.boxName) : _box = null {
    _lock.synchronized(() async {
      // Use HiveImpl directly to avoid conflicts with existing Hive.init
      // https://github.com/hivedb/hive/issues/336
      hive = HiveImpl();
      Box<dynamic> box;
      if (isWeb) {
        box = await hive.openBox<dynamic>(
          "${runtimeType.toString()}.$boxName",
          encryptionCipher: encryptionCipher,
        );
      } else {
        final directory = storageDirectory ?? await getTemporaryDirectory();
        hive.init(directory.path + "/async");
        box = await hive.openBox<dynamic>(
          "${runtimeType.toString()}.$boxName",
          encryptionCipher: encryptionCipher,
        );
      }
      _box = box;
    });
  }

  ///
  /// Close out the box and cleanup.
  ///
  Future<void> dispose() {
    return _box?.close();
  }

  /// Internal flag which determines if running on the web platform.
  /// Defaults to [kIsWeb] and is only visible for testing purposes.
  @visibleForTesting
  static bool isWeb = kIsWeb;

  /// Internal instance of [HiveImpl].
  /// It should only be used for testing.
  @visibleForTesting
  static HiveInterface hive;

  static final _lock = Lock();

  Box _box;

  @override
  Future<dynamic> read(String key) async {
    return _lock.synchronized(() async {
      return _box.isOpen ? _box.get(key) : null;
    });
  }

  @override
  Future<void> write(String key, dynamic value) {
    return _lock.synchronized(() async {
      if (_box.isOpen) {
        return _lock.synchronized(() => _box.put(key, value));
      }
      return null;
    });
  }

  @override
  Future<void> delete(String key) {
    if (_box.isOpen) {
      return _lock.synchronized(() => _box.delete(key));
    }
    return null;
  }

  @override
  Future<void> clear() {
    if (_box.isOpen) {
      return _lock.synchronized(_box.deleteFromDisk);
    }
    return null;
  }
}
