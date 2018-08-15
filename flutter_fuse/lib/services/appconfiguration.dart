import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum Experiments { calendarView }

// Handle the connection to remote config and do experiment controls.
class AppConfiguration {
  static AppConfiguration instance = new AppConfiguration();

  RemoteConfig config;
  Completer<bool> _completer = new Completer<bool>();
  bool loaded;
  Future<bool> loadingFuture;
  SharedPreferences sharedPreferences;

  Future<void> load() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print('Loading app config');
    FirebaseApp.instance.options.then((FirebaseOptions opt) {
      print("Firstbase client id${opt.clientID}");
    }).catchError((Error e) {
      print("Got error loading the firebase options");
    });
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
