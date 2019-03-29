abstract class TraceProxy {
  void start();
  void incrementCounter(String str);
  void stop();
}

abstract class AnalyticsSubsystem {
  void logSignUp({String signUpMethod});

  void logLogin();

  void setUserId(String uid);

  void setUserProperty({String name, String value});

  bool get debugMode;

  TraceProxy newTrace(String traceName);
}
