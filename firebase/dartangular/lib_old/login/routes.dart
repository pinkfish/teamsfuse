// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'login-component.template.dart' as lctd;
import 'route_paths.dart' as paths;

@Injectable()
class Routes {
  static final _login = new RouteDefinition(
    routePath: paths.login,
    component: lctd.LoginComponentNgFactory as ComponentFactory,
    useAsDefault: true,
  );

  RouteDefinition get login => _login;

  final List<RouteDefinition> all = [_login];
}
