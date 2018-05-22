import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'authentication.dart';
import 'dart:async';
import 'databasedetails.dart';
import 'messages.dart';
import 'notifications/gamenotification.dart';
import 'dart:math';
import 'appconfiguration.dart';
import 'dart:convert';
import 'dart:io';


class Notifications {
  static final Notifications instance = new Notifications();

  static const _keyNotificationData = "lib_notification_data";

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  StreamController<String> _notificationRoutes = new StreamController<String>();
  Stream<String> routeStream;
  StreamSubscription<UpdateReason> _gameStream;
  Map<String, dynamic> _notificationMapping = {};
  Random random = new Random.secure();
  State<SplashScreen> _state;

  static const String ACTION_STR = 'action';
  static const String GAME_UID_STR = 'gameUids';

  static const Duration notifyStart = const Duration(days: 31);
  static const Duration timeoutNotifiation = const Duration(days: 2);

  Notifications() {
    routeStream = _notificationRoutes.stream.asBroadcastStream();
  }

  void dispose() {
    _gameStream?.cancel();
    _gameStream = null;
  }

  void _handleMessage(Map<String, dynamic> data) {}

  void _handleLaunch(Map<String, dynamic> data) {}

  void _handleResume(Map<String, dynamic> data) {
    if (data.containsKey(ACTION_STR)) {
      switch (data[ACTION_STR]) {
        case 'openGame':
          _notificationRoutes.add("Game/" + data[GAME_UID_STR]);
          break;
      }
    }
  }

  Future<dynamic> _onSelectNotification(String payload) async {
    print('Selected notification $payload}');
    _notificationRoutes.add(payload);
    return 1;
  }

  int _generateNotificationId() {
    int val;
    do {
      val = random.nextInt(4294967296);
    } while (_notificationMapping.values.contains(val));
    return val;
  }

  void _createGameNotification(Game game, int id) {
    GameNotification not = new GameNotification(
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
    Map<String, Game> data = UserDatabaseData.instance.games;
    Set<String> stillHere = _notificationMapping.keys.toSet();
    DateTime now = new DateTime.now();
    for (Game game in data.values) {
      stillHere.remove(game.uid);
      DateTime gameDate = new DateTime.fromMillisecondsSinceEpoch(game.time);
      DateTime oldest = new DateTime.now().subtract(timeoutNotifiation);
      DateTime newest = new DateTime.now().add(notifyStart);
      // If it is older then 2 days, then delete it.
      if (gameDate.isAfter(oldest)) {
        DateTime frog =
            new DateTime.fromMillisecondsSinceEpoch(game.time).add(notifyStart);
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
        //flutterLocalNotificationsPlugin.cancel(_notificationMapping[game.uid]);
        _notificationMapping.remove(game.uid);
        _updateSharedPrefs();
      }
    }
    for (String gameId in stillHere) {
      //flutterLocalNotificationsPlugin.cancel(_notificationMapping[gameId]);
      _notificationMapping.remove(gameId);
      _updateSharedPrefs();
    }
  }

  void init() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((String token) {
      print('We have token! $token');
      UserAuth.instance.setNotificationToken(token);
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        this._handleMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onMessage: $message");
        this._handleLaunch(message);
      },
      onResume: (Map<String, dynamic> message) {
        print("onMessage: $message");
        this._handleResume(message);
      },
    );
    //get saved cache data from shared prefs
    String jsonCacheString = AppConfiguration.instance.sharedPreferences
        .getString(_keyNotificationData);
    if (jsonCacheString != null) {
      _notificationMapping = json.decode(jsonCacheString);
    }
  }

  void initForNotification(State<SplashScreen> state) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    InitializationSettingsAndroid initializationSettingsAndroid =
        new InitializationSettingsAndroid('app_icon');
    InitializationSettingsIOS initializationSettingsIOS =
        new InitializationSettingsIOS();
    InitializationSettings initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    flutterLocalNotificationsPlugin.onSelectNotificationStream.listen((String payload) {
      _onSelectNotification(payload);
    });

    this._state = state;
    // When games are scheduled we will pull up the results for them and
    // schedule notifications.  We only do this on android since on iOS we
    // need to rely on remote push notifications for the details to be up to
    // date.
    if (Platform.isAndroid) {
      _gameStream =
          UserDatabaseData.instance.gameStream.listen((UpdateReason reason) {
            _onGamesUpdated();
          });
    }
  }
}
