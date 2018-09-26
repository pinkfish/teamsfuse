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

@Component(
  selector: 'login-form',
  directives: const [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    materialInputDirectives,
    formDirectives
  ],
  templateUrl: 'login-component.html',
  styleUrls: const [
    'login.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class LoginComponent  {
  UserData model = new UserData(profile: new FusedUserProfile(null));
  bool submitting = false;
  bool error = true;
  final Router _router;

  LoginComponent(this._router);

  void onSubmit() {
    submitting = true;
    print('Signing in $model');
    UserDatabaseData.instance.userAuth.signIn(model).then((UserData user) {
      print('signed in $user');
      // Navigate away!
      _router.navigate("/a/games");
      print('Navigate away');
    })
    .catchError((Object e) {
      print('error $e');
      error = false;
    });
  }

  void cancel() {
    _router.navigate("/g/guesthome");
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