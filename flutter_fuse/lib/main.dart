import 'package:flutter_fuse/Routes.dart';
import 'package:flutter_fuse/cache/cachemanager.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/impl/databaseupdatemodelimpl.dart';
import 'package:sentry/sentry.dart';
import 'package:flutter_fuse/services/loggingdata.dart';

final SentryClient sentry = new SentryClient(
    dsn:
        'https://5691b440eb64430d9ba2917166fa17a1:7978cf6a0a5a4f7ab7702a51f524620a@sentry.io/1200691');

void main() {
  CacheManager.getInstance().then((CacheManager man) {
    print('got manager');
  }).catchError((Exception error) {
    print('Got error $error');
  });

  DatabaseUpdateModel.instance = new DatabaseUpdateModelImpl();

  Future.wait([SqlData.instance.initDatabase()]);

  Analytics.analytics.logAppOpen();

  Notifications.instance.init();

  // Send error logs up to sentry.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    final Event event = new Event(
      release: LoggingData.instance.packageInfo.version,
      exception: details.exception,
      stackTrace: details.stack,
      extra: LoggingData.instance.extra,
      tags: LoggingData.instance.tags
    );
    sentry.capture(event: event);
  };

  new Routes();
}
