import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_remote_config/firebase_remote_config.dart';

///
/// Expeciments that can be turned on by the config stuff.
///
enum Experiments {
  /// The calenderView experiment.
  calendarView,
}

///
/// Handle the connection to remote config and do experiment controls.  This
/// is a wrapper around the firebase app config to make it easier to use.
///
class AppConfiguration {
  //RemoteConfig _config;
  final Completer<bool> _completer = Completer<bool>();
  bool _loaded;

  /// Loads the configuration.
  Future<void> load() async {
    print('Loading app config');

    var opt = Firebase.app().options;
    print("Firstbase client id${opt.androidClientId}");
    _completer.future.then((done) => _loaded = done);
    //_config = await RemoteConfig.instance;
    //await _config.fetch();
    //await _config.activateFetched();
    _completer.complete(true);
  }

  ///
  /// Checks to see if the system is in the experiment or not.
  ///
  bool isInExperiment(Experiments experiment, {bool defaultValue = false}) {
    if (_loaded) {
      //return _config.getBool(experiment.toString());
    }
    return defaultValue;
  }
}
