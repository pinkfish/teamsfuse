// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'route_paths.dart' as paths;
import 'package:teamfuse/components/games/games-component.template.dart'
    as gctd;
import 'package:teamfuse/components/team/deletegamesfromteam.template.dart'
    as dgfttd;
import 'package:teamfuse/components/team/team.template.dart' as gcttd;
import 'package:teamfuse/components/games/single/game-component.template.dart'
    as sgtd;
import 'package:teamfuse/components/games/single/shared-game-component.template.dart'
    as ssgtd;
import 'package:teamfuse/components/club/club.template.dart' as ccttd;
import 'package:teamfuse/components/leagueortournament/home.template.dart'
    as lotht;
import 'package:teamfuse/components/leagueortournament/league.template.dart'
    as lotlt;

@Injectable()
class Routes {
  static final _games = new RouteDefinition(
      routePath: paths.games,
      component: gctd.GamesComponentNgFactory,
      useAsDefault: true);
  static final _deleteGamesFromTeam = new RouteDefinition(
    routePath: paths.deletegamesfromteam,
    component: dgfttd.DeleteGamesFromTeamComponentNgFactory,
  );
  static final _team = new RouteDefinition(
    routePath: paths.team,
    component: gcttd.TeamComponentNgFactory,
  );
  static final _club = new RouteDefinition(
    routePath: paths.club,
    component: ccttd.ClubComponentNgFactory,
  );

  static final _gameDisplay = new RouteDefinition(
    routePath: paths.gameDisplay,
    component: sgtd.SingleGameComponentNgFactory,
  );

  static final _gameSharedDisplay = new RouteDefinition(
    routePath: paths.gameSharedDisplay,
    component: ssgtd.SharedSingleGameComponentNgFactory,
  );

  static final _leagueHome = new RouteDefinition(
    routePath: paths.league,
    component: lotht.HomeComponentNgFactory,
  );

  static final _leagueDetails = new RouteDefinition(
      routePath: paths.leagueDetails,
      component: lotlt.LeagueComponentNgFactory);

  RouteDefinition get games => _games;
  RouteDefinition get deleteGamesFromTeam => _deleteGamesFromTeam;

  final List<RouteDefinition> all = [
    _games,
    _deleteGamesFromTeam,
    _team,
    _gameDisplay,
    _club,
    _leagueHome,
    _leagueDetails,
    _gameSharedDisplay
  ];
}
