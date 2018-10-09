import 'package:angular_router/angular_router.dart';

final games = new RoutePath(path: 'games');
final gameDisplay = new RoutePath(path: 'game/:id');
final gameSharedDisplay = new RoutePath(path: 'gameshared/:id');
final deletegamesfromteam = new RoutePath(path: 'deletegamesfromteam');
final team = new RoutePath(path: 'team/:id');
final club = new RoutePath(path: 'club/:id');
final leagueDetails = new RoutePath(path: 'league/detail/:id');
final leagueDetailsDivison = new RoutePath(path: 'league/detaildiv/:id');
final league = new RoutePath(path: 'league/home');
