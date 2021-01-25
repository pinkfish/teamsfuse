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

  @override
  List<Object> get props => [user];
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
  AuthenticationEvent() : super();
}

///
/// Called when the app starts to setup stuff.
///
class AuthenticationAppStarted extends AuthenticationEvent {
  @override
  String toString() => "AppStarted";

  @override
  List<Object> get props => [];
}

class _AuthenticationLogIn extends AuthenticationEvent {
  final UserData user;

  _AuthenticationLogIn({@required this.user});

  @override
  String toString() => "LoggedIn";

  @override
  List<Object> get props => [user];
}

///
/// Logs the current user out.
///
class AuthenticationLogOut extends AuthenticationEvent {
  @override
  String toString() => "LoggedOut";

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
/// This bloc deals with all the pieces related to authentication.
///
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserAuthImpl userAuth;
  final AnalyticsSubsystem analyticsSubsystem;

  StreamSubscription<UserData> _listener;

  AuthenticationBloc(
      {@required this.userAuth, @required this.analyticsSubsystem})
      : super(AuthenticationUninitialized()) {
    _listener = userAuth.onAuthChanged().listen(_authChanged);
  }

  @override
  Future<void> close() async {
    await super.close();
    _listener?.cancel();
  }

  UserData get currentUser {
    if (state is AuthenticationLoggedIn) {
      return (state as AuthenticationLoggedIn).user;
    }
    return null;
  }

  AuthenticationState _updateWithUser(UserData user) {
    if (user.isEmailVerified) {
      analyticsSubsystem.setUserId(user.uid);
      if (analyticsSubsystem.debugMode) {
        analyticsSubsystem.setUserProperty(name: "developer", value: "true");
      } else {
        analyticsSubsystem.setUserProperty(name: "developer", value: "false");
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
      UserData data = await userAuth.currentUser();
      if (data == null) {
        yield AuthenticationLoggedOut();
      } else {
        try {
          var state = _updateWithUser(data);
          yield state;
        } catch (e, stacktrace) {
          print("Error loading $e $stacktrace");
          yield AuthenticationLoggedOut();
        }
      }
    }

    if (event is _AuthenticationLogIn) {
      _AuthenticationLogIn loggedInEvent = event;
      var state = _updateWithUser(loggedInEvent.user);
      if (state != null) {
        yield state;
      }
    }

    if (event is AuthenticationLogOut) {
      if (!(state is AuthenticationLoggedOut)) {
        yield AuthenticationLoading();
        await userAuth.signOut();
        // Finished logging out.
        yield AuthenticationLoggedOut();
      }
    }

    if (event is AuthenticationNotificationToken) {
      // Ignore the errors here.
      userAuth.setNotificationToken(event.notificationToken);
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
