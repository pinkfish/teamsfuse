// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart' as paths;

import 'promo/promo-component.template.dart' as pctl;
import 'package:teamfuse/components/leagueortournament/guest/league.template.dart'
    as lotlt;

@Injectable()
class Routes {

  static final _leagueDetails = new RouteDefinition(
      routePath: paths.leagueDetails,
      component: lotlt.LeagueComponentNgFactory);

  static final _promo = new RouteDefinition(
    routePath: paths.promo,
    component: pctl.PromoComponentNgFactory,
    useAsDefault: true,
  );

  final List<RouteDefinition> all = [
    _promo,
    _leagueDetails,
  ];
}
