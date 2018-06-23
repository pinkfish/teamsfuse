// CacheManager for Flutter
// Copyright (c) 2017 Rene Floor
// Released under MIT License.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:synchronized/synchronized.dart';

///Cache information of one file
class CacheObject {
  static const String _keyFilePath = "relativePath";
  static const String _keyValidTill = "validTill";
  static const String _keyETag = "ETag";
  static const String _keyTouched = "touched";
  static Directory _directory;

  String relativePath;
  DateTime validTill;
  String eTag;
  DateTime touched;
  String url;
  Lock lock;

  CacheObject(this.url) {
    touch();
    lock = new Lock();
  }

  CacheObject.fromMap(this.url, Map<dynamic, dynamic> map) {
    if (map.containsKey(_keyFilePath)) {
      relativePath = map[_keyFilePath].toString();
    }
    if (map.containsKey(_keyValidTill)) {
      validTill =
          new DateTime.fromMillisecondsSinceEpoch(map[_keyValidTill] as int);
    }
    if (map.containsKey(_keyETag)) {
      eTag = map[_keyETag].toString();
    }
    if (map.containsKey(_keyTouched)) {
      touched =
          new DateTime.fromMillisecondsSinceEpoch(map[_keyTouched] as int);
    } else {
      touch();
    }

    lock = new Lock();
  }

  static void initDirectory() async {
    _directory = await getTemporaryDirectory();
  }

  String getFilePath() {
    if (relativePath == null) {
      return null;
    }

    return _directory.path + relativePath;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[_keyETag] = eTag;
    ret[_keyValidTill] = validTill?.millisecondsSinceEpoch;
    ret[_keyTouched] = touched?.millisecondsSinceEpoch;
    ret[_keyFilePath] = relativePath;
    return ret;
  }

  void touch() {
    touched = new DateTime.now();
  }

  void setDataFromHeaders(Map<String, String> headers) async {
    //Without a cache-control header we keep the file for a week
    Duration ageDuration = new Duration(days: 7);

    if (headers.containsKey("cache-control")) {
      String cacheControl = headers["cache-control"];
      List<String> controlSettings = cacheControl.split(", ");
      for (String setting in controlSettings) {
        if (setting.startsWith("max-age=")) {
          int validSeconds = int.tryParse(setting.split("=")[1]) ?? 0;

          if (validSeconds > 0) {
            ageDuration = new Duration(seconds: validSeconds);
          }
        }
      }
    }

    validTill = new DateTime.now().add(ageDuration);

    if (headers.containsKey("etag")) {
      eTag = headers["etag"];
    }

    String fileExtension = "";
    if (headers.containsKey("content-type")) {
      List<String> type = headers["content-type"].split("/");
      if (type.length == 2) {
        fileExtension = ".${type[1]}";
      }
    }

    String oldPath = getFilePath();
    if (oldPath != null && !oldPath.endsWith(fileExtension)) {
      removeOldFile(oldPath);
      relativePath = null;
    }

    if (relativePath == null) {
      relativePath = "cache/${new Uuid().v1()}$fileExtension";
    }
  }

  void removeOldFile(String filePath) async {
    File file = new File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void setRelativePath(String path) {
    relativePath = path;
  }
}
