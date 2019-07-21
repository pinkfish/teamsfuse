import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

///
/// States for the authentication bloc.
///
abstract class AuthenticationState extends Equatable {
  final UserData user;

  AuthenticationState({@required this.user});
}

class AuthenticationUninitialized extends AuthenticationState {
  AuthenticationUninitialized() : super(user: null);

  @override
  String toString() => "AuthenticationState::AuthenticatonUninitialized";
}

class AuthenticationLoading extends AuthenticationState {
  AuthenticationLoading() : super(user: null);

  @override
  String toString() => "AuthenticationState::AuthenticationLoading";
}

///
/// The user is logged in.
///
class AuthenticationLoggedIn extends AuthenticationState {
  AuthenticationLoggedIn({@required UserData user}) : super(user: user);

  @override
  String toString() => "AuthenticationState::AuthenticatonLoggedIn";
}

///
/// The user is logged in, but unvierified.
///
class AuthenticationLoggedInUnverified extends AuthenticationState {
  AuthenticationLoggedInUnverified({@required UserData user})
      : super(user: user);

  @override
  String toString() => "AuthenticationState::AuthenticationLoggedInUnverified";
}

///
/// The user is logged out.
///
class AuthenticationLoggedOut extends AuthenticationState {
  AuthenticationLoggedOut() : super(user: null);

  @override
  String toString() => "AuthenticationState::AuthenticatonUninitialized";
}

///
/// Events associated with the authentication bloc
///
abstract class AuthenticationEvent extends Equatable {
  AuthenticationEvent([List props = const []]) : super(props);
}

///
/// Called when the app starts to setup stuff.
///
class AuthenticationAppStarted extends AuthenticationEvent {
  @override
  String toString() => "AppStarted";
}

class _AuthenticationLogIn extends AuthenticationEvent {
  final UserData user;

  _AuthenticationLogIn({@required this.user});

  @override
  String toString() => "LoggedIn";
}

///
/// Logs the current user out.
///
class AuthenticationLogOut extends AuthenticationEvent {
  @override
  String toString() => "LoggedOut";
}

///
/// Updates the notification token so we can receive notifications.
///
class AuthenticationNotificationToken extends AuthenticationEvent {
  final String notificationToken;

  AuthenticationNotificationToken(@required this.notificationToken);
}

///
/// This bloc deals with all the pieces related to authentication.
///
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserAuthImpl userAuth;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<UserData> _listener;

  @override
  AuthenticationState get initialState {
    return AuthenticationUninitialized();
  }

  AuthenticationBloc(
      {@required this.userAuth, @required this.analyticsSubsystem});

  @override
  void dispose() {
    super.dispose();
    _listener?.cancel();
  }

  UserData get currentUser {
    if (currentState is AuthenticationLoggedIn) {
      return (currentState as AuthenticationLoggedIn).user;
    }
    return null;
  }

  Future<AuthenticationState> _updateWithUser(UserData user) async {
    if (user.isEmailVerified) {
      analyticsSubsystem.setUserId(user.uid);
      if (analyticsSubsystem.debugMode) {
        analyticsSubsystem.setUserProperty(name: "developer", value: "true");
      } else {
        analyticsSubsystem.setUserProperty(name: "developer", value: "false");
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
      _listener = userAuth.onAuthChanged().listen(_authChanged);
      UserData data = await userAuth.currentUser();
      if (data == null) {
        yield AuthenticationLoggedOut();
      } else {
        yield AuthenticationLoading();
        yield await _updateWithUser(data);
      }

      // Wait on updates to this.
    }

    if (event is _AuthenticationLogIn) {
      _AuthenticationLogIn loggedInEvent = event;
      yield AuthenticationLoading();
      yield await _updateWithUser(loggedInEvent.user);
    }

    if (event is AuthenticationLogOut) {
      yield AuthenticationLoading();
      await userAuth.signOut();
      // Finished logging out.
      yield AuthenticationLoggedOut();
    }

    if (event is AuthenticationNotificationToken) {
      // Ignore the errors here.
      userAuth.setNotificationToken(event.notificationToken);
    }
  }

  void _authChanged(UserData user) async {
    if (user != null) {
      dispatch(_AuthenticationLogIn(user: user));
    } else {
      dispatch(AuthenticationLogOut());
    }
  }
}
