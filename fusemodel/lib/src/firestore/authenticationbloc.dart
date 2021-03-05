import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

/// The reason the login failed.
enum LoginFailedReason {
  /// Bad password logging in.
  BadPassword,
}

///
/// States for the authentication bloc.
///
abstract class AuthenticationState extends Equatable {
  final UserData user;

  AuthenticationState({@required this.user});

  @override
  List<Object> get props => [user];
}

/// The auth state is unknown.
class AuthenticationUninitialized extends AuthenticationState {
  AuthenticationUninitialized() : super(user: null);

  @override
  String toString() => 'AuthenticationState::AuthenticatonUninitialized';
}

/// The auth state is loading.
class AuthenticationLoading extends AuthenticationState {
  AuthenticationLoading() : super(user: null);

  @override
  String toString() => 'AuthenticationState::AuthenticationLoading';
}

/// The auth operation is done.
class AuthenticationDone extends AuthenticationState {
  AuthenticationDone() : super(user: null);

  @override
  String toString() => 'AuthenticationState::AuthenticationDone';
}

///
/// The user is logged in.
///
class AuthenticationLoggedIn extends AuthenticationState {
  AuthenticationLoggedIn({@required UserData user}) : super(user: user);

  @override
  String toString() => 'AuthenticationState::AuthenticatonLoggedIn';
}

///
/// The user is logged in, but unvierified.
///
class AuthenticationLoggedInUnverified extends AuthenticationState {
  AuthenticationLoggedInUnverified({@required UserData user})
      : super(user: user);

  @override
  String toString() => 'AuthenticationState::AuthenticationLoggedInUnverified';
}

///
/// The user is logged out.
///
class AuthenticationLoggedOut extends AuthenticationState {
  AuthenticationLoggedOut() : super(user: null);

  @override
  String toString() => 'AuthenticationState::AuthenticatonUninitialized';
}

///
/// The login failed.
///
class AuthenticationFailed extends AuthenticationState {
  final UserData userData;
  final LoginFailedReason reason;
  final dynamic error;

  AuthenticationFailed({this.userData, this.reason, this.error});

  @override
  String toString() {
    return 'LoginFailed{}';
  }

  @override
  List<Object> get props => [userData, reason];
}

///
/// Events associated with the authentication bloc
///
abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent() : super();
}

///
/// Called when the app starts to setup stuff.
///
class AuthenticationAppStarted extends AuthenticationEvent {
  @override
  String toString() => 'AppStarted';

  @override
  List<Object> get props => [];
}

class _AuthenticationLogIn extends AuthenticationEvent {
  final UserData user;

  _AuthenticationLogIn({@required this.user});

  @override
  String toString() => 'LoggedIn';

  @override
  List<Object> get props => [user];
}

///
/// Logs the current user out.
///
class AuthenticationLogOut extends AuthenticationEvent {
  @override
  String toString() => 'LoggedOut';

  @override
  List<Object> get props => [];
}

///
/// Updates the notification token so we can receive notifications.
///
class AuthenticationNotificationToken extends AuthenticationEvent {
  final String notificationToken;

  AuthenticationNotificationToken(this.notificationToken);

  @override
  List<Object> get props => [notificationToken];
}

///
/// Updates the notification token so we can receive notifications.
///
class AuthenticationResendEmail extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

///
/// Sends a login attempt request.
///
class AuthenticationLoginAttempt extends AuthenticationEvent {
  final String email;
  final String password;

  AuthenticationLoginAttempt({@required this.email, @required this.password});

  @override
  String toString() {
    return 'AuthenticationLoginAttempt{user: $email}';
  }

  @override
  List<Object> get props => [email, password];
}

///
/// Sends a forgot password request.
///
class AuthenticationForgotPasswordSend extends AuthenticationEvent {
  final String email;

  AuthenticationForgotPasswordSend({@required this.email});

  @override
  String toString() {
    return 'AuthenticationForgotPasswordSend{user: $email}';
  }

  @override
  List<Object> get props => [email];
}

///
/// Requests signing up the user.
///
class AuthenticationSignupUser extends AuthenticationEvent {
  final String email;
  final String password;
  final String displayName;
  final String phoneNumber;

  AuthenticationSignupUser(
      {@required this.email,
      @required this.password,
      @required this.displayName,
      @required this.phoneNumber});

  @override
  String toString() {
    return 'AuthenticationSignupUser{user: $email}';
  }

  @override
  List<Object> get props => [email, password, displayName, phoneNumber];
}

///
/// This bloc deals with all the pieces related to authentication.
///
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserAuthImpl userAuth;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<UserData> _listener;

  AuthenticationBloc(this.userAuth, @required this.analyticsSubsystem)
      : super(AuthenticationUninitialized()) {
    print('Made with $userAuth $analyticsSubsystem');
    _listener = userAuth.onAuthChanged().listen(_authChanged);
  }

  @override
  Future<void> close() async {
    await super.close();
    await _listener?.cancel();
  }

  UserData get currentUser {
    if (state is AuthenticationLoggedIn) {
      return (state as AuthenticationLoggedIn).user;
    }
    return null;
  }

  AuthenticationState _updateWithUser(UserData user) {
    if (user == null) {
      return AuthenticationLoggedOut();
    } else if (user.isEmailVerified) {
      analyticsSubsystem.setUserId(user.uid);
      if (analyticsSubsystem.debugMode) {
        analyticsSubsystem.setUserProperty(name: 'developer', value: 'true');
      } else {
        analyticsSubsystem.setUserProperty(name: 'developer', value: 'false');
      }

      if (currentUser != null) {
        if (user == currentUser) {
          return null;
        }
      }

      return AuthenticationLoggedIn(user: user);
    } else {
      return AuthenticationLoggedInUnverified(user: user);
    }
  }

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AuthenticationAppStarted) {
      var data = await userAuth.currentUser();
      if (data == null) {
        yield AuthenticationLoggedOut();
      } else {
        try {
          yield _updateWithUser(data);
        } catch (e, stacktrace) {
          print('Error loading $e $stacktrace');
          yield AuthenticationFailed(error: e);
          yield AuthenticationLoggedOut();
          analyticsSubsystem.recordException(e, stacktrace);
        }
      }
    }

    if (event is _AuthenticationLogIn) {
      var loggedInEvent = event;
      yield _updateWithUser(loggedInEvent.user);
    }

    if (event is AuthenticationLogOut) {
      if (!(state is AuthenticationLoggedOut)) {
        yield AuthenticationLoading();
        await userAuth.signOut();
        // Finished logging out.
        yield AuthenticationDone();
        yield AuthenticationLoggedOut();
      }
    }

    if (event is AuthenticationNotificationToken) {
      // Ignore the errors here.
      await userAuth.setNotificationToken(event.notificationToken);
    }

    if (event is AuthenticationResendEmail) {
      await userAuth.sendEmailVerification();
    }

    if (event is AuthenticationLoginAttempt) {
      yield AuthenticationLoading();
      var attempt = event;
      var data = UserData((b) => b
        ..uid = 'unknown'
        ..isEmailVerified = false
        ..email = attempt.email
        ..password = attempt.password);
      UserData signedIn;
      try {
        signedIn = await userAuth.signIn(data);
      } catch (error, stack) {
        // Failed to login, probably bad password.
        yield AuthenticationFailed(
            userData: signedIn, reason: LoginFailedReason.BadPassword);
        analyticsSubsystem.recordException(error, stack);
      }

      if (signedIn != null) {
        yield AuthenticationDone();
        analyticsSubsystem.logLogin();
        yield _updateWithUser(signedIn);
      } else {
        yield AuthenticationLoggedOut();
      }
    }
    if (event is AuthenticationForgotPasswordSend) {
      yield AuthenticationLoading();

      var forgot = event;
      try {
        await userAuth.sendPasswordResetEmail(forgot.email);
        yield AuthenticationDone();
        yield AuthenticationLoggedOut();
      } catch (error) {
        yield AuthenticationFailed(error: error);
      }
    }
    if (event is AuthenticationSignupUser) {
      yield AuthenticationLoading();
      var signup = event;
      var user = UserData((b) => b
        ..email = signup.email
        ..password = signup.password);
      var profile = FusedUserProfile((b) => b
        ..displayName = signup.displayName
        ..phoneNumber = signup.phoneNumber
        ..email = signup.email
        ..emailOnUpdates = true
        ..emailUpcomingGame = true
        ..notifyOnlyForGames = true);
      var data = await userAuth.createUser(user, profile);
      if (data == null) {
        yield AuthenticationFailed(userData: user);
        yield AuthenticationLoggedOut();
      } else {
        yield AuthenticationDone();
        yield _updateWithUser(data);
      }
    }
  }

  void _authChanged(UserData user) async {
    if (user != null) {
      add(_AuthenticationLogIn(user: user));
    } else {
      add(AuthenticationLogOut());
    }
  }
}
