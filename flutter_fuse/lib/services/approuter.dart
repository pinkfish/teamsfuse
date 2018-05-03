import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/screens/settings/about.dart';
import 'package:flutter_fuse/screens/settings/settings.dart';
import 'package:flutter_fuse/screens/settings/profile.dart';
import 'package:flutter_fuse/screens/team/team.dart';
import 'package:flutter_fuse/screens/game/addgame.dart';
import 'package:flutter_fuse/screens/game/addtraining.dart';
import 'package:flutter_fuse/screens/game/editgame.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';
import 'package:flutter_fuse/screens/settings/editprofile.dart';
import 'package:flutter_fuse/screens/team/editteam.dart';
import 'package:flutter_fuse/screens/team/addplayer.dart';
import 'package:flutter_fuse/screens/invites/invitelist.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoteam.dart';
import 'package:flutter_fuse/screens/invites/addinvitetoplayer.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoplayer.dart';
import 'package:flutter_fuse/screens/team/playerdetails.dart';
import 'package:flutter_fuse/screens/settings/editplayer.dart';
import 'package:flutter_fuse/screens/message/messages.dart';
import 'package:flutter_fuse/screens/message/addmessage.dart';
import 'package:flutter_fuse/screens/message/messageview.dart';
import 'package:flutter_fuse/screens/team/addseason.dart';

class AppRouter {
  static Router myRouter;

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
    router.define("/Profile",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new ProfileScreen()));
    router.define("/EditProfile/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new EditProfileScreen(vals["id"][0])));
    router.define("/EditPlayer/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new EditPlayerScreen(playerUid: vals["id"][0])));
    router.define("/Settings",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new SettingsScreen()));
    router.define("/About",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AboutScreen()));
    router.define("/Invites",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new InviteListScreen()));
    router.define("/AcceptInviteToTeam/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AcceptInviteToTeamScreen(vals["id"][0])));
    router.define("/AddInviteToPlayer/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
            new AddInviteToPlayerScreen(vals["id"][0])));
    router.define("/AcceptInviteToPlayer/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
            new AcceptInviteToPlayerScreen(vals["id"][0])));
    router.define("/Team/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new TeamScreen(vals["id"][0])));
    router.define("/AddTeam",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
            new EditTeamScreen(null)));
    router.define("/EditTeam/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new EditTeamScreen(vals["id"][0])));
    router.define("/AddSeason/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
            new AddSeasonScreen(vals["id"][0])));
    router.define("/AddPlayer/:team/:season",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddPlayerScreen(vals["team"][0], vals["season"][0])));
    router.define("/PlayerDetails/:team/:season/:player",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new PlayerDetailsScreen(
                    vals["team"][0], vals["season"][0], vals["player"][0])));
    router.define("/EditGame/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new EditGameScreen(vals["id"][0])));
    router.define("/Game/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new GameDetailsScreen(vals["id"][0])));
    router.define("/AddGame",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddGameScreen()));
    router.define("/AddTraining",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddTrainingScreen()));
    router.define("/Messages",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new MessagesScreen()));
    router.define("/AddMessage",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddMessageScreen()));
    router.define("/ShowMessage/:id",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new ShowMessageScreen(messageUid: vals["id"][0])));
    router.define("/AddMessageTeam/:team",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddMessageScreen(teamUid: vals["team"])));
    router.define("/AddMessagePlayer/:team/:season/:player",
        handler: new Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                new AddMessageScreen(
                  teamUid: vals["team"],
                  seasonUid: vals["season"],
                  playerUid: vals["player"],
                )));
    return router;
  }
}
