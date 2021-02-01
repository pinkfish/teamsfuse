import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:teamfuse/components/guest/pieces/header.dart';

@Component(
  selector: 'verify-form',
  directives: const [
    MaterialButtonComponent,
    materialInputDirectives,
    formDirectives,
    GuestHeaderComponent,
    NgIf
  ],
  templateUrl: 'forgot.html',
  styleUrls: const [
    'login.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class ForgotComponent {
  String email;
  bool resetSent = false;
  bool error = true;
  final Router _router;
  final LoginBloc _loginBloc;

  ForgotComponent(this._router, this._loginBloc);

  void onSubmit() {
    resetSent = true;
    print('Forgot password in $email');
    _loginBloc.dispatch(LoginEventForgotPasswordSend(email: email));
  }

  void login() {
    _router.navigate("/login");
  }

  void cancel() {
    _router.navigate("/promo/guesthome");
  }

  void signup() {
    _router.navigate("/signup");
  }

  void resendVerifyEmail() {
    UserDatabaseData.instance.userAuth.sendEmailVerification();
  }
}
