import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart';
import 'package:universal_io/io.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'services/blocs.dart';
import 'util/async_hydrated_bloc/asyncstorage.dart';
import 'flutterfuseapp.dart';
import 'services/analytics.dart';
import 'services/appconfiguration.dart';
import 'services/firestore/firestore.dart' as fs;
import 'services/loggingdata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Trace as the first thing in the system.
  var trace = AnalyticsSubsystemImpl.instance.newTrace("startup");
  trace.start();

  Bloc.observer = _SimpleBlocDelegate();

  // Load up the data for the hydrated bloc stuff.
  HydratedBloc.storage = await HydratedStorage.build();
  AsyncHydratedStorage.storageDirectory = await getTemporaryDirectory();

  String currentTimeZone;
  ByteData loadedData;
  await Future.wait<dynamic>(<Future<dynamic>>[
    rootBundle.load('assets/timezone/2018c.tzf').then<ByteData>((data) {
      loadedData = data;
      print('loaded data');
      return data;
    }),
    Platform.isAndroid || Platform.isIOS
        ? FlutterNativeTimezone.getLocalTimezone()
            .then<String>((str) => currentTimeZone = str)
        : Future.value(true)
  ]);
  if (!Platform.isAndroid && !Platform.isIOS) {
    var dt = DateTime.now();
    currentTimeZone = dt.timeZoneName;
  }

  // Timezone
  initializeDatabase(loadedData.buffer.asUint8List());
  if (currentTimeZone == "GMT") {
    currentTimeZone = "Europe/London";
    setLocalLocation(getLocation(currentTimeZone));
  } else if (currentTimeZone == "Pacific Standard Time") {
    currentTimeZone = "America/Los_Angeles";
    setLocalLocation(getLocation(currentTimeZone));
  } else if (currentTimeZone == "Mountain Standard Time") {
    currentTimeZone = "America/Detroit";
    setLocalLocation(getLocation(currentTimeZone));
  } else {
    setLocalLocation(getLocation(currentTimeZone));
  }
  print('$currentTimeZone ${local.toString()}');

  // database
  print('Making stuff in here');
  // Setup the timestamps correctly.

  //await Firestore.instance.settings();

  var firestoreWrapper = fs.Firestore();
  //UserDatabaseData.instance = new UserDatabaseData(Analytics.instance,
  //    LoggingData.instance, SqlData.instance, firestoreWrapper);

  // Start the loading, but don't block on it,
  // Load notifications after the app config has loaded.
  var config = AppConfiguration();
  config.load();

  var loggingData = LoggingData();

  AnalyticsSubsystemImpl.analytics.logAppOpen();

  // Send error logs up to sentry.
  FlutterError.onError = (details) {
    loggingData.logFlutterError(details);
  };

  // License for the freepik picture.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        null, "Designed by FreePik\nwww.freepik.com ");
  });
  trace.stop();

  runApp(FlutterFuseApp(firestoreWrapper, config, loggingData));
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
