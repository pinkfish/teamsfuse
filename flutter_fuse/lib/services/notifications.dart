import 'package:firebase_messaging/firebase_messaging.dart';
import 'authentication.dart';
import 'dart:async';

class Notifications {
  static final Notifications instance = new Notifications();

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  StreamController<String> _notificationRoutes = new StreamController<String>();
  Stream<String> routeStream;

  static const String ACTION_STR = 'action';
  static const String GAME_UID_STR = 'gameUids';

  Notifications() {
    routeStream = _notificationRoutes.stream.asBroadcastStream();
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
  }
}
