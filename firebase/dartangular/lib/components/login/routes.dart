// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart' as paths;
import 'login-component.template.dart' as lctd;

@Injectable()
class Routes {
  static final _login = new RouteDefinition(
    routePath: paths.login,
    component: lctd.LoginComponentNgFactory,
    useAsDefault: true,
  );

  RouteDefinition get login => _login;

  final List<RouteDefinition> all = [
    _login
  ];
}