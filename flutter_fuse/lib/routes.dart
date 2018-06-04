import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/screens/login/loginform.dart';
import 'package:flutter_fuse/screens/login/forgotpassword.dart';
import 'package:flutter_fuse/screens/login/signup.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/screens/login/verifyemail.dart';
import 'package:flutter_fuse/services/loggingdata.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:fusemodel/fusemodel.dart';

class Routes {
  UserData _currentUser;

  final loggedOutRoutes = <String, WidgetBuilder>{
    "/Login/Home": (BuildContext context) => new LoginScreen(),
    "/Login/ForgotPassword": (BuildContext context) =>
        new ForgotPasswordScreen(),
    "/Login/SignUp": (BuildContext context) => new SignupScreen(),
    "/Login/Verify": (BuildContext context) => new VerifyEmailScreen(),
  };

  final theme = new ThemeData(
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

  PageRoute<dynamic> _buildRoute(RouteSettings routeSettings) {
    //Analytics.analytics.setCurrentScreen(screenName: routeSettings.name);
    LoggingData.instance.lastPath = routeSettings.name;
    if (_currentUser != null) {
      if (_currentUser.isEmailVerified) {
        return AppRouter.instance.generator(routeSettings);
      }
    }
    return new MaterialPageRoute<Null>(
        settings: routeSettings, builder: loggedOutRoutes[routeSettings.name]);
  }

  void _authChanged(UserData user) async {
    _currentUser = user;
    if (user != null) {
      UserDatabaseData.load(
          user.uid, user.email, UserAuth.instance.getProfile(user.uid));
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

  Routes() {
    // Subscribe to auth changes.
    UserAuth.instance.onAuthChanged().listen(_authChanged);
    app = new MaterialApp(
      localizationsDelegates: [
        const MessagesDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('en', 'UK'),
        const Locale('en', 'AU'),
      ],
      navigatorObservers: [
        new FirebaseAnalyticsObserver(analytics: Analytics.analytics),
      ],
      title: "Team Fuse",
      theme: theme,
      initialRoute: "/",
      home: new SplashScreen(),
      onGenerateRoute: _buildRoute,
    );
    runApp(app);
  }
}
