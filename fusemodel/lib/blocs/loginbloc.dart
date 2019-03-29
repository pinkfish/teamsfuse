import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

///
/// Basic login state
///
class LoginState extends Equatable {}

///
/// Initial state (showing the login form)
///
class LoginInitial extends LoginState {
  @override
  String toString() {
    return 'LoginInitial{}';
  }
}

///
/// Validating the login
///
class LoginValidating extends LoginState {
  @override
  String toString() {
    return 'LoginValidating{}';
  }
}

enum LoginFailedReason {
  BadPassword,
}

///
/// The login failed.
///
class LoginFailed extends LoginState {
  final UserData userData;
  final LoginFailedReason reason;

  LoginFailed({@required this.userData, @required this.reason});

  @override
  String toString() {
    return 'LoginFailed{}';
  }
}

///
/// The login succeeded.
///
class LoginSucceeded extends LoginState {
  final UserData userData;

  LoginSucceeded({@required this.userData});

  @override
  String toString() {
    return 'LoginSucceeded{}';
  }
}

///
/// Validating the forgot password request
///
class LoginValidatingForgotPassword extends LoginState {
  @override
  String toString() {
    return 'LoginValidatingForgotPassword{}';
  }
}

///
/// The forgot password flow is done.
///
class LoginForgotPasswordDone extends LoginState {
  @override
  String toString() {
    return 'LoginForgotPasswordDone{}';
  }
}

///
/// The forgot password attempt failed
///
class LoginForgotPasswordFailed extends LoginState {
  final Error error;

  LoginForgotPasswordFailed({@required this.error});

  @override
  String toString() {
    return 'LoginForgotPasswordDone{}';
  }
}

///
/// Validating the signup flow.
///
class LoginValidatingSignup extends LoginState {
  @override
  String toString() {
    return 'LoginValidatingSignup{}';
  }
}

///
/// The signup attempt failed.
///
class LoginSignupFailed extends LoginState {
  final UserData userData;
  final FusedUserProfile profile;

  LoginSignupFailed({@required this.userData, @required this.profile});

  @override
  String toString() {
    return 'LoginSignupFailed{}';
  }
}

///
/// The signup attempt was successeful
///
class LoginSignupSucceeded extends LoginState {
  final UserData userData;

  LoginSignupSucceeded({@required this.userData});

  @override
  String toString() {
    return 'LoginSignupSucceeded{}';
  }
}

class LoginEvent extends Equatable {}

///
/// Reset the state of the login system
///
class LoginEventReset extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventReset{}';
  }
}

///
/// Sends a login attempt request.
///
class LoginEventAttempt extends LoginEvent {
  final String email;
  final String password;

  LoginEventAttempt({@required this.email, @required this.password});

  @override
  String toString() {
    return 'LoginEventAttempt{user: $email}';
  }
}

///
/// Sends a forgot password request.
///
class LoginEventForgotPasswordSend extends LoginEvent {
  final String email;

  LoginEventForgotPasswordSend({@required this.email});

  @override
  String toString() {
    return 'LoginEventForgotPassword{user: $email}';
  }
}

///
/// Requests signing up the user.
///
class LoginEventSignupUser extends LoginEvent {
  final String email;
  final String password;
  final String displayName;
  final String phoneNumber;

  LoginEventSignupUser(
      {@required this.email,
      @required this.password,
      @required this.displayName,
      @required this.phoneNumber});

  @override
  String toString() {
    return 'LoginEventSignupUser{user: $email}';
  }
}

///
/// Login bloc handles the login flow.  Password, reset, etc,
///
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserAuthImpl userAuth;
  final AnalyticsSubsystem analyticsSubsystem;

  LoginBloc({@required this.userAuth, @required this.analyticsSubsystem});

  @override
  LoginState get initialState {
    return new LoginInitial();
  }

  @override
  Stream<LoginState> mapEventToState(
      LoginState currentState, LoginEvent event) async* {
    if (event is LoginEventReset) {
      yield LoginInitial();
    }
    if (event is LoginEventAttempt) {
      yield LoginValidating();
      LoginEventAttempt attempt = event;
      UserData data =
          new UserData(email: attempt.email, password: attempt.password);
      UserData signedIn;
      try {
        signedIn = await userAuth.signIn(data);
      } catch (error) {
        // Failed to login, probably bad password.
        yield LoginFailed(
            userData: signedIn, reason: LoginFailedReason.BadPassword);
      }

      if (signedIn != null) {
        analyticsSubsystem.logLogin();
        // Reload the user.
        userAuth.reloadUser();
        yield LoginSucceeded(userData: signedIn);
      }
    }
    if (event is LoginEventForgotPasswordSend) {
      yield LoginValidatingForgotPassword();

      LoginEventForgotPasswordSend forgot = event;
      try {
        await userAuth.sendPasswordResetEmail(forgot.email);
        yield LoginForgotPasswordDone();
      } catch (error) {
        yield LoginForgotPasswordFailed(error: error);
      }
    }
    if (event is LoginEventSignupUser) {
      yield LoginValidatingSignup();
      LoginEventSignupUser signup = event;
      UserData user =
          new UserData(email: signup.email, password: signup.password);
      FusedUserProfile profile = new FusedUserProfile(null,
          displayName: signup.displayName,
          phoneNumber: signup.phoneNumber,
          email: signup.email);
      UserData data = await userAuth.createUser(user, profile);
      if (data == null) {
        yield LoginSignupFailed(userData: user, profile: profile);
      } else {
        yield LoginSignupSucceeded(userData: data);
      }
    }
  }
}
