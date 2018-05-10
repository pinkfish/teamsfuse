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

void main() {
  var trace = Analytics.instance.newTrace("startup");
  trace.start();
  CacheManager.getInstance().then((CacheManager man) {
    print('got manager');
  }).catchError((Exception error) {
    print('Got error $error');
  });

  DatabaseUpdateModel.instance = new DatabaseUpdateModelImpl();

  Future.wait([SqlData.instance.initDatabase()]);

  // Start the loading, but don't block on it.
  AppConfiguration.instance.load();

  Analytics.analytics.logAppOpen();

  Notifications.instance.init();

  // Send error logs up to sentry.
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggingData.instance.logError(details);
  };

  trace.stop();

  new Routes();
}
