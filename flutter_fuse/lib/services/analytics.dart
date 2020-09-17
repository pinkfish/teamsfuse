import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:package_info/package_info.dart';

///
/// Analytics class to handle communication with the analytics subsystems
/// adding in all the various pieces.
///
class Analytics extends AnalyticsSubsystem {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static Analytics _instance;

  PackageInfo _packageInfo;
  DeviceInfoPlugin _deviceInfo;
  IosDeviceInfo _iosDeviceInfo;
  AndroidDeviceInfo _androidDeviceInfo;
  bool _debugMode = false;

  /// The instance of the analytics system to use.
  static Analytics get instance {
    if (_instance == null) {
      _instance = Analytics();
      _instance._load();
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    }

    return _instance;
  }

  void _load() {
    assert(_debugMode = true);

    // Load the device and package info.
    _packageInfo = PackageInfo(
        version: "unknown", packageName: "unknown", buildNumber: "unknown");
    PackageInfo.fromPlatform().then((info) {
      _packageInfo = info;
    });

    _deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      _deviceInfo.iosInfo.then((info) {
        _iosDeviceInfo = info;
      });
    }
    if (Platform.isAndroid) {
      _deviceInfo.androidInfo.then((info) {
        _androidDeviceInfo = info;
      });
    }
  }

  /// Returns the firebase analytics part to use in the system.
  static FirebaseAnalytics get analytics {
    return _analytics;
  }

  @override
  void logSignUp({String signUpMethod}) {
    _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  @override
  void logLogin() {
    _analytics.logLogin();
  }

  @override
  void setUserId(String uid) {
    _analytics.setUserId(uid);
  }

  @override
  void setUserProperty({String name, String value}) {
    _analytics.setUserProperty(name: name, value: value);
  }

  @override
  bool get debugMode {
    return _debugMode;
  }

  @override
  TraceProxy newTrace(String name) {
    var trace = FirebasePerformance.instance.newTrace(name);

    trace.putAttribute("os", Platform.operatingSystem);
    trace.putAttribute("osVersion", Platform.operatingSystemVersion);

    trace.putAttribute("version", _packageInfo.version);
    trace.putAttribute("build", _packageInfo.buildNumber);
    if (Platform.isIOS && _iosDeviceInfo != null) {
      trace.putAttribute(
          "emulator", _iosDeviceInfo.isPhysicalDevice.toString());
    }
    if (Platform.isAndroid && _androidDeviceInfo != null) {
      trace.putAttribute(
          "emulator", _androidDeviceInfo.isPhysicalDevice.toString());
    }
    return FirebaseTrace(trace);
  }

  ///
  /// Gets a version string to use for the app.
  ///
  String getVersion() {
    if (Platform.isAndroid) {
      return _androidDeviceInfo.version.release;
    }
    if (Platform.isIOS) {
      return _iosDeviceInfo.utsname.version;
    }
    return _packageInfo.version;
  }
}

///
/// Wrapped for the tracing in firebase to add in local stats and info
/// on top.
///
class FirebaseTrace implements TraceProxy {
  /// Creates the firebase trace with the internal tracing piece.
  FirebaseTrace(this._trace);

  final Trace _trace;

  @override
  void start() {
    _trace.start();
  }

  @override
  void incrementCounter(String str) {
    _trace.incrementMetric(str, 1);
  }

  @override
  void stop() {
    _trace.stop();
  }
}
