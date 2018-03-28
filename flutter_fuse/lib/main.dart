import 'package:flutter_fuse/Routes.dart';
import 'package:flutter_fuse/cache/cachemanager.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'dart:async';

void main() {
  CacheManager.getInstance().then((CacheManager man) {
    print('got manager');
  }).catchError((Exception error) {
    print('Got error $error');
  });

  Future.wait([SqlData.instance.initDatabase()]);

  Analytics.analytics.logAppOpen();

  Notifications.instance.init();

  new Routes();
}
