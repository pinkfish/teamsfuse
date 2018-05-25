import 'package:flutter_fuse/Routes.dart';
import 'package:flutter_fuse/cache/cachemanager.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/impl/databaseupdatemodelimpl.dart';
import 'package:flutter_fuse/services/loggingdata.dart';
import 'package:flutter_fuse/services/appconfiguration.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

void main() async {
  var trace = Analytics.instance.newTrace("startup");
  trace.start();

  DatabaseUpdateModel.instance = new DatabaseUpdateModelImpl();

  String currentTimeZone;
  ByteData loadedData;
  await Future.wait([
    SqlData.instance.initDatabase(),
    rootBundle.load('assets/timezone/2018c.tzf').then((ByteData data) {
      loadedData = data;
      print('loaded data');
    }),
    FlutterNativeTimezone
        .getLocalTimezone()
        .then((String str) => currentTimeZone = str)
  ]);

  initializeDatabase(loadedData.buffer.asUint8List());
  if (currentTimeZone == "GMT") {
    currentTimeZone = "Europe/London";
    setLocalLocation(getLocation(currentTimeZone));
  } else {
    setLocalLocation(getLocation(currentTimeZone));
  }
  print('$currentTimeZone ${local.toString()}');

  // Start the loading, but don't block on it,
  // although load notifications system after it has finished.
  AppConfiguration.instance.load().then((void a) {
    CacheManager.getInstance().then((CacheManager man) {
      print('got manager');
    }).catchError((Exception error) {
      print('Got error $error');
    });
    Notifications.instance.init();
  });

  Analytics.analytics.logAppOpen();

  // Send error logs up to sentry.
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingData.instance.logError(details);
  };

  trace.stop();

  new Routes();
}
