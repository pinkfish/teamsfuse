// CacheManager for Flutter
// Copyright (c) 2017 Rene Floor
// Released under MIT License.
library flutter_cache_manager;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_fuse/services/appconfiguration.dart';

import 'cacheobject.dart';

class CacheManager {
  static const String _keyCacheData = "lib_cached_image_data";
  static const String _keyCacheCleanDate = "lib_cached_image_data_last_clean";

  static Duration inBetweenCleans = new Duration(days: 7);
  static Duration maxAgeCacheObject = new Duration(days: 30);
  static int maxNrOfCacheObjects = 200;
  static bool showDebugLogs = false;

  static CacheManager _instance;

  CacheManager._();

  static Future<CacheManager> getInstance() async {
    if (_instance == null) {
      await _lock.synchronized(() async {
        if (_instance == null) {
          _instance = new CacheManager._();
          await _instance._init();
        }
      });
    }
    return _instance;
  }

  Map<String, CacheObject> _cacheData;
  DateTime lastCacheClean;

  static Lock _lock = new Lock();

  ///Shared preferences is used to keep track of the information about the files
  void _init() async {
    _getSavedCacheDataFromPreferences();
    _getLastCleanTimestampFromPreferences();
    CacheObject.initDirectory();
  }

  bool _isStoringData = false;
  bool _shouldStoreDataAgain = false;
  Lock _storeLock = new Lock();

  void _getSavedCacheDataFromPreferences() {
    //get saved cache data from shared prefs
    String jsonCacheString =
        AppConfiguration.instance.sharedPreferences.getString(_keyCacheData);
    _cacheData = <String, CacheObject>{};
    if (jsonCacheString != null) {
      Map<String, dynamic> jsonCache = json.decode(jsonCacheString);
      jsonCache.forEach((String keyOb, dynamic dataOb) {
        _cacheData[keyOb] =
            new CacheObject.fromMap(keyOb, dataOb as Map<dynamic, dynamic>);
      });
    }
  }

  ///Store all data to shared preferences
  void _save() async {
    if (!(await _canSave())) {
      return;
    }

    await _cleanCache();
    await _saveDataInPrefs();
  }

  Future<bool> _canSave() async {
    return _storeLock. synchronized(() {
      if (_isStoringData) {
        _shouldStoreDataAgain = true;
        return false;
      }
      _isStoringData = true;
      return true;
    });
  }

  Future<bool> _shouldSaveAgain() async {
    return _storeLock.synchronized(() {
      if (_shouldStoreDataAgain) {
        _shouldStoreDataAgain = false;
        return true;
      }
      _isStoringData = false;
      return false;
    });
  }

  void _saveDataInPrefs() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};

    await _lock.synchronized(() {
      _cacheData.forEach((String key, CacheObject cache) {
        if (jsonMap[key] != null) {
          jsonMap[key] = cache.toMap();
        }
      });
    });
    AppConfiguration.instance.sharedPreferences
        .setString(_keyCacheData, json.encode(jsonMap));

    if (await _shouldSaveAgain()) {
      await _saveDataInPrefs();
    }
  }

  void _getLastCleanTimestampFromPreferences() {
    // Get data about when the last clean action has been performed
    int cleanMillis =
        AppConfiguration.instance.sharedPreferences.getInt(_keyCacheCleanDate);
    if (cleanMillis != null) {
      lastCacheClean = new DateTime.fromMillisecondsSinceEpoch(cleanMillis);
    } else {
      lastCacheClean = new DateTime.now();
      AppConfiguration.instance.sharedPreferences
          .setInt(_keyCacheCleanDate, lastCacheClean.millisecondsSinceEpoch);
    }
  }

  void _cleanCache({bool force: false}) async {
    Duration sinceLastClean = new DateTime.now().difference(lastCacheClean);

    if (force ||
        sinceLastClean > inBetweenCleans ||
        _cacheData.length > maxNrOfCacheObjects) {
      await _lock.synchronized( () async {
        await _removeOldObjectsFromCache();
        await _shrinkLargeCache();

        lastCacheClean = new DateTime.now();
        AppConfiguration.instance.sharedPreferences
            .setInt(_keyCacheCleanDate, lastCacheClean.millisecondsSinceEpoch);
      });
    }
  }

  void _removeOldObjectsFromCache() async {
    DateTime oldestDateAllowed = new DateTime.now().subtract(maxAgeCacheObject);

    //Remove old objects
    Iterable<CacheObject> oldValues = _cacheData.values.where(
        (CacheObject c) => c == null || c.touched.isBefore(oldestDateAllowed));
    for (CacheObject oldValue in oldValues) {
      await _removeFile(oldValue);
    }
  }

  void _shrinkLargeCache() async {
    //Remove oldest objects when cache contains to many items
    if (_cacheData.length > maxNrOfCacheObjects) {
      List<CacheObject> allValues = _cacheData.values.toList();
      allValues.sort((CacheObject c1, CacheObject c2) =>
          c1.touched.compareTo(c2.touched)); // sort OLDEST first
      Iterable<CacheObject> oldestValues =
          allValues.take(_cacheData.length - maxNrOfCacheObjects); // get them
      for (CacheObject item in oldestValues) {
        await _removeFile(item);
      } //remove them
    }
  }

  void _removeFile(CacheObject cacheObject) async {
    //Ensure the file has been downloaded
    if (cacheObject.relativePath == null) {
      return;
    }

    _cacheData.remove(cacheObject.url);

    File file = new File(cacheObject.getFilePath());
    if (await file.exists()) {
      file.delete();
    }
  }

  /// Figure out if the file is cached or not.
  Future<bool> isCached(String url) async {
    if (_cacheData.containsKey(url)) {
      CacheObject cacheObject = _cacheData[url];
      String filePath = cacheObject.getFilePath();
      if (filePath != null) {
        File cachedFile = new File(filePath);
        return await cachedFile.exists();
      }
    }
    return false;
  }

  ///Get the file from the cache or online. Depending on availability and age
  ///If it fails, will return null
  Future<File> getFile(String url, {bool useFirebase = false}) async {
    print("[Flutter Cache Manager] Loading $url");
    String log;
    if (!_cacheData.containsKey(url)) {
      await _lock.synchronized( () {
        if (!_cacheData.containsKey(url)) {
          _cacheData[url] = new CacheObject(url);
        }
      });
    }

    CacheObject cacheObject = _cacheData[url];
    await cacheObject.lock.synchronized( () async {
      // Set touched date to show that this object is being used recently
      cacheObject.touch();

      String filePath = cacheObject.getFilePath();
      //If we have never downloaded this file, do download
      if (filePath == null) {
        print("[Flutter Cache Manager] Download first $url");

        log = "$log\nDownloading for first time.";
        _cacheData[url] = await downloadFile(url, useFirebase);
        return;
      }
      //If file is removed from the cache storage, download again
      File cachedFile = new File(filePath);
      bool cachedFileExists = await cachedFile.exists();
      if (!cachedFileExists) {
        log = "$log\nDownloading because file does not exist.";
        _cacheData[url] = await downloadFile(url, useFirebase,
            relativePath: cacheObject.relativePath);

        log =
            "$log\Cache file valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
        return;
      }
      //If file is old, download if server has newer one
      if (cacheObject.validTill == null ||
          cacheObject.validTill.isBefore(new DateTime.now())) {
        log = "$log\nUpdating file in cache.";
        CacheObject newCacheData = await downloadFile(url, useFirebase,
            relativePath: cacheObject.relativePath, eTag: cacheObject.eTag);
        if (newCacheData != null) {
          _cacheData[url] = newCacheData;
        }
        log =
            "$log\nNew cache file valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
        return;
      }
      log =
          "$log\nUsing file from cache.\nCache valid till ${_cacheData[url].validTill?.toIso8601String() ?? "only once.. :("}";
    });

    //If non of the above is true, than we don't have to download anything.
    _save();
    if (showDebugLogs) {
      print(log);
    }
    CacheObject ob = _cacheData[url];
    if (ob == null) {
      return null;
    }
    String fname = ob.getFilePath();
    if (fname == null) {
      return null;
    }
    return new File(fname);
  }

  ///Download the file from the url
  Future<CacheObject> downloadFile(String url, bool useFirebase,
      {String relativePath, String eTag}) async {
    print("[Flutter Cache Manager] Download file $url");
    CacheObject newCache = new CacheObject(url);
    newCache.setRelativePath(relativePath);
    Map<String, String> headers = <String, String>{};
    if (eTag != null) {
      headers["If-None-Match"] = eTag;
    }

    http.Response response;
    try {
      if (useFirebase) {
        FirebaseStorage.instance.ref().child(url).getDownloadURL();
      } else {
        response = await http.get(url, headers: headers);
      }
    } catch (e) {}
    if (response != null) {
      if (response.statusCode == 200) {
        await newCache.setDataFromHeaders(response.headers);

        String filePath = newCache.getFilePath();
        Directory folder = new File(filePath).parent;
        if (!(await folder.exists())) {
          folder.createSync(recursive: true);
        }
        await new File(filePath).writeAsBytes(response.bodyBytes);

        return newCache;
      }
      if (response.statusCode == 304) {
        await newCache.setDataFromHeaders(response.headers);
        return newCache;
      }
    }

    return null;
  }
}
