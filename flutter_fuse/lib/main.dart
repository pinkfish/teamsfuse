import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';
import 'package:timezone/timezone.dart';
import 'package:clock/clock.dart';

import 'flutterfuseapp.dart';
import 'services/analytics.dart';
import 'services/appconfiguration.dart';
import 'services/firestore/firestore.dart' as fs;
import 'services/loggingdata.dart';
import 'util/async_hydrated_bloc/asyncstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Trace as the first thing in the system.
  final trace = AnalyticsSubsystemImpl.instance.newTrace('startup');
  trace.start();

  // Trace the errors to crashalytics early in the process.
  var loggingData = LoggingData();
  unawaited(AnalyticsSubsystemImpl.analytics.logAppOpen());

  // Send error logs up to crashalytics.
  FlutterError.onError = (details) {
    loggingData.logFlutterError(details);
  };

  Bloc.observer = _SimpleBlocDelegate();
  var storageDirectory = Directory('');
  if (!kIsWeb) {
    final sd = await getTemporaryDirectory();
    storageDirectory = Directory(sd.path);
    AsyncHydratedStorage.storageDirectory = storageDirectory;
    // Load up the data for the hydrated bloc stuff.
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: storageDirectory,
    );
  } else {
    HydratedBloc.storage = _EmptyHydratedStorage();
  }

  String currentTimeZone;
  ByteData loadedData;
  await Future.wait<dynamic>(<Future<dynamic>>[
    rootBundle.load('assets/timezone/2018c.tzf').then<ByteData>((data) {
      loadedData = data;
      return data;
    }),
    !kIsWeb
        ? FlutterNativeTimezone.getLocalTimezone()
            .then<String>((str) => currentTimeZone = str)
        : Future.value(true)
  ]);
  if (kIsWeb) {
    var dt = clock.now();
    currentTimeZone = dt.timeZoneName;
  }

  // Timezone
  initializeDatabase(loadedData.buffer.asUint8List());
  try {
    if (currentTimeZone == 'GMT' || currentTimeZone == 'Etc/UTC') {
      currentTimeZone = 'Europe/London';
      setLocalLocation(getLocation(currentTimeZone));
    } else if (currentTimeZone == 'Pacific Standard Time') {
      currentTimeZone = 'America/Los_Angeles';
      setLocalLocation(getLocation(currentTimeZone));
    } else if (currentTimeZone == 'Mountain Standard Time') {
      currentTimeZone = 'America/Detroit';
      setLocalLocation(getLocation(currentTimeZone));
    } else if (currentTimeZone == 'Coordinated Universal Time') {
      currentTimeZone = 'Europe/London';
      setLocalLocation(getLocation(currentTimeZone));
    } else {
      setLocalLocation(getLocation(currentTimeZone));
    }
  } catch (e, stack) {
    AnalyticsSubsystemImpl.instance.recordException(e, stack);
    currentTimeZone = 'America/Los_Angeles';
    setLocalLocation(getLocation(currentTimeZone));
  }
  print('$currentTimeZone ${local.toString()}');

  var firestoreWrapper = fs.Firestore();
  //UserDatabaseData.instance = new UserDatabaseData(Analytics.instance,
  //    LoggingData.instance, SqlData.instance, firestoreWrapper);

  // Start the loading, but don't block on it,
  // Load notifications after the app config has loaded.
  var config = AppConfiguration();
  unawaited(config.load());

  // License for the freepik picture.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        null, 'Designed by FreePik\nwww.freepik.com ');
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
    print('Transition: ${transition.currentState.runtimeType.toString()} '
        'event: ${transition.event.runtimeType.toString()} '
        'nextState: ${transition.nextState.runtimeType.toString()}');
  }
}

// my_hydrated_storage.dart

class _EmptyHydratedStorage implements Storage {
  @override
  dynamic read(String key) {}

  @override
  Future<void> write(String key, dynamic value) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}
}
