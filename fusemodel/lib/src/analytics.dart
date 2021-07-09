abstract class TraceProxy {
  void start();
  void incrementCounter(String str);
  void stop();
}

abstract class AnalyticsSubsystem {
  void logSignUp({String signUpMethod});

  void logLogin();

  void setUserProperty({String name, String value});

  bool get debugMode;

  TraceProxy newTrace(String traceName);

  void logEvent({String name, Map<String, String> parameters});
  void logInviteAccepted(String inviteType, String invitedTo);

  void recordError(Error error, StackTrace stack);
  void recordException(dynamic error, StackTrace stack);
}
