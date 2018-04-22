import 'package:flutter_fuse/Routes.dart';
import 'package:flutter_fuse/cache/cachemanager.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/impl/databaseupdatemodelimpl.dart';

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

  new Routes();
}
