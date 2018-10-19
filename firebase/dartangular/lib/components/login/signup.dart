import 'package:angular/angular.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';
import 'package:teamfuse/components/guest/pieces/header.dart';

@Component(
  selector: 'login-form',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    materialInputDirectives,
    formDirectives,
    PasswordCheckValidator,
    GuestHeaderComponent,
  ],
  templateUrl: 'signup.html',
  styleUrls: const [
    'login.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class SignupComponent {
  UserData model = new UserData(profile: new FusedUserProfile(null));
  bool submitting = false;
  bool error = true;
  final Router _router;
  String passwordCheck;
  String displayName;

  SignupComponent(this._router);

  void onSubmit() {
    FusedUserProfile profile =
        new FusedUserProfile(null, displayName: displayName);
    submitting = true;
    print('Creating $model');
    UserDatabaseData.instance.userAuth
        .createUser(model, profile)
        .then((UserData user) {
      print('created in $user');
      // Navigate away!
      _router.navigate("/a/games");
      print('Navigate away');
    }).catchError((Object e) {
      print('error $e');
      error = false;
    });
  }

  void cancel() {
    _router.navigate("/g/guesthome");
  }

  void login() {
    _router.navigate("/login");
  }

  void forgotPassword() {
    _router.navigate('/forgot');
  }

  String emailValidator(String inputText) {
    if (inputText.isEmpty) {
      return null;
    }

    if (!inputText.contains('@')) {
      return 'Need an @ in an email address.';
    }

    return null;
  }

  Map<String, bool> setCssValidityClass(NgControl control) {
    final validityClass = control.valid == true ? 'is-valid' : 'is-invalid';
    return {validityClass: true};
  }
}

@Directive(selector: '[passwordCheck]', providers: const [
  const ExistingProvider.forToken(
    NG_VALIDATORS,
    PasswordCheckValidator,
  ),
])
class PasswordCheckValidator implements Validator {
  @HostBinding('attr.passwordCheck')
  String passwordCheckAttr;

  @Input('passwordCheck')
  set minLength(String value) {
     passwordCheckAttr = value;
  }

  @override
  Map<String, dynamic> validate(AbstractControl c) {
    final v = c?.value?.toString();
    if (v == null || v == '') return null;
    print('Checking $v $passwordCheckAttr');
    return v != passwordCheckAttr
        ? {
            'pattern': 'Password must match!'
          }
        : null;
  }
}
