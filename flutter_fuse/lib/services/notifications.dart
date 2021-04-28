import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'appconfiguration.dart';

///
/// Handles interacting with the notifztions for the app.  Displaying
/// notifications and incoming notications.
///
class Notifications {
  static const String _keyNotificationData = 'lib_notification_data';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final StreamController<String> _notificationRoutes =
      StreamController<String>();

  StreamSubscription<UpdateReason> _gameStream;

  /// Disposes the class, closing everything.
  void dispose() {
    _gameStream?.cancel();
    _gameStream = null;
    _notificationRoutes.close();
  }

  /// Initalize the system from the setup.
  void init(AuthenticationBloc auth, AppConfiguration configuration) async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage: $message');
      //this._handleMessage(message);
      return;
    });
  }

  // Background messaging handler.
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }

  ///
  /// Init the system for local notifications.
  ///
  void initForNotification() async {}
}
