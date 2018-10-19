import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';
import 'package:teamfuse/components/guest/pieces/header.dart';

@Component(
  selector: 'verify-form',
  directives: const [
    MaterialButtonComponent,
    GuestHeaderComponent,
    NgIf
  ],
  templateUrl: 'verify.html',
  styleUrls: const [
    'login.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class VerifyComponent {
  UserData model = new UserData(profile: new FusedUserProfile(null));
  bool resentEmail = false;
  bool error = true;
  final Router _router;

  VerifyComponent(this._router);

  void login() {
    _router.navigate("/login");
  }

  void cancel() {
    _router.navigate("/g/guesthome");
  }

  void signup() {
    _router.navigate("/signup");
  }

  void forgotPassword() {
    _router.navigate('/forgot');
  }


  void resendVerifyEmail() {
    resentEmail = true;
    UserDatabaseData.instance.userAuth.sendEmailVerification();
  }
}
