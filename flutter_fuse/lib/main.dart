import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedantic/pedantic.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:clock/clock.dart';

import 'flutterfuseapp.dart';
import 'services/analytics.dart';
import 'services/appconfiguration.dart';
import 'services/firestore/firestore.dart' as fs;
import 'services/loggingdata.dart';
import 'util/async_hydrated_bloc/asyncstorage.dart';

void setLocalLocation(String tzName) {
  tz.setLocalLocation(tz.getLocation(tzName));
}

void main() async {
  return mainInner(true);
}

void mainInner(bool setupErrorHandler) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Trace as the first thing in the system.
  final analytics = await AnalyticsSubsystemImpl.create(FirebaseAnalytics());

  final trace = analytics.newTrace('startup');
  trace.start();

  // Trace the errors to crashalytics early in the process.
  var loggingData = LoggingData();
  unawaited(analytics.logAppOpen());

  // Send error logs up to crashalytics.
  if (setupErrorHandler) {
    FlutterError.onError = (details) {
      loggingData.logFlutterError(details);
    };
  }

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
  tz_data.initializeTimeZones();
  if (!kIsWeb) {
    currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  }

  if (kIsWeb) {
    var dt = clock.now();
    currentTimeZone = dt.timeZoneName;
  }

  // Timezone
  try {
    if (currentTimeZone == 'GMT' || currentTimeZone == 'Etc/UTC') {
      currentTimeZone = 'Europe/London';
      setLocalLocation(currentTimeZone);
    } else if (currentTimeZone == 'Pacific Standard Time' ||
        currentTimeZone == 'Pacific Daylight Time') {
      currentTimeZone = 'America/Los_Angeles';
      setLocalLocation(currentTimeZone);
    } else if (currentTimeZone == 'Mountain Standard Time') {
      currentTimeZone = 'America/Detroit';
      setLocalLocation(currentTimeZone);
    } else if (currentTimeZone == 'Coordinated Universal Time') {
      currentTimeZone = 'Europe/London';
      setLocalLocation(currentTimeZone);
    } else {
      try {
        setLocalLocation(currentTimeZone);
      } catch (e, stack) {
        analytics.recordException(e, stack);
        print('Failed to set location $currentTimeZone');
      }
    }
  } catch (e, stack) {
    analytics.recordException(e, stack);
    currentTimeZone = 'America/Los_Angeles';
    setLocalLocation(currentTimeZone);
  }
  print('$currentTimeZone ');

  var firestoreWrapper = fs.Firestore();

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

  runApp(FlutterFuseApp(firestoreWrapper, config, loggingData, analytics));
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
