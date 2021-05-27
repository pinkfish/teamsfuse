import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart';

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

const channelId = 'teams_fuse_channel';
const channelTitle = 'TeamsFuse Notifications';
const channelDescription =
    'This channel is used for important notifications for TeamsFuse.';

///
/// Handles interacting with the notifications for the app.  Displaying
/// notifications and incoming notifications.
///
class Notifications {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final StreamController<String> _notificationRoutes =
      StreamController<String>();

  final SelectNotificationCallback _selectNotification;

  final AuthenticationBloc _authenticationBloc;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  final channel = AndroidNotificationChannel(
    channelId,
    channelTitle,
    channelDescription,
    importance: Importance.high,
  );

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Notifications(this._selectNotification, this._authenticationBloc);

  StreamSubscription<UpdateReason> _gameStream;

  /// Disposes the class, closing everything.
  void dispose() {
    _gameStream?.cancel();
    _gameStream = null;
    _notificationRoutes.close();
  }

  /// Initialize the system from the setup for local and FCM notifications.
  void init() async {
    final initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettingsMacOS = MacOSInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    try {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _selectNotification);

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e, stack) {
      // Report errors with the local events setup.
      _authenticationBloc.analyticsSubsystem.recordException(e, stack);
    }

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
      print('onMessage: ${message.data}');
      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelTitle,
              channelDescription,
              icon: 'app_icon',
            ),
          ),
        );
      }
      return;
    });

    // When a new message comesin forward it onwards.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onMessageOpenedAppController.add(message);
    });

    // Set the token to get notifications.
    if (_authenticationBloc.state is AuthenticationLoggedIn) {
      final token = await _firebaseMessaging.getToken();
      _authenticationBloc.add(AuthenticationNotificationToken(token));
    }
    _authenticationBloc.stream.listen((event) async {
      if (event is AuthenticationLoggedIn) {
        // When we login, write out the auth token.
        final token = await _firebaseMessaging.getToken();
        _authenticationBloc.add(AuthenticationNotificationToken(token));
      }
    });
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
              channelId,
              channelTitle,
              channelDescription,
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
            channelId,
            channelTitle,
            channelDescription,
          ),
          iOS: iOSPlatformChannelSpecifics,
        ),
      );
    }
  }

  ///
  /// Cancel this notification.
  ///
  Future<void> cancelNotification(String threadId) async {
    await flutterLocalNotificationsPlugin.cancel(threadId.hashCode);
  }

  ///
  /// Gets the initial message.
  ///
  Future<RemoteMessage> getInitialMessage() {
    return _firebaseMessaging.getInitialMessage();
  }

  ///
  /// Turn a remote message into something we can use.
  ///
  String pathFromMessage(RemoteMessage message) {
    if (message == null) {
      return null;
    }
    switch (message.data['action']) {
      case 'openGame':
        return '/Game/View/${message.data['gameUid']}';
      default:
        return null;
    }
  }

  // ignore: close_sinks
  static final _onMessageOpenedAppController =
      StreamController<RemoteMessage>();

  /// Returns a [Stream] that is called when a user presses a notification message displayed
  /// via FCM.
  ///
  /// A Stream event will be sent if the app has opened from a background state
  /// (not terminated).
  ///
  /// If your app is opened via a notification whilst the app is terminated,
  /// see [getInitialMessage].
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;
}

// Background messaging handler.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  print('onBackgroundMessage: ${message.data}');
  final notification = message.notification;
  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelTitle,
          channelDescription,
          icon: 'app_icon',
        ),
      ),
    );
  }
}
