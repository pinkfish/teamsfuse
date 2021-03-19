import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/firestore/firestore.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

import 'screens/publichome.dart';
import 'services/algolia.dart';
import 'services/approuter.dart';
import 'services/messagespublic.dart';

void main() {
  runApp(PublicTeamsFuse());
}

///
/// The public teams fuse app.
///
class PublicTeamsFuse extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primarySwatch: Colors.green,
    );
    final route = "Home";
    final wrapper = Firestore();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<fluro.FluroRouter>(
          create: (context) => AppRouter.createAppRouter(),
        ),
        RepositoryProvider<AnalyticsSubsystem>(
          create: (c) => AnalyticsSubsystemImpl.instance,
        ),
        RepositoryProvider<DatabaseUpdateModel>(
            create: (context) => DatabaseUpdateModelImpl(
                wrapper, null, AnalyticsSubsystemImpl.instance)),
        RepositoryProvider<BaseCacheManager>(
            create: (context) => DefaultCacheManager()),
        RepositoryProvider<UserAuthImpl>(
            create: (context) => UserAuthImpl(wrapper)),
        RepositoryProvider<AlgoliaSearch>(
          create: (context) => AlgoliaSearch(),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            MessagesPublicDelegate(),
            MessagesDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: "Teams Fuse",
          theme: theme,
          initialRoute: route,
          home: PublicHomeScreen(PublicMainTab.about.name),
          onGenerateRoute: (settings) => _buildRoute(context, settings),
        ),
      ),
    );
  }

  Route<dynamic> _buildRoute(
      BuildContext context, RouteSettings routeSettings) {
    // States on routes.
    final router = RepositoryProvider.of<fluro.FluroRouter>(context);
    return router.generator(routeSettings);
  }
}
