import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:fusemodel/fusemodel.dart';

class Analytics extends AnalyticsSubsystem {
  static FirebaseAnalytics _analytics = new FirebaseAnalytics();
  static Analytics _instance;

  PackageInfo packageInfo;
  DeviceInfoPlugin deviceInfo;
  IosDeviceInfo iosDeviceInfo;
  AndroidDeviceInfo androidDeviceInfo;
  bool debugMode;

  static Analytics get instance {
    if (_instance == null) {
      _instance = new Analytics();
      _instance.load();
      FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    }

    return _instance;
  }

  void load() {
    assert(debugMode = true);

    // Load the device and package info.
    packageInfo = new PackageInfo(
        version: "unknown", packageName: "unknown", buildNumber: "unknown");
    PackageInfo.fromPlatform().then((PackageInfo info) {
      packageInfo = info;
    });

    deviceInfo = new DeviceInfoPlugin();
    if (Platform.isIOS) {
      deviceInfo.iosInfo.then((IosDeviceInfo info) {
        iosDeviceInfo = info;
      });
    }
    if (Platform.isAndroid) {
      deviceInfo.androidInfo.then((AndroidDeviceInfo info) {
        androidDeviceInfo = info;
      });
    }
  }

  static FirebaseAnalytics get analytics {
    return _analytics;
  }

  @override
  void logSignUp({String signUpMethod}) {
    _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  @override
  TraceProxy newTrace(String name) {
    Trace trace = FirebasePerformance.instance.newTrace(name);

    trace.putAttribute("os", Platform.operatingSystem);
    trace.putAttribute(
        "osVersion", Platform.operatingSystemVersion.substring(0, 30));

    trace.putAttribute("version", packageInfo.version);
    trace.putAttribute("build", packageInfo.buildNumber);
    if (Platform.isIOS && iosDeviceInfo != null) {
      trace.putAttribute("emulator", iosDeviceInfo.isPhysicalDevice.toString());
    }
    if (Platform.isAndroid && androidDeviceInfo != null) {
      trace.putAttribute(
          "emulator", androidDeviceInfo.isPhysicalDevice.toString());
    }
    return new FirebaseTrace(trace);
  }

  String getVersion() {
    if (Platform.isAndroid) {
      return androidDeviceInfo.version.release;
    }
    if (Platform.isIOS) {
      return iosDeviceInfo.utsname.version;
    }
    return packageInfo.version;
  }
}

class FirebaseTrace implements TraceProxy {
  Trace trace;
  FirebaseTrace(this.trace);

  @override
  void start() {
    trace.start();
  }

  @override
  void incrementCounter(String str) {
    trace.incrementCounter(str);
  }

  @override
  void stop() {
    trace.stop();
  }
}
