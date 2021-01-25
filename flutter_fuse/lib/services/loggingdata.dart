import 'package:device_info/device_info.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:package_info/package_info.dart';
import 'package:universal_io/io.dart';

///
/// Logging data for the database.
///
class LoggingData extends LoggingDataBase {
  /// Constrctor for the logging data.
  LoggingData() {
    var plugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      _tags["ios"] = Platform.operatingSystemVersion;
      plugin.iosInfo.then((info) {
        _extra["deviceInfo"] = <String, dynamic>{
          "model": info.model,
          "name": info.name,
          "systemName": info.systemName,
          "systemVersion": info.systemVersion,
          "localizedModel": info.localizedModel,
          "identifierForVendor": info.identifierForVendor,
          "utsname": <String, String>{
            "sysname": info.utsname.sysname,
            "nodename": info.utsname.nodename,
            "release": info.utsname.release,
            "version": info.utsname.version,
            "machine": info.utsname.machine,
          }
        };
        _tags["model"] = info.model;
        _tags["realDevice"] = info.isPhysicalDevice.toString();
        _realDevice = info.isPhysicalDevice;
      });
    }
    if (Platform.isAndroid) {
      _tags["android"] = Platform.operatingSystemVersion;
      plugin.androidInfo.then((info) {
        _extra["deviceInfo"] = <String, dynamic>{
          "version": <String, dynamic>{
            "baseOS": info.version.baseOS,
            "codename": info.version.codename,
            "incremental": info.version.incremental,
            "previewSdkInt": info.version.previewSdkInt,
            "release": info.version.release,
            "sdkInt": info.version.sdkInt,
            "securityPatch": info.version.securityPatch,
          },
          "board": info.board,
          "bootloader": info.bootloader,
          "brand": info.brand,
          "device": info.device,
          "display": info.display,
          "fingerprint": info.fingerprint,
          "hardware": info.hardware,
          "host": info.host,
          "id": info.id,
          "manufacturer": info.manufacturer,
          "model": info.model,
          "product": info.product,
          "tags": info.tags,
          "type": info.type,
        };
        _tags["model"] = info.model;
        _tags["realDevice"] = info.isPhysicalDevice.toString();
        _realDevice = info.isPhysicalDevice;
      });
    }
    _tags["locale"] = Platform.localeName;
    _packageInfo = PackageInfo(
        version: "unknown", packageName: "unknown", buildNumber: "unknown");
    PackageInfo.fromPlatform().then((info) {
      _tags["buildNumber"] = info.buildNumber;
      _tags["packageName"] = info.packageName;
      _packageInfo = info;
    });

    // Fill in the scope for sentry.
  }

  void start() async {
    if (kDebugMode) {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      for (var item in _extra.entries) {
        FirebaseCrashlytics.instance.setCustomKey(item.key, item.value);
      }
      for (var tag in _tags.entries) {
        FirebaseCrashlytics.instance.setCustomKey(tag.key, tag.value);
      }
      FirebaseCrashlytics.instance
          .setCustomKey("release", _packageInfo.version);
    }
  }

  final Map<String, dynamic> _extra = <String, dynamic>{};
  final Map<String, String> _tags = <String, String>{};
  PackageInfo _packageInfo;
  bool _realDevice = true;
  final bool _debugMode = false;

  /// Sets the last path used.
  set lastPath(String path) => _extra["lastPath"] = path;

  /// Gets the last path used.
  String get lastPath => _extra["lastPath"].toString();

  /// Logs a flutter error up to the logging service.
  void logFlutterError(FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details, forceReport: true);
    // Don't capture on emulators.
    if (_realDevice && !_debugMode) {
      FirebaseCrashlytics.instance.setCustomKey("lastpath", lastPath);
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  }

  @override
  void logError(FusedErrorDetails details) async {
    // Don't capture on emulators.
    if (_realDevice && !_debugMode) {
      FirebaseCrashlytics.instance.setCustomKey("lastpath", lastPath);

      FirebaseCrashlytics.instance
          .recordError(details.exception, details.stack);
    }
  }
}
