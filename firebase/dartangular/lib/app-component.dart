import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_router/angular_router.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';

import 'route_paths.dart';
import 'routes.dart';

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
  providers: [
    const ClassProvider(Routes),
    materialProviders,
    ClassProvider(UserAuthImpl),
    ClassProvider(DatabaseUpdateModelImpl),
    ClassProvider(AuthenticationBloc),
  ],
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
  ],
)
class AppComponent implements OnInit, OnDestroy {
  final Routes routes;
  final Router _router;
  StreamSubscription<RouterState>? _sub;
  final AuthenticationBloc _auth;

  AppComponent(this.routes, this._router, this._auth);

  @override
  void ngOnInit() async {
    UserData data = await _auth.currentUser;

    _sub = _router.onRouteActivated.listen(_routerStateUpdate);
    if (data == null) {
      print('Current user frog == null ${_router?.current?.path}');

      print("Navigated... ${guest.path}/home");
    } else {
      print('Current user frog == null ${_router?.current?.path}');
      // Authenticated, stay at the old url.
      //UserDatabaseData.load(data.uid, data.email,
      //    UserDatabaseData.instance.userAuth.getProfile(data.uid));
    }
  }

  @override
  void ngOnDestroy() {
    _sub?.cancel();
  }

  void _routerStateUpdate(RouterState state) {
    if (_auth.currentUser == null) {
      print('ROuter state ${state.path}');
      // Logged out.
      if (state.path.startsWith(authed.path)) {
        // Try and switch to the guest version of the url first.
        String newPath = state.path.split("/").sublist(1).join("/");
        print('newpath: $newPath ${state.path}');
        _router.navigate("/" + guest.path + "/" + newPath);
      }
    } else {
      // If we are not verified yet, then go there and keep track of the
      // current path.
      if (!_auth.currentUser.isEmailVerified) {
        _router.navigate("/verify",
            NavigationParams(queryParameters: {'current': state.path}));
      }
      if (state.path.startsWith(guest.path)) {
        // Try the authed version of it.
        String newPath = state.path.split("/").sublist(1).join("/");
        print('newpath: $newPath ${state.path}');
        _router.navigate("/" + authed.path + "/" + newPath);
      }
    }
  }
}
