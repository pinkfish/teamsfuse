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

class AuthenticationLoggedIn extends AuthenticationState {
  AuthenticationLoggedIn({@required UserData user}) : super(user: user);

  @override
  String toString() => "AuthenticationState::AuthenticatonLoggedIn";
}

class AuthenticationLoggedInUnverified extends AuthenticationState {
  AuthenticationLoggedInUnverified({@required UserData user})
      : super(user: user);

  @override
  String toString() => "AuthenticationState::AuthenticationLoggedInUnverified";
}

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

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => "AppStarted";
}

class LoggedIn extends AuthenticationEvent {
  final UserData user;

  LoggedIn({@required this.user});

  @override
  String toString() => "LoggedIn";
}

class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => "LoggedOut";
}

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
    if (event is AppStarted) {
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

    if (event is LoggedIn) {
      LoggedIn loggedInEvent = event;
      yield AuthenticationLoading();
      yield await _updateWithUser(loggedInEvent.user);
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userAuth.signOut();
      // Finished logging out.
      yield AuthenticationLoggedOut();
    }
  }

  void _authChanged(UserData user) async {
    if (user != null) {
      dispatch(LoggedIn(user: user));
    } else {
      dispatch(LoggedOut());
    }
  }
}
