import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:timezone/timezone.dart';

import 'flutterfuseapp.dart';
import 'services/analytics.dart';
import 'services/appconfiguration.dart';
import 'services/firestore/firestore.dart' as fs;
import 'services/loggingdata.dart';
import 'services/sqldata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Trace as the first thing in the system.
  var trace = Analytics.instance.newTrace("startup");
  trace.start();

  Bloc.observer = _SimpleBlocDelegate();

  // Load up the data for the hydrated bloc stuff.
  HydratedBloc.storage = await HydratedStorage.build();

  String currentTimeZone;
  ByteData loadedData;
  await Future.wait<dynamic>(<Future<dynamic>>[
    SqlData.instance.initDatabase(),
    rootBundle.load('assets/timezone/2018c.tzf').then<ByteData>((data) {
      loadedData = data;
      print('loaded data');
      return data;
    }),
    FlutterNativeTimezone.getLocalTimezone()
        .then<String>((str) => currentTimeZone = str)
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

  //await Firestore.instance.settings();

  await Firebase.initializeApp();

  var firestoreWrapper = fs.Firestore();
  //UserDatabaseData.instance = new UserDatabaseData(Analytics.instance,
  //    LoggingData.instance, SqlData.instance, firestoreWrapper);

  // Start the loading, but don't block on it,
  // Load notifications after the app config has loaded.
  AppConfiguration.instance.load().then((a) {
    /*
    CacheManager.getInstance().then((CacheManager man) {
      print('got manager');
    }).catchError((dynamic error) {
      print('Got error $error');
    });

     */
  });

  Analytics.analytics.logAppOpen();

  // Send error logs up to sentry.
  FlutterError.onError = (details) {
    LoggingData.instance.logFlutterError(details);
  };

  // License for the freepik picture.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        null, "Designed by FreePik\nwww.freepik.com ");
  });
  trace.stop();

  runApp(FlutterFuseApp(firestoreWrapper));
}

///
/// Simple delegate to print out the transitions.
///
class _SimpleBlocDelegate extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("Transition: ${transition.currentState.runtimeType.toString()} "
        "event: ${transition.event.runtimeType.toString()} "
        "nextState: ${transition.nextState.runtimeType.toString()}");
  }
}
