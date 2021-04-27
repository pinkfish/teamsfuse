import 'package:firebase_analytics/observer.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
    final route = 'Home';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        FirebaseAnalyticsObserver(analytics: AnalyticsSubsystemImpl.analytics),
      ],
      title: 'Teams Fuse',
      theme: _theme,
      initialRoute: route,
      home: SplashScreen(),
      onGenerateRoute: (settings) => _buildRoute(context, settings),
    );
  }

  Route<dynamic> _buildRoute(
      BuildContext context, RouteSettings routeSettings) {
    // States on routes.
    final router = RepositoryProvider.of<fluro.FluroRouter>(context);
    print('Navigating to ${routeSettings.name}');
    // Deal with routes that start with main.
    if (routeSettings.name.startsWith('main/')) {
      return router.generator(
          routeSettings.copyWith(name: routeSettings.name.substring(5)));
    }
    return router.generator(routeSettings);
  }
}
