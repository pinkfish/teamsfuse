import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';
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

  ForgotComponent(this._router);

  void onSubmit() {
    resetSent = true;
    print('Forgot password in $email');
    UserDatabaseData.instance.userAuth.sendPasswordResetEmail(email);
  }

  void login() {
    _router.navigate("/login");
  }

  void cancel() {
    _router.navigate("/g/guesthome");
  }

  void signup() {
    _router.navigate("/signup");
  }

  void resendVerifyEmail() {
    UserDatabaseData.instance.userAuth.sendEmailVerification();
  }
}
