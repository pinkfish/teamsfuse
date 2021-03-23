import 'package:fluro/fluro.dart' as fluro;
import '../screens/publicclubhome.dart';
import '../screens/publichome.dart';
import '../screens/publicteam.dart';
import '../screens/publicplayer.dart';

///
/// The main router for the app.  Has all the details for routing and routes
/// for all the parts of the app.
///
class AppRouter {
  ///
  /// Creates the app router to use for the app.  Sets up all the routes
  /// and does stuff.
  ///
  static fluro.FluroRouter createAppRouter() {
    var router = fluro.FluroRouter();

    // Public section
    router.define('/Club/:tab/:id',
        handler: fluro.Handler(
            handlerFunc: (context, vals) => PublicClubHomeScreen(
                  vals['tab'][0].toString(),
                  vals['id'][0].toString(),
                )));

    router.define('/Team/:tab/:id',
        handler: fluro.Handler(
            handlerFunc: (context, vals) => PublicTeamDetailsScreen(
                vals['tab'][0].toString(), vals['id'][0].toString())));

    router.define('/Player/:tab/:playerId',
        handler: fluro.Handler(
            handlerFunc: (context, vals) => PublicPlayerDetailsScreen(
                vals['tab'][0].toString(), vals['playerId'][0].toString())));

    router.define('/Home',
        handler: fluro.Handler(
            handlerFunc: (context, vals) =>
                PublicHomeScreen(PublicMainTab.about.name)));

    router.define('/Home/:tab',
        handler: fluro.Handler(
            handlerFunc: (context, vals) =>
                PublicHomeScreen(vals['tab'][0].toString())));

    return router;
  }
}
