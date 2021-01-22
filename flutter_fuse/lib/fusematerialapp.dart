import 'package:firebase_analytics/observer.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home/splash.dart';
import 'services/analytics.dart';
import 'services/messages.dart';

///
/// The main material app pieces, seperate widget to make the injection work
/// correctly.
///
///
class FuseMaterialApp extends StatelessWidget {
  final ThemeData _theme;

  ///
  /// Create the material app pieces.
  ///
  FuseMaterialApp(this._theme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        MessagesDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', 'US'),
        Locale('en', 'UK'),
        Locale('en', 'AU'),
      ],
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: Analytics.analytics),
      ],
      title: "Team Fuse",
      theme: _theme,
      initialRoute: "Home",
      home: SplashScreen(),
      onGenerateRoute: (settings) => _buildRoute(context, settings),
    );
  }

  Route<dynamic> _buildRoute(
      BuildContext context, RouteSettings routeSettings) {
    print("Route ${routeSettings.name}");
    // States on routes.
    var router = RepositoryProvider.of<fluro.FluroRouter>(context);
    return router.generator(routeSettings);
  }
}
