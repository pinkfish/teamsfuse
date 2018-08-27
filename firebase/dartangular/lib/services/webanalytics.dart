import 'package:fusemodel/fusemodel.dart';

class WebTrace implements TraceProxy {
  @override
  void start() {}

  @override
  void stop() {}

  @override
  void incrementCounter(String str) {}
}

class WebAnalytics implements AnalyticsSubsystem {
  @override
  void logSignUp({String signUpMethod}) {}

  @override
  TraceProxy newTrace(String traceName) {
    return new WebTrace();
  }
}
