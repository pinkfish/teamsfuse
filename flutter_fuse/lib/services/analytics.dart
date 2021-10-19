import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:package_info/package_info.dart';
import 'package:universal_io/io.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class _MyPackageInfo {
  /// The version of the package
  String version;

  /// The build number to use.
  String buildNumber;

  _MyPackageInfo({this.version, this.buildNumber});
}

///
/// Analytics class to handle communication with the analytics subsystems
/// adding in all the various pieces.
///
class AnalyticsSubsystemImpl extends AnalyticsSubsystem {
  static AnalyticsSubsystemImpl _instance;

  _MyPackageInfo _packageInfo;
  DeviceInfoPlugin _deviceInfo;
  IosDeviceInfo _iosDeviceInfo;
  AndroidDeviceInfo _androidDeviceInfo;
  final FirebaseAnalytics _analytics;
  bool _debugMode = false;
  String _userId;

  AnalyticsSubsystemImpl(this._analytics);

  /// The instance of the analytics system to use.
  static Future<AnalyticsSubsystemImpl> create(
      FirebaseAnalytics analytics) async {
    if (_instance == null) {
      if (kIsWeb) {
        await SentryFlutter.init((options) => options
          ..dsn = Platform.environment['SENTRY_DSN'].replaceAll('"', ''));
      }
      _instance = AnalyticsSubsystemImpl(analytics);
      _instance._load();
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    }

    return _instance;
  }

  /// Sets the user id locally an in the firebase system.
  Future<void> setUserId(String userId) {
    _userId = userId;
    return firebase.setUserId(userId);
  }

  String getUserId() {
    return _userId;
  }

  FirebaseAnalytics get firebase => _analytics;

  void _load() {
    assert(_debugMode = true);

    // Load the device and package info.
    _packageInfo = _MyPackageInfo(
        version: Platform.operatingSystem, buildNumber: 'unknown');

    _deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      // Do web specific stuff in here.
    } else if (Platform.isIOS) {
      PackageInfo.fromPlatform().then((info) {
        _packageInfo = _MyPackageInfo(
          version: info.version,
          buildNumber: info.buildNumber,
        );
      });
      _deviceInfo.iosInfo.then((info) {
        _iosDeviceInfo = info;
      });
    } else if (Platform.isAndroid) {
      PackageInfo.fromPlatform().then((info) {
        _packageInfo = _MyPackageInfo(
          version: info.version,
          buildNumber: info.buildNumber,
        );
      });
      _deviceInfo.androidInfo.then((info) {
        _androidDeviceInfo = info;
      });
    }
  }

  @override
  Future<void> logSignUp({String signUpMethod}) async {
    return _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  @override
  Future<void> logLogin() async {
    return _analytics.logLogin();
  }

  Future<void> logAppOpen() async {
    return _analytics.logAppOpen();
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

    if (kIsWeb) {
      trace.putAttribute('os', 'web');
      trace.putAttribute('osVersion', 'x.x');
    } else {
      trace.putAttribute('os', Platform.operatingSystem);
      trace.putAttribute('osVersion', Platform.operatingSystemVersion);
    }

    trace.putAttribute('version', _packageInfo.version);
    trace.putAttribute('build', _packageInfo.buildNumber);
    if (Platform.isIOS && _iosDeviceInfo != null) {
      trace.putAttribute(
          'emulator', _iosDeviceInfo.isPhysicalDevice.toString());
    }
    if (Platform.isAndroid && _androidDeviceInfo != null) {
      trace.putAttribute(
          'emulator', _androidDeviceInfo.isPhysicalDevice.toString());
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

  ///
  /// Log an event to analytics for details on what is going on.
  ///
  @override
  Future<void> logEvent({String name, Map<String, String> parameters}) async {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logInviteAccepted(String inviteType, String invitedTo) async {
    return _analytics.logShare(
        contentType: inviteType, itemId: invitedTo, method: 'invite');
  }

  @override
  void recordError(Error error, StackTrace stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    } else {
      Sentry.captureException(error, stackTrace: stack);
    }
  }

  @override
  void recordException(dynamic error, StackTrace stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    } else {
      Sentry.captureException(error, stackTrace: stack);
    }
  }
}

///
/// The empty firebase trace for web stuff.
///
class EmptyFirebaseTrace implements TraceProxy {
  @override
  void incrementCounter(String str) {}

  @override
  void start() {}

  @override
  void stop() {}
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
    if (Platform.isAndroid || Platform.isIOS) {
      _trace.start();
    }
  }

  @override
  void incrementCounter(String str) {
    if (Platform.isAndroid || Platform.isIOS) {
      _trace.incrementMetric(str, 1);
    }
  }

  @override
  void stop() {
    if (Platform.isAndroid || Platform.isIOS) {
      _trace.stop();
    }
  }
}
