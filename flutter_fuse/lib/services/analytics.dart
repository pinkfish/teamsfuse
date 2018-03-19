import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static FirebaseAnalytics _analytics = new FirebaseAnalytics();

  static FirebaseAnalytics get analytics {
    return _analytics;
  }
}
