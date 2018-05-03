import 'package:firebase_messaging/firebase_messaging.dart';
import 'authentication.dart';

class Notifications {
  static final Notifications instance = new Notifications();

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  void _handleMessage(Map<String, dynamic> data) {}

  void _handleLaunch(Map<String, dynamic> data) {}

  void _handleResume(Map<String, dynamic> data) {}

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
