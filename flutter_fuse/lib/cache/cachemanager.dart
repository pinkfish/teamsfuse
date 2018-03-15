// CacheManager for Flutter
// Copyright (c) 2017 Rene Floor
// Released under MIT License.
library flutter_cache_manager;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:synchronized/synchronized.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'cacheobject.dart';

class CacheManager {
  static const _keyCacheData = "lib_cached_image_data";
  static const _keyCacheCleanDate = "lib_cached_image_data_last_clean";

  static Duration inBetweenCleans = new Duration(days: 7);
  static Duration maxAgeCacheObject = new Duration(days: 30);
  static int maxNrOfCacheObjects = 200;
  static bool showDebugLogs = false;

  static CacheManager _instance;
  static Future<CacheManager> getInstance() async {
    if (_instance == null) {
      await synchronized(_lock, () async {
        if (_instance == null) {
          _instance = new CacheManager._();
          await _instance._init();
        }
      });
    }
    return _instance;
  }

  CacheManager._();

  SharedPreferences _prefs;
  Map<String, CacheObject> _cacheData;
  DateTime lastCacheClean;

  static Object _lock = new Object();

  ///Shared preferences is used to keep track of the information about the files
  _init() async {
    _prefs = await SharedPreferences.getInstance();
    _getSavedCacheDataFromPreferences();
    _getLastCleanTimestampFromPreferences();
    CacheObject.initDirectory();
  }

  bool _isStoringData = false;
  bool _shouldStoreDataAgain = false;
  Object _storeLock = new Object();

  _getSavedCacheDataFromPreferences() {
    //get saved cache data from shared prefs
    var jsonCacheString = _prefs.getString(_keyCacheData);
    _cacheData = new Map();
    if (jsonCacheString != null) {
      Map jsonCache = JSON.decode(jsonCacheString);
      jsonCache.forEach((key, data) {
        _cacheData[key] = new CacheObject.fromMap(key, data);
      });
    }
  }

  ///Store all data to shared preferences
  _save() async {
    if (!(await _canSave())) {
      return;
    }

    await _cleanCache();
    await _saveDataInPrefs();
  }

  Future<bool> _canSave() async {
    return await synchronized(_storeLock, () {
      if (_isStoringData) {
        _shouldStoreDataAgain = true;
        return false;
      }
      _isStoringData = true;
      return true;
    });
  }

  Future<bool> _shouldSaveAgain() async {
    return await synchronized(_storeLock, () {
      if (_shouldStoreDataAgain) {
        _shouldStoreDataAgain = false;
        return true;
      }
      _isStoringData = false;
      return false;
    });
  }

  _saveDataInPrefs() async {
    Map<String, dynamic> json = new Map();

    await synchronized(_lock, () {
      _cacheData.forEach((key, cache) {
        if (json[key] != null) {
          json[key] = cache.toMap();
        }
      });
    });
    _prefs.setString(_keyCacheData, JSON.encode(json));

    if (await _shouldSaveAgain()) {
      await _saveDataInPrefs();
    }
  }

  _getLastCleanTimestampFromPreferences() {
    // Get data about when the last clean action has been performed
    num cleanMillis = _prefs.getInt(_keyCacheCleanDate);
    if (cleanMillis != null) {
      lastCacheClean = new DateTime.fromMillisecondsSinceEpoch(cleanMillis);
    } else {
      lastCacheClean = new DateTime.now();
      _prefs.setInt(_keyCacheCleanDate, lastCacheClean.millisecondsSinceEpoch);
    }
  }

  _cleanCache({force: false}) async {
    Duration sinceLastClean = new DateTime.now().difference(lastCacheClean);

    if (force ||
        sinceLastClean > inBetweenCleans ||
        _cacheData.length > maxNrOfCacheObjects) {
      await synchronized(_lock, () async {
        await _removeOldObjectsFromCache();
        await _shrinkLargeCache();

        lastCacheClean = new DateTime.now();
        _prefs.setInt(
            _keyCacheCleanDate, lastCacheClean.millisecondsSinceEpoch);
      });
    }
  }

  _removeOldObjectsFromCache() async {
    DateTime oldestDateAllowed = new DateTime.now().subtract(maxAgeCacheObject);

    //Remove old objects
    Iterable<CacheObject> oldValues =
        _cacheData.values.where((c) => c.touched.isBefore(oldestDateAllowed));
    for (var oldValue in oldValues) {
      await _removeFile(oldValue);
    }
  }

  _shrinkLargeCache() async {
    //Remove oldest objects when cache contains to many items
    if (_cacheData.length > maxNrOfCacheObjects) {
      var allValues = _cacheData.values.toList();
      allValues.sort(
          (c1, c2) => c1.touched.compareTo(c2.touched)); // sort OLDEST first
      var oldestValues =
          allValues.take(_cacheData.length - maxNrOfCacheObjects); // get them
      oldestValues.forEach((item) async {
        await _removeFile(item);
      }); //remove them
    }
  }

  _removeFile(CacheObject cacheObject) async {
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
      await synchronized(_lock, () {
        if (!_cacheData.containsKey(url)) {
          _cacheData[url] = new CacheObject(url);
        }
      });
    }

    var cacheObject = _cacheData[url];
    await synchronized(cacheObject.lock, () async {
      // Set touched date to show that this object is being used recently
      cacheObject.touch();

      var filePath = cacheObject.getFilePath();
      //If we have never downloaded this file, do download
      if (filePath == null) {
        print("[Flutter Cache Manager] Download first $url");

        log = "$log\nDownloading for first time.";
        _cacheData[url] = await downloadFile(url, useFirebase);
        return;
      }
      //If file is removed from the cache storage, download again
      var cachedFile = new File(filePath);
      var cachedFileExists = await cachedFile.exists();
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
        var newCacheData = await downloadFile(url, useFirebase,
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
    var newCache = new CacheObject(url);
    newCache.setRelativePath(relativePath);
    var headers = new Map<String, String>();
    if (eTag != null) {
      headers["If-None-Match"] = eTag;
    }

    var response;
    try {
      if (useFirebase) {
        FirebaseStorage.instance.ref().child(url).getDownlodUrl();
      } else {
        response = await http.get(url, headers: headers);
      }
    } catch (e) {}
    if (response != null) {
      if (response.statusCode == 200) {
        await newCache.setDataFromHeaders(response.headers);

        var filePath = newCache.getFilePath();
        var folder = new File(filePath).parent;
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
