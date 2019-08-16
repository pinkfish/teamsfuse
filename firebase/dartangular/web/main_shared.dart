import 'dart:async';

import 'package:angular/angular.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import "package:intl/intl_browser.dart";
import 'package:teamfuse/services/sqldata.dart';
import 'package:teamfuse/services/webanalytics.dart';
import 'package:teamfuse/services/weblogging.dart';
import 'package:teamfuse/util/firestore/firestore.dart' as fs;
import 'package:timezone/browser.dart';

void mainShared(InjectorFactory injector) async {
  fb.initializeApp(
      apiKey: "AIzaSyBN6v7M6jy39smjF9Lt819FcsWRm2cu9K0",
      authDomain: "teamsfuse.firebaseapp.com",
      databaseURL: "https://teamsfuse.firebaseio.com",
      projectId: "teamsfuse",
      storageBucket: "teamsfuse.appspot.com",
      messagingSenderId: "400199897683");
  var firestore = fs.Firestore();
  var logging = WebLogging();
  var analytics = WebAnalytics();
  var persistentData = SqlData.instance;
  await findSystemLocale();
  await initializeTimeZone();
  print('Startup checking user');
  UserAuthImpl userAuthImpl = UserAuthImpl(firestore, persistentData);
  var authenticationBloc = AuthenticationBloc(userAuth: userAuthImpl);
  var loginBloc = new LoginBloc(userAuth: userAuthImpl);
  DatabaseUpdateModel databaseUpdateModel =
      DatabaseUpdateModelImpl(firestore, SqlData.instance);
  var coordinationBloc = CoordinationBloc(
      persistentData: persistentData,
      authenticationBloc: authenticationBloc,
      analytics: analytics,
      databaseUpdateModel: databaseUpdateModel,
      analyticsSubsystem: analytics);
  var playerBloc = new PlayerBloc(coordinationBloc: coordinationBloc);
  var inviteBloc = new InviteBloc(
      coordinationBloc: coordinationBloc,
      persistentData: persistentData,
      analyticsSubsystem: analytics,
      databaseUpdateModel: databaseUpdateModel);
  var teamBloc =
      new TeamBloc(coordinationBloc: coordinationBloc, playerBloc: playerBloc);
  var messagesBloc =
      MessagesBloc(coordinationBloc: coordinationBloc, teamBloc: teamBloc);
  var clubBloc =
      ClubBloc(coordinationBloc: coordinationBloc, teamBloc: teamBloc);
  var leagueOrTournamentBloc =
      LeagueOrTournamentBloc(coordinationBloc: coordinationBloc);
  var gameBloc =
      GameBloc(coordinationBloc: coordinationBloc, teamBloc: teamBloc);
  var filteredGameBloc =
      FilteredGameBloc(gameBloc: gameBloc, teamBloc: teamBloc);
  var loadedStateBloc = LoadedStateBloc(coordinationBloc: coordinationBloc);

  authenticationBloc.dispatch(AuthenticationAppStarted());
  Completer<UserData> data = new Completer();

  await data.future;

  runApp(fluff.AppComponentNgFactory as ComponentFactory,
      createInjector: injector);
}
