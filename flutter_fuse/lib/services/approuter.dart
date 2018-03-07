import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/screens/settings/about.dart';
import 'package:flutter_fuse/screens/settings/settings.dart';
import 'package:flutter_fuse/screens/team/team.dart';
import 'package:flutter_fuse/screens/game/addgame.dart';
import 'package:flutter_fuse/screens/game/editgame.dart';
import 'package:flutter_fuse/screens/team/editteam.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';

class AppRouter {
  static Router myRouter = null;

  static Router get instance {
    if (myRouter == null) {
      myRouter = _setupRoutes();
    }
    return myRouter;
  }

  static Router _setupRoutes() {
    Router router = new Router();
    router.define("/Home",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new HomeScreen()));
    router.define("/Settings",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new SettingsScreen()));
    router.define("/About",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AboutScreen()));
    router.define("/Team/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new TeamScreen(vals["id"])));
    router.define("/EditTeam/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new EditTeamScreen(vals["id"])));
    router.define("/EditGame/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new EditGameScreen(vals["id"])));
    router.define("/Game/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new GameDetailsScreen(vals["id"])));
    router.define("/AddGame",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddGameScreen()));
    return router;
  }
}
