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

  @override
  // TODO: implement debugMode
  bool get debugMode => throw UnimplementedError();

  @override
  void logEvent({String name, Map<String, String> parameters}) {
    // TODO: implement logEvent
  }

  @override
  void logInviteAccepted(String inviteType, String invitedTo) {
    // TODO: implement logInviteAccepted
  }

  @override
  void logLogin() {
    // TODO: implement logLogin
  }

  @override
  void recordError(Error error, StackTrace stack) {
    // TODO: implement recordError
  }

  @override
  void recordException(Exception error, StackTrace stack) {
    // TODO: implement recordException
  }

  @override
  void setUserId(String uid) {
    // TODO: implement setUserId
  }

  @override
  void setUserProperty({String name, String value}) {
    // TODO: implement setUserProperty
  }
}
