import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/services/firestore/firestore.dart';
import 'package:flutter_fuse/services/loggingdata.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

class Routes {
  Routes(FirestoreWrapper firestore, PersistenData persistentData) {
    // Subscribe to auth changes.
    //UserDatabaseData.instance.userAuth.onAuthChanged().listen(_authChanged);
    // Start loading stuff.
    //_authChanged(data);
    // Setup the app and do exciting things.
    app = new MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        const MessagesDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const <Locale>[
        const Locale('en', 'US'),
        const Locale('en', 'UK'),
        const Locale('en', 'AU'),
      ],
      navigatorObservers: <NavigatorObserver>[
        new FirebaseAnalyticsObserver(analytics: Analytics.analytics),
      ],
      title: "Team Fuse",
      theme: theme,
      initialRoute: "Home",
      home: new SplashScreen(),
      onGenerateRoute: _buildRoute,
    );
    UserAuthImpl userAuthImpl = UserAuthImpl(firestore, persistentData);
    _authenticationBloc = AuthenticationBloc(userAuth: userAuthImpl);
    _loginBloc = new LoginBloc(userAuth: userAuthImpl);
    DatabaseUpdateModel databaseUpdateModel =
        DatabaseUpdateModelImpl(new Firestore(), SqlData.instance);
    _coordinationBloc = CoordinationBloc(
        persistentData: persistentData,
        authenticationBloc: _authenticationBloc,
        analytics: Analytics.instance,
        databaseUpdateModel: databaseUpdateModel,
        analyticsSubsystem: Analytics.instance);
    _playerBloc = new PlayerBloc(coordinationBloc: _coordinationBloc);
    _inviteBloc = new InviteBloc(
        coordinationBloc: _coordinationBloc,
        persistentData: persistentData,
        analyticsSubsystem: Analytics.instance,
        databaseUpdateModel: databaseUpdateModel);
    _teamBloc = new TeamBloc(
        coordinationBloc: _coordinationBloc, playerBloc: _playerBloc);
    _messagesBloc =
        MessagesBloc(coordinationBloc: _coordinationBloc, teamBloc: _teamBloc);
    _clubBloc =
        ClubBloc(coordinationBloc: _coordinationBloc, teamBloc: _teamBloc);
    _leagueOrTournamentBloc =
        LeagueOrTournamentBloc(coordinationBloc: _coordinationBloc);
    _gameBloc =
        GameBloc(coordinationBloc: _coordinationBloc, teamBloc: _teamBloc);
    _filteredGameBloc =
        FilteredGameBloc(gameBloc: _gameBloc, teamBloc: _teamBloc);
    _loadedStateBloc = LoadedStateBloc(coordinationBloc: _coordinationBloc);

    _authenticationBloc.dispatch(AuthenticationAppStarted());
    runApp(MultiBlocProvider(providers: [
      BlocProvider<AuthenticationBloc>(
          builder: (BuildContext context) => _authenticationBloc),
      BlocProvider<CoordinationBloc>(
          builder: (BuildContext context) => _coordinationBloc),
      BlocProvider<LoginBloc>(builder: (BuildContext context) => _loginBloc),
      BlocProvider<InviteBloc>(builder: (BuildContext context) => _inviteBloc),
      BlocProvider<TeamBloc>(builder: (BuildContext context) => _teamBloc),
      BlocProvider<MessagesBloc>(
          builder: (BuildContext context) => _messagesBloc),
      BlocProvider<LeagueOrTournamentBloc>(
          builder: (BuildContext context) => _leagueOrTournamentBloc),
      BlocProvider<ClubBloc>(builder: (BuildContext context) => _clubBloc),
      BlocProvider<GameBloc>(builder: (BuildContext context) => _gameBloc),
      BlocProvider<FilteredGameBloc>(
          builder: (BuildContext context) => _filteredGameBloc),
      BlocProvider<PlayerBloc>(builder: (BuildContext context) => _playerBloc),
      BlocProvider<LoadedStateBloc>(
          builder: (BuildContext context) => _loadedStateBloc),
    ], child: app));
  }

  //UserData _currentUser;
  AuthenticationBloc _authenticationBloc;
  LoginBloc _loginBloc;
  InviteBloc _inviteBloc;
  GameBloc _gameBloc;
  FilteredGameBloc _filteredGameBloc;
  PlayerBloc _playerBloc;
  TeamBloc _teamBloc;
  ClubBloc _clubBloc;
  LeagueOrTournamentBloc _leagueOrTournamentBloc;
  MessagesBloc _messagesBloc;
  CoordinationBloc _coordinationBloc;
  LoadedStateBloc _loadedStateBloc;

  final ThemeData theme = new ThemeData(
    // This is the theme of your application.
    //
    // Try running your application with "flutter run". You'll see the
    // application has a blue toolbar. Then, without quitting the app, try
    // changing the primarySwatch below to Colors.green and then invoke
    // "hot reload" (press "r" in the console where you ran "flutter run",
    // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
    // counter didn't reset back to zero; the application is not restarted.
    primarySwatch: Colors.green,
  );

  MaterialApp app;

  Route<dynamic> _buildRoute(RouteSettings routeSettings) {
    //Analytics.analytics.setCurrentScreen(screenName: routeSettings.name);
    LoggingData.instance.lastPath = routeSettings.name;
    return AppRouter.instance.generator(routeSettings);
  }
/*
  void _authChanged(UserData user) async {
    _currentUser = user;
    if (user != null) {
      UserDatabaseData.load(user.uid, user.email,
          UserDatabaseData.instance.userAuth.getProfile(user.uid));

    } else {
      UserDatabaseData.clear();
    }
  }
  */
}
