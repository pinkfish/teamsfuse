import 'package:fluro/fluro.dart' as fluro;
import '../screens/publichome.dart';

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
    router.define("/Public/:tab/:id",
        handler: fluro.Handler(
            handlerFunc: (context, vals) => PublicHomeScreen(
                vals["tab"][0].toString(), vals["id"][0].toString(), null)));

    router.define("/Public/:tab/:id/:id2",
        handler: fluro.Handler(
            handlerFunc: (context, vals) => PublicHomeScreen(
                vals["tab"][0].toString(),
                vals["id"][0].toString(),
                vals["id2"][0].toString())));

    return router;
  }
}