// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart' as paths;
import 'package:teamfuse/components/home/loading-component.template.dart' as lctd;
import 'package:teamfuse/components/login/needauth-component.template.dart' as nactd;
import 'package:teamfuse/components/authed/authed-component.template.dart' as actd;
import 'package:teamfuse/components/guest/guest-component.template.dart' as gctd;
import 'notfound-component.template.dart' as nfct;


@Injectable()
class Routes {
  static final _authed = new RouteDefinition(
    routePath: paths.authed,
    component: actd.AuthedComponentNgFactory,
  );
  static final _guest = new RouteDefinition(
    routePath: paths.guest,
    component: gctd.GuestComponentNgFactory,
  );
  static final _loading = new RouteDefinition(
    routePath: paths.loading,
    component: lctd.LoadingComponentNgFactory,
    useAsDefault: true,
  );
  static final _login = new RouteDefinition(
    routePath: paths.login,
    component:nactd.NeedAuthComponentNgFactory,
  );

  final List<RouteDefinition> all = [
    _authed,
    _loading,
    _login,
    _guest,
     new RouteDefinition(
      path: '.*',
      component: nfct.NotFoundComponentNgFactory,
    ),
  ];
}