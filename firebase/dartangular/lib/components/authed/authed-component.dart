import 'package:angular/angular.dart';

import 'package:angular_router/angular_router.dart';
import 'routes.dart';
import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:teamfuse/components/drawer/drawer.dart';
import '../common/search.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'authed-component.html',
  directives: [
    RouterLink,
    RouterOutlet,
    SearchComponent,
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    Drawer
  ],
  providers: [
    const ClassProvider(AuthedRoutes),
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class AuthedComponent {
  final AuthedRoutes routes;

  AuthedComponent(this.routes);
}
