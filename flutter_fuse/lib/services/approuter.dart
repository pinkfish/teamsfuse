import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_fuse/screens/clubs/addclub.dart';
import 'package:flutter_fuse/screens/clubs/addmember.dart';
import 'package:flutter_fuse/screens/clubs/clubdetails.dart';
import 'package:flutter_fuse/screens/clubs/editclub.dart';
import 'package:flutter_fuse/screens/game/addevent.dart';
import 'package:flutter_fuse/screens/game/addgame.dart';
import 'package:flutter_fuse/screens/game/addtraining.dart';
import 'package:flutter_fuse/screens/game/editgame.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';
import 'package:flutter_fuse/screens/game/sharedgamedetails.dart';
import 'package:flutter_fuse/screens/invites/acceptinviteasadmin.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoclub.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoleague.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoleagueteam.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoplayer.dart';
import 'package:flutter_fuse/screens/invites/acceptinvitetoteam.dart';
import 'package:flutter_fuse/screens/invites/addinvitetoplayer.dart';
import 'package:flutter_fuse/screens/invites/invitelist.dart';
import 'package:flutter_fuse/screens/league/addleague.dart';
import 'package:flutter_fuse/screens/league/editleague.dart';
import 'package:flutter_fuse/screens/league/home.dart';
import 'package:flutter_fuse/screens/league/league.dart';
import 'package:flutter_fuse/screens/league/leaguedivison.dart';
import 'package:flutter_fuse/screens/league/leagueteam.dart';
import 'package:flutter_fuse/screens/login/forgotpassword.dart';
import 'package:flutter_fuse/screens/login/loginform.dart';
import 'package:flutter_fuse/screens/login/signup.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_fuse/screens/login/verifyemail.dart';
import 'package:flutter_fuse/screens/message/addmessage.dart';
import 'package:flutter_fuse/screens/message/messages.dart';
import 'package:flutter_fuse/screens/message/messageview.dart';
import 'package:flutter_fuse/screens/settings/about.dart';
import 'package:flutter_fuse/screens/settings/editplayer.dart';
import 'package:flutter_fuse/screens/settings/editprofile.dart';
import 'package:flutter_fuse/screens/settings/profile.dart';
import 'package:flutter_fuse/screens/settings/settings.dart';
import 'package:flutter_fuse/screens/team/addadmin.dart';
import 'package:flutter_fuse/screens/team/addplayer.dart';
import 'package:flutter_fuse/screens/team/addseason.dart';
import 'package:flutter_fuse/screens/team/addteam.dart';
import 'package:flutter_fuse/screens/team/clubsettings.dart';
import 'package:flutter_fuse/screens/team/editteam.dart';
import 'package:flutter_fuse/screens/team/playerdetails.dart';
import 'package:flutter_fuse/screens/team/team.dart';
import 'package:flutter_fuse/screens/team/teamhome.dart';
import 'package:flutter_fuse/screens/team/teamsettings.dart';
import 'package:fusemodel/fusemodel.dart';

import 'analytics.dart';

class AppRouter {
  static fluro.Router createAppRouter() {
    fluro.Router router = fluro.Router();
    router.define("/Home",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SplashScreen()));
    router.define("/Profile",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                ProfileScreen(
                  onlyPlayer: false,
                )));
    router.define("/Players",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                ProfileScreen(
                  onlyPlayer: true,
                )));
    router.define("/EditProfile/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditProfileScreen(vals["id"][0].toString())));
    router.define("/EditPlayer/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditPlayerScreen(playerUid: vals["id"][0].toString())));
    router.define("/Settings",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SettingsScreen()));
    router.define("/About",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AboutScreen()));
    router.define("/Invites",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                InviteListScreen()));
    router.define("/AcceptInviteToTeam/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToTeamScreen(vals["id"][0].toString())));
    router.define("/AddInviteToPlayer/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddInviteToPlayerScreen(vals["id"][0].toString())));
    router.define("/AcceptInviteToPlayer/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToPlayerScreen(vals["id"][0].toString())));
    router.define("/AcceptInviteAsAdmin/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteAsAdminScreen(vals["id"][0].toString())));
    router.define("/AcceptInviteToClub/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToClubScreen(vals["id"][0].toString())));
    router.define("/AcceptInviteToClub/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToClubScreen(vals["id"][0].toString())));
    router.define("/AcceptInviteToLeague/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToLeagueScreen(vals["id"][0].toString())));
    router.define("/AcceptInviteToLeagueTeam/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AcceptInviteToLeagueTeamScreen(vals["id"][0].toString())));
    router.define("/Team/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamScreen(vals["id"][0].toString())));
    router.define("/AddTeam",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddTeamScreen()));
    router.define("/AllTeams",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamHomeScreen()));
    router.define("/EditTeam/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditTeamScreen(vals["id"][0].toString())));
    router.define("/TeamSettings/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                TeamSettingsScreen(vals["id"][0].toString())));
    router.define("/TeamAddAdmin/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddAdminScreen(vals["id"][0].toString())));
    router.define("/TeamClub/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                ClubSettingsScreen(vals["id"][0].toString())));
    router.define("/AddSeason/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddSeasonScreen(vals["id"][0].toString())));
    router.define("/AddPlayer/:team/:season",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddPlayerScreen(
                    vals["team"][0].toString(), vals["season"][0].toString())));
    router.define("/PlayerDetails/:team/:season/:player",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                PlayerDetailsScreen(
                    vals["team"][0].toString(),
                    vals["season"][0].toString(),
                    vals["player"][0].toString())));
    router.define("/EditGame/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditGameScreen(vals["id"][0].toString())));
    router.define("/Game/:id", handler: fluro.Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      Analytics.analytics.logViewItem(
          itemId: vals["id"][0].toString(),
          itemName: "Game",
          itemCategory: "Game");
      return GameDetailsScreen(vals["id"][0].toString());
    }));
    router.define("/SharedGame/:id", handler: fluro.Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      Analytics.analytics.logViewItem(
          itemId: vals["id"][0].toString(),
          itemName: "Game",
          itemCategory: "Game");
      return SharedGameDetailsScreen(vals["id"][0].toString());
    }));

    router.define("/AddEvent",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddEventScreen()));
    router.define("/AddGame",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddGameScreen()));
    router.define("/AddTraining",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddTrainingScreen()));
    router.define("/Messages",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                MessagesScreen()));
    router.define("/AddMessage",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMessageScreen()));
    router.define("/ShowMessage/:id", handler: fluro.Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> vals) {
      Analytics.analytics.logViewItem(
          itemId: vals["id"][0].toString(),
          itemName: "Message",
          itemCategory: "Message");

      return ShowMessageScreen(messageUid: vals["id"][0].toString());
    }));
    router.define("/AddMessageTeam/:team",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMessageScreen(teamUid: vals["team"].toString())));
    router.define("/AddMessagePlayer/:team/:season/:player",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMessageScreen(
                  teamUid: vals["team"][0].toString(),
                  seasonUid: vals["season"][0].toString(),
                  playerUid: vals["player"][0].toString(),
                )));

    router.define("/Club/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                ClubDetailsScreen(vals["id"][0].toString())));
    router.define("/EditClub/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditClubScreen(vals["id"][0].toString())));
    router.define("/AddClubMember/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddMemberScreen(vals["id"][0].toString())));
    router.define("/AddClubTeam/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddTeamScreen(clubUid: vals["id"][0].toString())));
    router.define("/AddClub",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddClubScreen()));

    // League screens.
    router.define('/League/Home',
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                LeagueHomeScreen()));
    router.define('/League/AddLeague',
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddLeagueScreen(LeagueOrTournamentType.League)));
    router.define('/League/AddTournament',
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                AddLeagueScreen(LeagueOrTournamentType.League)));
    router.define("/League/Main/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                LeagueScreen(vals["id"][0].toString())));
    router.define("/League/Edit/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                EditLeagueScreen(vals["id"][0].toString())));
    router.define("/League/Divison/:id/:season/:divison",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                LeagueDivisonScreen(
                  vals["id"][0].toString(),
                  vals["season"][0].toString(),
                  vals["divison"][0].toString(),
                )));
    router.define("/League/Team/:league/:season/:id",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                LeagueTeamScreen(
                  vals["league"][0].toString(),
                  vals["season"][0].toString(),
                  vals["id"][0].toString(),
                )));

    // The login router.
    router.define("/Login/Home",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                LoginScreen()));
    router.define("/Login/Verify",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                VerifyEmailScreen()));
    router.define("/Login/SignUp",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                SignupScreen()));
    router.define("/Login/ForgotPassword",
        handler: fluro.Handler(
            handlerFunc: (BuildContext context, Map<String, dynamic> vals) =>
                ForgotPasswordScreen()));
    return router;
  }
}
