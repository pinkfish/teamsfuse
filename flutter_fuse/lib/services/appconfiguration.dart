import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Experiments { calendarView }

// Handle the connection to remote config and do experiment controls.
class AppConfiguration {
  static AppConfiguration instance = AppConfiguration();

  RemoteConfig config;
  Completer<bool> _completer = Completer<bool>();
  bool loaded;
  Future<bool> loadingFuture;
  SharedPreferences sharedPreferences;

  Future<void> load() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print('Loading app config');

    var opt = Firebase.app().options;
    print("Firstbase client id${opt.androidClientId}");
    loadingFuture = _completer.future.then((bool done) => loaded = done);
    config = await RemoteConfig.instance;
    await config.fetch();
    await config.activateFetched();
    _completer.complete(true);
  }

  void waitForLoaded() {}

  bool isInExperiment(Experiments experiment, {bool defaultValue = false}) {
    if (loaded) {
      return config.getBool(experiment.toString());
    }
    return defaultValue;
  }
}
