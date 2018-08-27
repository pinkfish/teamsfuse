import 'package:angular/angular.dart';

import 'package:fusemodel/fusemodel.dart';
import 'package:angular_router/angular_router.dart';
import 'routes.dart';
import 'route_paths.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/angular_components.dart';
import 'package:fusemodel/firestore.dart';

@Component(
  selector: 'my-app',
  template: '''
         <router-outlet [routes]="routes.all"></router-outlet>
   ''',
  directives: [
    RouterLink,
    RouterOutlet,
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent
  ],
  providers: [const ClassProvider(Routes), materialProviders],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class AppComponent implements OnInit {
  final Routes routes;
  final Router _router;

  AppComponent(this.routes, this._router);

  @override
  ngOnInit() async {
    UserData data =
        await UserDatabaseData.instance.userAuth.currentUserNoWait();
    if (data == null) {
      print('Current user frog == null');
      _router.navigate("/" + login.path + "/login");
      print("Navigated... ${login.path}");
    } else {
      // Authenticated, stay at the old url.
      UserDatabaseData.load(data.uid, data.email,
          UserDatabaseData.instance.userAuth.getProfile(data.uid));
    }
    UserDatabaseData.instance.userAuth.onAuthChanged().listen((UserData u) {
      print('onAuthStateChanged $u');
      if (u != null) {
        UserDatabaseData.load(u.uid, u.email,
            UserDatabaseData.instance.userAuth.getProfile(u.uid));
        this._router.navigate("/a/games");
      } else {
        UserDatabaseData.clear();
      }
    });
  }
}
