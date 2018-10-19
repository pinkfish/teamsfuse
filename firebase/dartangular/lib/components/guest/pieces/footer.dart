import 'package:angular/angular.dart';

import 'package:angular_router/angular_router.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';

@Component(
  selector: 'guest-footer',
  templateUrl: 'footer.html',
  directives: [
    MaterialButtonComponent,
    MaterialIconComponent,
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    '../guest-component.css',
  ],
)
class GuestFooterComponent {
  final Router _router;

  void createAccount() {
    _router.navigate("/signup");
  }

  GuestFooterComponent(this._router);
}
