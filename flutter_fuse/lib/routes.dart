import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:timezone/timezone.dart';

import 'package:flutter_fuse/services/approuter.dart';

import 'package:flutter_fuse/screens/login/loginform.dart';
import 'package:flutter_fuse/screens/login/forgotpassword.dart';
import 'package:flutter_fuse/screens/login/signup.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fuse/services/messages.dart';

class Routes {
  UserData _currentUser;

  final loggedOutRoutes = <String, WidgetBuilder>{
    "/Home": (BuildContext context) => new LoginScreen(),
    "/ForgotPassword": (BuildContext context) => new ForgotPasswordScreen(),
    "/SignUp": (BuildContext context) => new SignupScreen(),
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

  Route<Null> _buildRoute(RouteSettings routeSettings) {
    print(routeSettings.name);
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
      final data = await rootBundle.load('assets/timezone/2018c.tzf');
      initializeDatabase(data.buffer.asUint8List());
      UserDatabaseData.load(user.uid);
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
        title: 'Team Fuse',
        theme: theme,
        initialRoute: "/",
        home: new SplashScreen(),
        onGenerateRoute: _buildRoute);
    runApp(app);
  }
}
