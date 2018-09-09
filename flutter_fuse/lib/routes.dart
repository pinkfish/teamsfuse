import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/loggingdata.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/firestore.dart';

class Routes {
  UserData _currentUser;

  final ThemeData theme = new ThemeData(
    // This is the theme of your application.
    //
    // Try running your application with "flutter run". You'll see the
    // application has a blue toolbar. Then, without quitting the app, try
    // changing the primarySwatch below to Colors.green and then invoke
    // "hot reload" (press "r" in the console where you ran "flutter run",
    // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
    // counter didn't reset back to zero; the application is not restarted.
    primarySwatch: Colors.green,
  );

  MaterialApp app;

  Routes(UserData data) {
    // Subscribe to auth changes.
    UserDatabaseData.instance.userAuth.onAuthChanged().listen(_authChanged);
    // Start loading stuff.
    _authChanged(data);
    // Setup the app and do exciting things.
    app = new MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        const MessagesDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('en', 'UK'),
        const Locale('en', 'AU'),
      ],
      navigatorObservers: <NavigatorObserver>[
        new FirebaseAnalyticsObserver(analytics: Analytics.analytics),
      ],
      title: "Team Fuse",
      theme: theme,
      initialRoute: _currentUser == null || !_currentUser.isEmailVerified
          ? "Login/Home"
          : "Home",
      home: new SplashScreen(),
      onGenerateRoute: _buildRoute,
    );
    runApp(app);
  }

  Route<dynamic> _buildRoute(RouteSettings routeSettings) {
    //Analytics.analytics.setCurrentScreen(screenName: routeSettings.name);
    LoggingData.instance.lastPath = routeSettings.name;
    return AppRouter.instance.generator(routeSettings);
  }

  void _authChanged(UserData user) async {
    _currentUser = user;
    if (user != null) {
      UserDatabaseData.load(user.uid, user.email,
          UserDatabaseData.instance.userAuth.getProfile(user.uid));
      Analytics.analytics.setUserId(user.uid);
      if (Analytics.instance.debugMode) {
        Analytics.analytics.setUserProperty(name: "developer", value: "true");
      } else {
        Analytics.analytics.setUserProperty(name: "developer", value: "false");
      }
    } else {
      UserDatabaseData.clear();
    }
  }
}
