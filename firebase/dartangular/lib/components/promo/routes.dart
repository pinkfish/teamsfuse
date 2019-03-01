// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:teamfuse/components/promo/route_paths.dart' as paths;

import 'home/home.template.dart' as hcgl;
import 'league/league.template.dart' as lcgl;
import 'tournaments/tournaments.template.dart' as tcgl;

@Injectable()
class Routes {
  static final _guestHome = new RouteDefinition(
      routePath: paths.home,
      component: hcgl.HomeComponentNgFactory as ComponentFactory,
      useAsDefault: true);
  static final _league = new RouteDefinition(
      routePath: paths.league,
      component: lcgl.LeagueComponentNgFactory as ComponentFactory,
      useAsDefault: false);
  static final _tournaments = new RouteDefinition(
      routePath: paths.tournaments,
      component: tcgl.TournamentsComponentNgFactory as ComponentFactory,
      useAsDefault: false);

  RouteDefinition get guestHome => _guestHome;

  final List<RouteDefinition> all = [
    _guestHome,
    _league,
    _tournaments,
  ];
}
