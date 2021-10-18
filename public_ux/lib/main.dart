import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/firestore/firestore.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:pedantic/pedantic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'screens/publicclubhome.dart';
import 'screens/publichome.dart';
import 'services/algolia.dart';
import 'services/approuter.dart';
import 'services/messagespublic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  var storageDirectory = Directory('');
  if (!kIsWeb) {
    final sd = await getTemporaryDirectory();
    storageDirectory = Directory(sd.path);
    AsyncHydratedStorage.storageDirectory = storageDirectory;
    // Load up the data for the hydrated bloc stuff.
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: storageDirectory,
    );
  } else {
    HydratedBloc.storage = _EmptyHydratedStorage();
  }

  tz.initializeTimeZones();

  final analytics = await AnalyticsSubsystemImpl.create(FirebaseAnalytics());

  unawaited(analytics.logAppOpen());

  // Send error logs up to crashalytics.
  FlutterError.onError = (details) {
    analytics.recordException(details.exception, details.stack);
  };

  runApp(PublicTeamsFuse(analytics));
}

///
/// The public teams fuse app.
///
class PublicTeamsFuse extends StatelessWidget {
  final AnalyticsSubsystemImpl _analytics;

  /// Create the public app.
  PublicTeamsFuse(this._analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primarySwatch: Colors.green,
    );
    var route = 'Home';
    final wrapper = Firestore();

    // Figure out if we know what the base uri is.
    if (Uri.base.host.isNotEmpty) {
      // Split it and work it out.
      final bits = Uri.base.host.split('.');
      switch (bits[0]) {
        case 'nwblasers':
          route = 'Club/${PublicClubTab.club}/-LFYVrTV145zE21C4O24';
          break;
        default:
          route = 'Home';
          break;
      }
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<fluro.FluroRouter>(
          create: (context) => AppRouter.createAppRouter(),
        ),
        RepositoryProvider<AnalyticsSubsystemImpl>(
          create: (c) => _analytics,
        ),
        RepositoryProvider<UserAuthImpl>(
          create: (c) => UserAuthImpl(wrapper),
        ),
        RepositoryProvider<DatabaseUpdateModel>(
            create: (context) =>
                DatabaseUpdateModelImpl(wrapper, null, _analytics)),
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
          title: 'Teams Fuse',
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
    print(routeSettings.name);
    // States on routes.
    final router = RepositoryProvider.of<fluro.FluroRouter>(context);
    return router.generator(routeSettings);
  }
}

class _EmptyHydratedStorage implements Storage {
  @override
  dynamic read(String key) {}

  @override
  Future<void> write(String key, dynamic value) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}
}
