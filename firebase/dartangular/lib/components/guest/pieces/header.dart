import 'package:angular/angular.dart';

import 'package:angular_router/angular_router.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:teamfuse/components/common/search.dart';

@Component(
  selector: 'guest-header',
  templateUrl: 'header.html',
  directives: [
    RouterLink,
    MaterialButtonComponent,
    MaterialIconComponent,
    SearchComponent,
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    '../guest-component.css',
  ],
  //providers: const [HeroService],
)
class GuestHeaderComponent implements OnActivate {
  final Router _router;

  @override
  void onActivate(RouterState previous, RouterState current) {}

  void signIn() {
    _router.navigate("/login");
  }

  void gotoHome() {
    _router.navigate("/promo/guesthome");
  }

  GuestHeaderComponent(this._router);
}
