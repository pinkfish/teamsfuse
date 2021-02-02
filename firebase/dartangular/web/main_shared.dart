import 'package:angular/angular.dart';
import 'package:firebase/firebase.dart' as fb;
import "package:intl/intl_browser.dart";
import 'package:teamfuse/app-component.template.dart' as fluff;
import 'package:timezone/browser.dart';

void mainShared(InjectorFactory injector) async {
  fb.initializeApp(
      apiKey: "AIzaSyBdhSWSOEvnTMHMDf0bMEIb8i64uVcWL3U",
      authDomain: "teamsfuse.firebaseapp.com",
      databaseURL: "https://teamsfuse.firebaseio.com",
      projectId: "teamsfuse",
      storageBucket: "teamsfuse.appspot.com",
      messagingSenderId: "400199897683",
      appId: "1:400199897683:web:a76b9c523dbef7a408aca6");
  await findSystemLocale();
  await initializeTimeZone();
  print('Startup checking user');

  runApp(fluff.AppComponentNgFactory as ComponentFactory,
      createInjector: injector);
}
