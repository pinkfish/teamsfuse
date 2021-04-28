import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart';

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

///
/// Handles interacting with the notifications for the app.  Displaying
/// notifications and incoming notifications.
///
class Notifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final StreamController<String> _notificationRoutes =
      StreamController<String>();

  final SelectNotificationCallback selectNotification;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  final channel = AndroidNotificationChannel(
    'teams_fuse_channel', // id
    'TeamsFuse Notifications', // title
    'This channel is used for important notifications for TeamsFuse.',
    // description
    importance: Importance.high,
  );

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Notifications(this.selectNotification);

  StreamSubscription<UpdateReason> _gameStream;

  /// Disposes the class, closing everything.
  void dispose() {
    _gameStream?.cancel();
    _gameStream = null;
    _notificationRoutes.close();
  }

  /// Initialize the system from the setup for local and FCM notifications.
  void init(AuthenticationBloc auth) async {
    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettingsMacOS = MacOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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
      return;
    });
  }

  // Background messaging handler.
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
  }

  /// Received the local notification, now do something exciting.
  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return;
  }

  ///
  /// Schedule a notification for the time in the right zone.
  ///
  Future<void> zonedSchedule(
      String threadId, String title, String body, TZDateTime scheduleAt) async {
    final iOSPlatformChannelSpecifics =
        IOSNotificationDetails(threadIdentifier: threadId);
    if (TZDateTime.now(local).isBefore(scheduleAt)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          threadId.hashCode,
          title,
          body,
          scheduleAt,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
            ),
            iOS: iOSPlatformChannelSpecifics,
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    } else {
      await flutterLocalNotificationsPlugin.show(
        threadId.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
          ),
          iOS: iOSPlatformChannelSpecifics,
        ),
      );
    }
  }

  Future<void> cancelNotification(String threadId) async {
    await flutterLocalNotificationsPlugin.cancel(threadId.hashCode);
  }
}
