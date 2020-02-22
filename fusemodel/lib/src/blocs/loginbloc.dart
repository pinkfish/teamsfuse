import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

///
/// Basic login state
///
abstract class LoginState extends Equatable {
  LoginState();
}

///
/// Initial state (showing the login form)
///
class LoginInitial extends LoginState {
  @override
  String toString() {
    return 'LoginInitial{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Validating the login
///
class LoginValidating extends LoginState {
  @override
  String toString() {
    return 'LoginValidating{}';
  }

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [userData, reason];
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

  @override
  List<Object> get props => [userData];
}

///
/// The login succeeded.
///
class LoginEmailNotValidated extends LoginState {
  final UserData userData;

  LoginEmailNotValidated({@required this.userData});

  @override
  String toString() {
    return 'LoginEmailNotValidated{}';
  }

  @override
  List<Object> get props => [userData];
}

///
/// Validating the forgot password request
///
class LoginValidatingForgotPassword extends LoginState {
  @override
  String toString() {
    return 'LoginValidatingForgotPassword{}';
  }

  @override
  List<Object> get props => [];
}

///
/// The forgot password flow is done.
///
class LoginForgotPasswordDone extends LoginState {
  @override
  String toString() {
    return 'LoginForgotPasswordDone{}';
  }

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [error];
}

///
/// The forgot password flow is done.
///
class LoginVerificationDone extends LoginState {
  @override
  String toString() {
    return 'LoginVerificationDone{}';
  }

  @override
  List<Object> get props => [];
}

///
/// The forgot password attempt failed
///
class LoginVerificationFailed extends LoginState {
  final Error error;

  LoginVerificationFailed({@required this.error});

  @override
  String toString() {
    return 'LoginVerificationFailed{}';
  }

  @override
  List<Object> get props => [error];
}

///
/// Validating the signup flow.
///
class LoginValidatingSignup extends LoginState {
  @override
  String toString() {
    return 'LoginValidatingSignup{}';
  }

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [userData, profile];
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

  @override
  List<Object> get props => [userData];
}

abstract class LoginEvent extends Equatable {}

///
/// Reset the state of the login system
///
class LoginEventReset extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventReset{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Reloads the user to correct state
///
class LoginEventReload extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventReset{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Logs  the user to out
///
class LoginEventLogout extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventLogout{}';
  }

  @override
  List<Object> get props => [];
}

///
/// Resends an email to the user.
///
class LoginEventResendEmail extends LoginEvent {
  @override
  String toString() {
    return 'LoginEventResendEmail{}';
  }

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [email, password];
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

  @override
  List<Object> get props => [email];
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

  @override
  List<Object> get props => [email, password, displayName, phoneNumber];
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
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEventReset) {
      yield LoginInitial();
    }
    if (event is LoginEventReload) {
      userAuth.reloadUser();
    }
    if (event is LoginEventLogout) {
      userAuth.signOut();
    }
    if (event is LoginEventResendEmail) {
      userAuth.sendEmailVerification();
    }
    if (event is LoginEventAttempt) {
      yield LoginValidating();
      LoginEventAttempt attempt = event;
      UserData data = new UserData((b) => b
        ..email = attempt.email
        ..password = attempt.password);
      print(data);
      UserData signedIn;
      try {
        signedIn = await userAuth.signIn(data);
      } catch (error) {
        print('Error: ${error}');
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
      UserData user = new UserData((b) => b
        ..email = signup.email
        ..password = signup.password);
      FusedUserProfile profile = new FusedUserProfile((b) => b
        ..displayName = signup.displayName
        ..phoneNumber = signup.phoneNumber
        ..email = signup.email
        ..emailOnUpdates = true
        ..emailUpcomingGame = true
        ..notifyOnlyForGames = true);
      UserData data = await userAuth.createUser(user, profile);
      if (data == null) {
        yield LoginSignupFailed(userData: user, profile: profile);
      } else {
        yield LoginSignupSucceeded(userData: data);
      }
    }
  }
}
