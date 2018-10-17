import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';

import 'package:teamfuse/components/leagueortournament/guest/league.template.dart'
    as lotlt;
import 'package:teamfuse/components/leagueortournament/guest/leagueteam.template.dart'
    as lttlt;
import 'package:teamfuse/components/guest/team/teamdetails.template.dart'
    as tdtd;
import 'notfound-component.template.dart' as nfct;

@Injectable()
class GuestRoutes {
  static final _leagueDetails = new RouteDefinition(
      routePath: leagueDetails, component: lotlt.LeagueComponentNgFactory);

  static final _leagueTeam = new RouteDefinition(
      routePath: leagueTeam, component: lttlt.LeagueTeamComponentNgFactory);

  static final _teamDetails = new RouteDefinition(
      routePath: team, component: tdtd.TeamDetailsComponentNgFactory);

  final List<RouteDefinition> all = [
    _leagueDetails,
    _leagueTeam,
    _teamDetails,
    new RouteDefinition(
      path: '.*',
      component: nfct.GuestNotFoundComponentNgFactory,
    ),
  ];
}
