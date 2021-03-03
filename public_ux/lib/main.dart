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
import 'package:public_ux/screens/publichome.dart';

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
    final route = "Public/Club/-LFYVrTV145zE21C4O24";

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
                Firestore(), null, AnalyticsSubsystemImpl.instance)),
        RepositoryProvider<BaseCacheManager>(
            create: (context) => DefaultCacheManager()),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[],
        child: MaterialApp(
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
          home: PublicHomeScreen("club", "-LFYVrTV145zE21C4O24", null),
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
