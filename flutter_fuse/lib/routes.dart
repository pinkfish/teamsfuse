import 'package:flutter/material.dart';
import 'package:flutter_fuse/screens/login/loginform.dart';
import 'package:flutter_fuse/screens/login/forgotpassword.dart';
import 'package:flutter_fuse/screens/login/signup.dart';
import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fuse/services/messages.dart';


class Routes {

  UserData _currentUser;
  UserDatabaseData _data;

  final loggedOutRoutes = <String, WidgetBuilder>{
    "/" : (BuildContext context) => new LoginScreen(),
    "/ForgotPassword": (BuildContext context) => new ForgotPasswordScreen(),
    "/SignUp": (BuildContext context) => new SignupScreen(),
  };
  final loggedInRoutes = <String, WidgetBuilder>{
    "/": (BuildContext context) => new HomeScreen()
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
    if (_currentUser != null) {
      if (_currentUser.isEmailVerified) {
        if (loggedInRoutes.containsKey(routeSettings.name)) {
          return new MaterialPageRoute<Null>(
              settings: routeSettings,
              builder: loggedInRoutes[routeSettings.name]
          );
        }
        return new MaterialPageRoute<Null>(
            settings: routeSettings,
            builder: loggedInRoutes["/"]
        );
      }
    }
    return new MaterialPageRoute<Null>(
        settings: routeSettings,
        builder: loggedOutRoutes[routeSettings.name]
    );
  }

  void _authChanged(UserData user) async {
    bool changePages = false;
    if (_currentUser != null && user == null) {
      changePages = true;
    }
    if (_currentUser == null && user != null) {
      changePages = true;
    }
    _currentUser = user;
    if (user != null) {
      final data = await rootBundle.load('assets/timezone/2018c.tzf');
      initializeDatabase(data.buffer.asUint8List());
      UserDatabaseData.load(user.uid);
    } else {
      UserDatabaseData.clear();
    }
    if (changePages) {
      //app.navigatorKey.currentState.pushNamed("/");
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
        onGenerateRoute: this._buildRoute
    );
    runApp(app);
  }
}
