// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart' as paths;
import 'package:teamfuse/components/games/games-component.template.dart' as gctd;
import 'package:teamfuse/components/team/deletegamesfromteam.template.dart' as dgfttd;
import 'package:teamfuse/components/team/team.template.dart' as gcttd;
import 'package:teamfuse/components/games/single/game-component.template.dart' as sgtd;


@Injectable()
class Routes {
  static final _games = new RouteDefinition(
    routePath: paths.games,
    component: gctd.GamesComponentNgFactory,
    useAsDefault: true
  );
  static final _deleteGamesFromTeam = new RouteDefinition(
      routePath: paths.deletegamesfromteam,
      component: dgfttd.DeleteGamesFromTeamComponentNgFactory,
  );
  static final _teams = new RouteDefinition(
    routePath: paths.teams,
    component: gcttd.TeamComponentNgFactory,
  );

  static final _gameDisplay = new RouteDefinition(
    routePath: paths.gameDisplay,
    component: sgtd.SingleGameComponentNgFactory,
  );

  RouteDefinition get games => _games;
  RouteDefinition get deleteGamesFromTeam => _deleteGamesFromTeam;

  final List<RouteDefinition> all = [
    _games,
    _deleteGamesFromTeam,
    _teams,
    _gameDisplay
  ];
}