import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_fuse/Routes.dart';
import 'package:flutter_fuse/cache/cachemanager.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/appconfiguration.dart';
import 'package:flutter_fuse/services/firestore/firestore.dart' as fs;
import 'package:flutter_fuse/services/loggingdata.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

void main() async {
  TraceProxy trace = Analytics.instance.newTrace("startup");
  trace.start();

  String currentTimeZone;
  ByteData loadedData;
  await Future.wait<dynamic>(<Future<dynamic>>[
    SqlData.instance.initDatabase(),
    rootBundle
        .load('assets/timezone/2018c.tzf')
        .then<ByteData>((ByteData data) {
      loadedData = data;
      print('loaded data');
      return data;
    }),
    FlutterNativeTimezone.getLocalTimezone()
        .then<String>((String str) => currentTimeZone = str)
  ]);

  // Timezone
  initializeDatabase(loadedData.buffer.asUint8List());
  if (currentTimeZone == "GMT") {
    currentTimeZone = "Europe/London";
    setLocalLocation(getLocation(currentTimeZone));
  } else {
    setLocalLocation(getLocation(currentTimeZone));
  }
  print('$currentTimeZone ${local.toString()}');

  // database
  print('Making stuff in here');
  // Setup the timestamps correctly.
  await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);

  UserDatabaseData.instance = new UserDatabaseData(Analytics.instance,
      LoggingData.instance, SqlData.instance, new fs.Firestore());

  // Start the loading, but don't block on it,
  // Load notifications after the app config has loaded.
  AppConfiguration.instance.load().then((void a) {
    CacheManager.getInstance().then((CacheManager man) {
      print('got manager');
    }).catchError((dynamic error) {
      print('Got error $error');
    });
    Notifications.instance.init();
  });

  Analytics.analytics.logAppOpen();

  // Send error logs up to sentry.
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingData.instance.logFlutterError(details);
  };

  // Wait till the user has loaded from firebase.
  UserData data = await UserDatabaseData.instance.userAuth.currentUser();

  // License for the freepik picture.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        null, "Designed by FreePik\nwww.freepik.com ");
  });
  trace.stop();

  new Routes(data);
}
