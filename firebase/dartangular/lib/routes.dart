import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
//import 'package:teamfuse/components/authed/authed-component.template.dart'
//    as actd;
import 'package:teamfuse/components/guest/guest-component.template.dart'
    as gctd;
//import 'package:teamfuse/components/login/forgot.template.dart' as fct;
//import 'package:teamfuse/components/login/needauth-component.template.dart'
//    as nactd;
//import 'package:teamfuse/components/login/signup.template.dart' as sct;
//import 'package:teamfuse/components/login/verify.template.dart' as vct;
import 'package:teamfuse/components/promo/promo-component.template.dart' as pct;

import 'notfound-component.template.dart' as nfct;
import 'route_paths.dart' as paths;

@Injectable()
class Routes {
  /*
  static final _authed = new RouteDefinition(
    routePath: paths.authed,
    component: actd.AuthedComponentNgFactory as ComponentFactory,
  );

   */
  static final _guest = new RouteDefinition(
    routePath: paths.guest,
    component: gctd.GuestComponentNgFactory as ComponentFactory,
  );
  static final _promo = new RouteDefinition(
    routePath: paths.promo,
    component: pct.PromoComponentNgFactory as ComponentFactory,
    useAsDefault: true,
  );

  /*
  static final _login = new RouteDefinition(
    routePath: paths.login,
    component: nactd.NeedAuthComponentNgFactory as ComponentFactory,
  );

  static final _signup = new RouteDefinition(
    routePath: paths.signup,
    component: sct.SignupComponentNgFactory as ComponentFactory,
  );

  static final _verify = new RouteDefinition(
    routePath: paths.verify,
    component: vct.VerifyComponentNgFactory as ComponentFactory,
  );

  static final _forgot = new RouteDefinition(
    routePath: paths.forgot,
    component: fct.ForgotComponentNgFactory as ComponentFactory,
  );

   */

  final List<RouteDefinition> all = [
    //_authed,
    // _login,
    _guest,
    _promo,
    // _signup,
    //  _verify,
    //  _forgot,
    new RouteDefinition.redirect(path: '', redirectTo: 'promo/guesthome'),
    new RouteDefinition(
      path: '.*',
      component: nfct.NotFoundComponentNgFactory as ComponentFactory,
    ),
  ];
}
