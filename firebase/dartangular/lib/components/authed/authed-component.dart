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

@Component(
  selector: 'my-app',
  template: '''
  <material-drawer persistent #drawer="drawer">
    <teamfuse-drawer ></teamfuse-drawer>
  </material-drawer>
  <div class="material-content">
    <header class="material-header shadow">
        <div class="material-header-row">
            <material-button icon
                             class="material-drawer-button" (trigger)="drawer.toggle()">
                <material-icon icon="menu"></material-icon>
            </material-button>
            <span class="material-header-title">Team Fuse</span>
            <div class="material-spacer"></div>
        </div>
    </header>
    
    <div>
        <router-outlet [routes]="routes.all"></router-outlet>
    </div>
  </div>
  ''',
  directives: [
    RouterLink,
    RouterOutlet,
    DeferredContentDirective,
    MaterialPersistentDrawerDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    Drawer
  ],
  providers: [
    const ClassProvider(Routes),
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],

  //providers: const [HeroService],
)
class AuthedComponent {
  final Routes routes;

  AuthedComponent(this.routes);
}
