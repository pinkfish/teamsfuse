import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'appconfiguration.dart';

///
/// Handles interacting with the notifztions for the app.  Displaying
/// notifications and incoming notications.
///
class Notifications {
  static const String _keyNotificationData = 'lib_notification_data';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //   FlutterLocalNotificationsPlugin();

  final StreamController<String> _notificationRoutes =
      StreamController<String>();

  //Stream<String> _routeStream;
  StreamSubscription<UpdateReason> _gameStream;
  final Map<String, int> _notificationMapping = <String, int>{};

  //final Random _random = Random.secure();
  //State<SplashScreen> _state;

  //static const String _actionStr = 'action';
  //static const String _gameUidStr = 'gameUids';

  // static const Duration _notifyStart = Duration(days: 31);
  //static const Duration _timeoutNotifiation = Duration(days: 2);

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

    /*
    final pref = SharedPreferences.getInstance();

      var jsonCacheString = pref.getString(_keyNotificationData);
      if (jsonCacheString != null) {
        var tmp = json.decode(jsonCacheString) as Map<String, dynamic>;
        _notificationMapping.clear();
        tmp.forEach(
            (str, val) => val is int ? _notificationMapping[str] = val : null);
      }
    }

     */
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
  void initForNotification() async {
    /*
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    InitializationSettingsAndroid initializationSettingsAndroid =
        InitializationSettingsAndroid('app_icon');
    InitializationSettingsIOS initializationSettingsIOS =
        InitializationSettingsIOS(categorySetup: <IOSCategoryDetails>[
      IOSCategoryDetails(id: 'GAMES', actions: <IOSActionDetails>[
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
