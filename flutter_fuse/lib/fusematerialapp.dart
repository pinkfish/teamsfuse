import 'package:firebase_analytics/observer.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home/splash.dart';
import 'services/messages.dart';

///
/// The main material app pieces, seperate widget to make the injection work
/// correctly.
///
///
class FuseMaterialApp extends StatelessWidget {
  final ThemeData theme;

  FuseMaterialApp(this.theme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        const MessagesDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('en', 'UK'),
        const Locale('en', 'AU'),
      ],
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: Analytics.analytics),
      ],
      title: "Team Fuse",
      theme: theme,
      initialRoute: "Home",
      home: SplashScreen(),
      onGenerateRoute: (RouteSettings settings) =>
          _buildRoute(context, settings),
    );
  }

  Route<dynamic> _buildRoute(
      BuildContext context, RouteSettings routeSettings) {
    print("Route ${routeSettings.name}");
    // States on routes.
    var router = RepositoryProvider.of<fluro.Router>(context);
    return router.generator(routeSettings);
  }
}
