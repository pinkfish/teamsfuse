import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart' as paths;
import 'package:teamfuse/components/login/needauth-component.template.dart'
    as nactd;
import 'package:teamfuse/components/authed/authed-component.template.dart'
    as actd;
import 'package:teamfuse/components/guest/guest-component.template.dart'
    as gctd;
import 'notfound-component.template.dart' as nfct;
import 'package:teamfuse/components/promo/promo-component.template.dart' as pct;
import 'package:teamfuse/components/login/signup.template.dart' as sct;
import 'package:teamfuse/components/login/verify.template.dart' as vct;
import 'package:teamfuse/components/login/forgot.template.dart' as fct;

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
  static final _promo = new RouteDefinition(
    routePath: paths.promo,
    component: pct.PromoComponentNgFactory,
    useAsDefault: true,
  );

  static final _login = new RouteDefinition(
    routePath: paths.login,
    component: nactd.NeedAuthComponentNgFactory,
  );

  static final _signup = new RouteDefinition(
    routePath: paths.signup,
    component: sct.SignupComponentNgFactory,
  );

  static final _verify = new RouteDefinition(
    routePath: paths.verify,
    component: vct.VerifyComponentNgFactory,
  );

  static final _forgot = new RouteDefinition(
    routePath: paths.forgot,
    component: fct.ForgotComponentNgFactory,
  );

  final List<RouteDefinition> all = [
    _authed,
    _login,
    _guest,
    _promo,
    _signup,
    _verify,
    _forgot,
    new RouteDefinition.redirect(path: '', redirectTo: 'promo/guesthome'),
    new RouteDefinition(
      path: '.*',
      component: nfct.NotFoundComponentNgFactory,
    ),
  ];
}
