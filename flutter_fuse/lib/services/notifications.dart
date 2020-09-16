import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

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
/*
  int _generateNotificationId() {
    int val;
    do {
      val = random.nextInt(4294967296);
    } while (_notificationMapping.values.contains(val));
    return val;
  }

  void _createGameNotification(Game game, int id) {
    GameNotification not = GameNotification(
        game, UserDatabaseData.instance.teams[game.teamUid]);

    not.showNotification(id, flutterLocalNotificationsPlugin,
        Messages.of(_state.context), MaterialLocalizations.of(_state.context));
    _notificationMapping[game.uid] = id;
    _updateSharedPrefs();
  }


  void _updateSharedPrefs() {
    String data = json.encode(_notificationMapping);
    AppConfiguration.instance.sharedPreferences
        .setString(_keyNotificationData, data);
  }


  void _onGamesUpdated() {
    Map<String, Game> data = UserDatabaseData.instance.gamesCache;
    Set<String> stillHere = _notificationMapping.keys.toSet();
    DateTime now = DateTime.now();
    for (Game game in data.values) {
      stillHere.remove(game.uid);
      DateTime gameDate = DateTime.fromMillisecondsSinceEpoch(game.sharedData.time.toInt());
      DateTime oldest = DateTime.now().subtract(timeoutNotifiation);
      DateTime newest = DateTime.now().add(notifyStart);
      // If it is older then 2 days, then delete it.
      if (gameDate.isAfter(oldest)) {
        DateTime frog =
            DateTime.fromMillisecondsSinceEpoch(game.sharedData.time.toInt()).add(notifyStart);
        print('Checking ${game.uid} $frog $now');
        if (!_notificationMapping.containsKey(game.uid) &&
            gameDate.isBefore(newest)) {
          print('creating or updating!');
          int id;
          if (_notificationMapping.containsKey(game.uid)) {
            id = _notificationMapping[game.uid];
          }
          if (id == null) {
            id = _generateNotificationId();
          }
          // Create a notification...
          _createGameNotification(game, id);
        }
      } else if (_notificationMapping.containsKey(game.uid)) {
        flutterLocalNotificationsPlugin.cancel(_notificationMapping[game.uid]);
        _notificationMapping.remove(game.uid);
        _updateSharedPrefs();
      }
    }
    for (String gameId in stillHere) {
      flutterLocalNotificationsPlugin.cancel(_notificationMapping[gameId]);
      _notificationMapping.remove(gameId);
      _updateSharedPrefs();
    }
  }
  */

  void init(AuthenticationBloc auth) {
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
    //get saved cache data from shared prefs
    String jsonCacheString = AppConfiguration.instance.sharedPreferences
        .getString(_keyNotificationData);
    if (jsonCacheString != null) {
      Map<String, dynamic> tmp =
          json.decode(jsonCacheString) as Map<String, dynamic>;
      _notificationMapping.clear();
      tmp.forEach((String str, dynamic val) =>
          val is int ? _notificationMapping[str] = val : null);
    }
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
