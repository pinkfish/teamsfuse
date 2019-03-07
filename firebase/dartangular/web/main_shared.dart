import 'dart:async';

import 'package:angular/angular.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import "package:intl/intl_browser.dart";
import 'package:teamfuse/services/sqldata.dart';
import 'package:teamfuse/services/webanalytics.dart';
import 'package:teamfuse/services/weblogging.dart';
import 'package:teamfuse/util/firestore/firestore.dart' as fs;
import 'package:timezone/browser.dart';

import 'package:teamfuse/app-component.template.dart' as fluff;

void mainShared(InjectorFactory injector) async {
  fb.initializeApp(
      apiKey: "AIzaSyBN6v7M6jy39smjF9Lt819FcsWRm2cu9K0",
      authDomain: "teamsfuse.firebaseapp.com",
      databaseURL: "https://teamsfuse.firebaseio.com",
      projectId: "teamsfuse",
      storageBucket: "teamsfuse.appspot.com",
      messagingSenderId: "400199897683");
  UserDatabaseData.instance = new UserDatabaseData(new WebAnalytics(),
      new WebLogging(), SqlData.instance, new fs.Firestore());
  await findSystemLocale();
  await initializeTimeZone();
  print('Startup checking user');
  Completer<UserData> data = new Completer();
  // Load the user.
  StreamSubscription sub = UserDatabaseData.instance.userAuth
      .onAuthChanged()
      .listen((UserData user) {
    data.complete(user);
  });
  await data.future;
  print('Loaded user');
  // We should now have the current user setup correctly/
  sub.cancel();
  print('Loaded!');

  runApp(fluff.AppComponentNgFactory as ComponentFactory,
      createInjector: injector);
}
