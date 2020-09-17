import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appconfiguration.dart';
import 'firebasemessaging.dart';

//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  Notifications() {
    routeStream = _notificationRoutes.stream.asBroadcastStream();
  }

  static const String _keyNotificationData = "lib_notification_data";

  static final Notifications instance = Notifications();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //   FlutterLocalNotificationsPlugin();

  StreamController<String> _notificationRoutes = StreamController<String>();
  Stream<String> routeStream;
  StreamSubscription<UpdateReason> _gameStream;
  Map<String, int> _notificationMapping = <String, int>{};
  Random random = Random.secure();
  //State<SplashScreen> _state;

  static const String actionStr = 'action';
  static const String gameUidStr = 'gameUids';

  static const Duration notifyStart = const Duration(days: 31);
  static const Duration timeoutNotifiation = const Duration(days: 2);

  void dispose() {
    _gameStream?.cancel();
    _gameStream = null;
    _notificationRoutes.close();
    _notificationRoutes = null;
  }

  void init(AuthenticationBloc auth, AppConfiguration configuration) {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((String token) {
      print('We have token! $token');
      auth.add(AuthenticationNotificationToken(token));
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        //this._handleMessage(message);
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        //this._handleLaunch(message);
        return;
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        //this._handleResume(message);
        return;
      },
    );
    SharedPreferences.getInstance().then((pref) {
      var jsonCacheString = pref.getString(_keyNotificationData);
      if (jsonCacheString != null) {
        Map<String, dynamic> tmp =
            json.decode(jsonCacheString) as Map<String, dynamic>;
        _notificationMapping.clear();
        tmp.forEach((String str, dynamic val) =>
            val is int ? _notificationMapping[str] = val : null);
      }
    });
  }

  void initForNotification() async {
    /*
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    InitializationSettingsAndroid initializationSettingsAndroid =
        InitializationSettingsAndroid('app_icon');
    InitializationSettingsIOS initializationSettingsIOS =
        InitializationSettingsIOS(categorySetup: <IOSCategoryDetails>[
      IOSCategoryDetails(id: "GAMES", actions: <IOSActionDetails>[
        IOSActionDetails(
          id: 'directions',
          title: 'DIRECTIONS',
        ),
        IOSActionDetails(
          id: 'details',
          title: 'DETAILS',
        )
      ])
    ]);
    InitializationSettings initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    /*
    flutterLocalNotificationsPlugin.onSelectNotificationStream.listen((String payload) {
      _onSelectNotification(payload);
    });
    */

    //_state = state;
    // When games are scheduled we will pull up the results for them and
    // schedule notifications.  We only do this on android since on iOS we
    // need to rely on remote push notifications for the details to be up to
    // date.
    if (Platform.isAndroid) {
      /*
      _gameStream =
          UserDatabaseData.instance.gameStream.listen((UpdateReason reason) {
        _onGamesUpdated();
      });
      */
    }
    */
  }
}
