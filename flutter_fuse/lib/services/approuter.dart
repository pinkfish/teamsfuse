import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter_fuse/screens/team/addmedia.dart';
import 'package:flutter_fuse/screens/team/editseasonplayer.dart';
import 'package:flutter_fuse/screens/team/teammedia.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:timezone/timezone.dart';

import '../screens/clubs/addclub.dart';
import '../screens/clubs/addcoach.dart';
import '../screens/clubs/addmember.dart';
import '../screens/clubs/addnewsitem.dart';
import '../screens/clubs/clubdetails.dart';
import '../screens/clubs/editclub.dart';
import '../screens/clubs/editcoach.dart';
import '../screens/clubs/editnewsitem.dart';
import '../screens/game/addevent.dart';
import '../screens/game/addgame.dart';
import '../screens/team/addmedia.dart';
import '../screens/game/addtraining.dart';
import '../screens/game/editgame.dart';
import '../screens/game/gamedetails.dart';
import '../screens/game/gamestats.dart';
import '../screens/game/sharedgamedetails.dart';
import '../screens/home/home.dart';
import '../screens/invites/acceptinviteasadmin.dart';
import '../screens/invites/acceptinvitetoclub.dart';
import '../screens/invites/acceptinvitetoleague.dart';
import '../screens/invites/acceptinvitetoleagueteam.dart';
import '../screens/invites/acceptinvitetoplayer.dart';
import '../screens/invites/addinvitetoplayer.dart';
import '../screens/invites/invitelist.dart';
import '../screens/league/addleague.dart';
import '../screens/league/editleague.dart';
import '../screens/league/home.dart';
import '../screens/league/league.dart';
import '../screens/league/leaguedivison.dart';
import '../screens/league/leagueteam.dart';
import '../screens/login/forgotpassword.dart';
import '../screens/login/loginform.dart';
import '../screens/login/signup.dart';
import '../screens/login/splashscreen.dart';
import '../screens/login/verifyemail.dart';
import '../screens/message/addmessage.dart';
import '../screens/message/messages.dart';
import '../screens/message/messageview.dart';
import '../screens/settings/about.dart';
import '../screens/settings/editprofile.dart';
import '../screens/settings/profile.dart';
import '../screens/settings/settings.dart';
import '../screens/team/addadmin.dart';
import '../screens/team/addplayer.dart';
import '../screens/team/addseason.dart';
import '../screens/team/addteam.dart';
import '../screens/team/clubsettings.dart';
import '../screens/team/editplayer.dart';
import '../screens/team/editseason.dart';
import '../screens/team/editteam.dart';
import '../screens/team/playerdetails.dart';
import '../screens/team/seasondetails.dart';
import '../screens/team/team.dart';
import '../screens/team/teamhome.dart';
import '../screens/team/teamsettings.dart';
import 'analytics.dart';

///
/// The main router for the app.  Has all the details for routing and routes
/// for all the parts of the app.
///
class AppRouter {
  ///
  /// Creates the app router to use for the app.  Sets up all the routes
  /// and does stuff.
  ///
  static fluro.FluroRouter createAppRouter(Location location) {
    var router = fluro.FluroRouter();
    router.define('/Home',
        handler:
            fluro.Handler(handlerFunc: (context, values) => SplashScreen()));
    router.define('/Main/Home',
        handler: fluro.Handler(
            handlerFunc: (context, values) => HomeScreen(location)));
    router.define('/Profile',
        handler: fluro.Handler(
            handlerFunc: (context, values) => ProfileScreen(
                  onlyPlayer: false,
                )));
    router.define('/Players',
        handler: fluro.Handler(
            handlerFunc: (context, values) => ProfileScreen(
                  onlyPlayer: true,
                )));
    router.define('/EditProfile/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                EditProfileScreen(values['id'][0].toString())));
    router.define('/EditPlayer/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                EditPlayerScreen(playerUid: values['id'][0].toString())));
    router.define('/Settings',
        handler:
            fluro.Handler(handlerFunc: (context, values) => SettingsScreen()));
    router.define('/About',
        handler:
            fluro.Handler(handlerFunc: (context, values) => AboutScreen()));
    router.define('/Invites',
        handler: fluro.Handler(
            handlerFunc: (context, values) => InviteListScreen()));
    router.define('/AddInviteToPlayer/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddInviteToPlayerScreen(values['id'][0].toString())));
    router.define('/AcceptInviteToPlayer/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AcceptInviteToPlayerScreen(values['id'][0].toString())));
    router.define('/AcceptInviteAsAdmin/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AcceptInviteAsAdminScreen(values['id'][0].toString())));
    router.define('/AcceptInviteToClub/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AcceptInviteToClubScreen(values['id'][0].toString())));
    router.define('/AcceptInviteToClub/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AcceptInviteToClubScreen(values['id'][0].toString())));
    router.define('/AcceptInviteToLeague/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AcceptInviteToLeagueScreen(values['id'][0].toString())));
    router.define('/AcceptInviteToLeagueTeam/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AcceptInviteToLeagueTeamScreen(values['id'][0].toString())));
    router.define('/Team/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                TeamScreen(values['id'][0].toString())));
    router.define('/Team/Media/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                TeamMediaScreen(values['id'][0].toString())));

    router.define('/AddTeam',
        handler:
            fluro.Handler(handlerFunc: (context, values) => AddTeamScreen()));
    router.define('/AllTeams',
        handler:
            fluro.Handler(handlerFunc: (context, values) => TeamHomeScreen()));
    router.define(
      '/EditTeam/:id',
      handler: fluro.Handler(
          handlerFunc: (context, values) =>
              EditTeamScreen(values['id'][0].toString())),
    );
    router.define(
      '/TeamSettings/:id',
      handler: fluro.Handler(
          handlerFunc: (context, values) =>
              TeamSettingsScreen(values['id'][0].toString())),
    );
    router.define(
      '/TeamAddAdmin/:id',
      handler: fluro.Handler(
          handlerFunc: (context, values) =>
              AddAdminScreen(values['id'][0].toString())),
    );
    router.define(
      '/TeamClub/:id',
      handler: fluro.Handler(
          handlerFunc: (context, values) =>
              ClubSettingsScreen(values['id'][0].toString())),
    );
    router.define(
      '/Team/Media/:teamId/:seasonId',
      handler: fluro.Handler(
        handlerFunc: (context, values) => AddMediaScreen(
            values['teamId'][0].toString(), values['seasonId'][0].toString()),
      ),
    );
    router.define(
      '/AddSeason/:id',
      handler: fluro.Handler(
          handlerFunc: (context, values) =>
              AddSeasonScreen(values['id'][0].toString())),
    );
    router.define(
      '/Season/Edit/:id',
      handler: fluro.Handler(
          handlerFunc: (context, values) =>
              EditSeasonScreen(values['id'][0].toString())),
    );
    router.define('/Season/View/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                SeasonDetailsScreen(seasonUid: values['id'][0].toString())));
    router.define('/AddPlayer/:team/:season',
        handler: fluro.Handler(
            handlerFunc: (context, values) => AddPlayerScreen(
                values['team'][0].toString(), values['season'][0].toString())));
    router.define('/PlayerDetails/:team/:season/:player',
        handler: fluro.Handler(
            handlerFunc: (context, values) => PlayerDetailsScreen(
                values['team'][0].toString(),
                values['season'][0].toString(),
                values['player'][0].toString())));
    router.define('/Season/Player/:season/:player',
        handler: fluro.Handler(
            handlerFunc: (context, values) => EditSeasonPlayerScreen(
                seasonUid: values['season'][0].toString(),
                playerUid: values['player'][0].toString())));

    router.define('/EditGame/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                EditGameScreen(values['id'][0].toString())));
    router.define('/Game/:id',
        handler: fluro.Handler(handlerFunc: (context, values) {
      AnalyticsSubsystemImpl.analytics.logViewItem(
          itemId: values['id'][0].toString(),
          itemName: 'Game',
          itemCategory: 'Game');
      return GameDetailsScreen(values['id'][0].toString());
    }));
    router.define(
      '/GameStats/:id/:seasonId/:teamId',
      handler: fluro.Handler(
          handlerFunc: (context, values) => GameStatsScreen(
                values['id'][0].toString(),
                values['seasonId'][0].toString(),
                values['teamId'][0].toString(),
              )),
    );
    router.define('/SharedGame/:id',
        handler: fluro.Handler(handlerFunc: (context, values) {
      AnalyticsSubsystemImpl.analytics.logViewItem(
          itemId: values['id'][0].toString(),
          itemName: 'Game',
          itemCategory: 'Game');
      return SharedGameDetailsScreen(values['id'][0].toString());
    }));

    router.define('/AddEvent',
        handler:
            fluro.Handler(handlerFunc: (context, values) => AddEventScreen()));
    router.define('/AddGame',
        handler: fluro.Handler(
            handlerFunc: (context, values) => AddGameScreen(null, null)));
    router.define('/Game/Add/:teamId/:seasonId',
        handler: fluro.Handler(
            handlerFunc: (context, values) => AddGameScreen(
                values['teamId'][0].toString(),
                values['seasonId'][0].toString())));
    router.define('/AddTraining',
        handler: fluro.Handler(
            handlerFunc: (context, values) => AddTrainingScreen()));
    router.define('/Messages',
        handler:
            fluro.Handler(handlerFunc: (context, values) => MessagesScreen()));
    router.define('/AddMessage',
        handler: fluro.Handler(
            handlerFunc: (context, values) => AddMessageScreen()));
    router.define('/ShowMessage/:id',
        handler: fluro.Handler(handlerFunc: (context, values) {
      AnalyticsSubsystemImpl.analytics.logViewItem(
          itemId: values['id'][0].toString(),
          itemName: 'Message',
          itemCategory: 'Message');

      return ShowMessageScreen(messageUid: values['id'][0].toString());
    }));
    router.define('/AddMessageTeam/:team',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddMessageScreen(teamUid: values['team'].toString())));
    router.define('/AddMessagePlayer/:team/:season/:player',
        handler: fluro.Handler(
            handlerFunc: (context, values) => AddMessageScreen(
                  teamUid: values['team'][0].toString(),
                  seasonUid: values['season'][0].toString(),
                  playerUid: values['player'][0].toString(),
                )));

    // Club screens.
    router.define('/Club/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                ClubDetailsScreen(values['id'][0].toString())));
    router.define('/EditClub/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                EditClubScreen(values['id'][0].toString())));
    router.define('/AddClubMember/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddMemberScreen(values['id'][0].toString())));
    router.define('/AddClubTeam/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddTeamScreen(clubUid: values['id'][0].toString())));
    router.define('/AddClub',
        handler:
            fluro.Handler(handlerFunc: (context, values) => AddClubScreen()));
    router.define('/Club/Coach/Add/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddCoachScreen(values['id'][0].toString())));
    router.define('/Club/Coach/Edit/:clubId/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) => EditCoachScreen(
                values['clubId'][0].toString(), values['id'][0].toString())));
    router.define('/Club/News/Add/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddNewsItemScreen(values['id'][0].toString())));
    router.define('/Club/News/Edit/:clubId/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) => EditNewsItemScreen(
                values['clubId'][0].toString(), values['id'][0].toString())));

    // League screens.
    router.define('/League/Home',
        handler: fluro.Handler(
            handlerFunc: (context, values) => LeagueHomeScreen()));
    router.define('/League/AddLeague',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddLeagueScreen(LeagueOrTournamentType.League)));
    router.define('/League/AddTournament',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                AddLeagueScreen(LeagueOrTournamentType.League)));
    router.define('/League/Main/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                LeagueScreen(values['id'][0].toString())));
    router.define('/League/Edit/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) =>
                EditLeagueScreen(values['id'][0].toString())));
    router.define('/League/Divison/:id/:season/:divison',
        handler: fluro.Handler(
            handlerFunc: (context, values) => LeagueDivisonScreen(
                  values['divison'][0].toString(),
                )));
    router.define('/League/Team/:id',
        handler: fluro.Handler(
            handlerFunc: (context, values) => LeagueTeamScreen(
                  values['id'][0].toString(),
                )));

    // The login router.
    router.define('/Login/Home',
        handler:
            fluro.Handler(handlerFunc: (context, values) => LoginScreen()));
    router.define('/Login/Verify',
        handler: fluro.Handler(
            handlerFunc: (context, values) => VerifyEmailScreen()));
    router.define('/Login/SignUp',
        handler:
            fluro.Handler(handlerFunc: (context, values) => SignupScreen()));
    router.define('/Login/ForgotPassword',
        handler: fluro.Handler(
            handlerFunc: (context, values) => ForgotPasswordScreen()));

    return router;
  }
}
