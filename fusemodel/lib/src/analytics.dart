abstract class TraceProxy {
  void start();
  void incrementCounter(String str);
  void stop();
}

abstract class AnalyticsSubsystem {
  void logSignUp({String signUpMethod});

  TraceProxy newTrace(String traceName);
}
