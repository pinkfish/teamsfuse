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
import 'dart:async';

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
class AppComponent implements OnInit, OnDestroy {
  final Routes routes;
  final Router _router;
  StreamSubscription<RouterState> _sub;

  AppComponent(this.routes, this._router);

  @override
  void ngOnInit() async {
    UserData data =
        await UserDatabaseData.instance.userAuth.currentUserNoWait();

    _sub = _router.onRouteActivated.listen(_routerStateUpdate);
    if (data == null) {
      print('Current user frog == null ${_router?.current?.path}');

      print("Navigated... ${guest.path}/home");
    } else {
      print('Current user frog == null ${_router?.current?.path}');
      // Authenticated, stay at the old url.
      UserDatabaseData.load(data.uid, data.email,
          UserDatabaseData.instance.userAuth.getProfile(data.uid));
    }
    UserDatabaseData.instance.userAuth.onAuthChanged().listen((UserData u) {
      print('onAuthStateChanged $u');
      if (u != null) {
        UserDatabaseData.load(u.uid, u.email,
            UserDatabaseData.instance.userAuth.getProfile(u.uid));
      } else {
        UserDatabaseData.clear();
      }
    });
  }

  @override
  void ngOnDestroy() {
    _sub.cancel();
  }

  void _routerStateUpdate(RouterState state) {
    if (UserDatabaseData.instance.userAuth.currentUserNoWait() == null) {
      print('ROuter state ${state.path}');
      // Logged out.
      if (!state.path.startsWith(guest.path)) {
        // Try and switch to the guest version of the url first.
        String newPath = state.path.split("/").sublist(1).join("/");
        print('newpath: $newPath ${state.path}');
        _router.navigate("/" + guest.path + "/" + newPath);
      }
    } else {
      if (state.path.startsWith(guest.path)) {
        // Try the authed version of it.
        String newPath = state.path.split("/").sublist(1).join("/");
        print('newpath: $newPath ${state.path}');
        _router.navigate("/" + authed.path + "/" + newPath);
      }
    }
  }
}
