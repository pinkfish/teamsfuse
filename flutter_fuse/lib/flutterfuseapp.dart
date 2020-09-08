import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/approuter.dart';
import 'package:flutter_fuse/services/firestore/firestore.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

import 'fusematerialapp.dart';

class FlutterFuseApp extends StatefulWidget {
  final FirestoreWrapper firestore;

  FlutterFuseApp(this.firestore);

  @override
  State<StatefulWidget> createState() {
    return _FuseFuseAppState();
  }
}

class _FuseFuseAppState extends State<FlutterFuseApp> {
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
  SeasonBloc _seasonBloc;

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

  Widget _materialApp(BuildContext context) {
    // Subscribe to auth changes.
    //UserDatabaseData.instance.userAuth.onAuthChanged().listen(_authChanged);
    // Start loading stuff.
    //_authChanged(data);
    // Setup the app and do exciting things.
    return FuseMaterialApp(theme);
  }

  @override
  void initState() {
    super.initState();
    UserAuthImpl userAuthImpl = UserAuthImpl(widget.firestore);
    _authenticationBloc = AuthenticationBloc(
        userAuth: userAuthImpl, analyticsSubsystem: Analytics.instance);
    _loginBloc = new LoginBloc(
        userAuth: userAuthImpl, analyticsSubsystem: Analytics.instance);
    DatabaseUpdateModel databaseUpdateModel =
        DatabaseUpdateModelImpl(new Firestore());
    _coordinationBloc = CoordinationBloc(
        authenticationBloc: _authenticationBloc,
        analytics: Analytics.instance,
        databaseUpdateModel: databaseUpdateModel,
        analyticsSubsystem: Analytics.instance);
    _playerBloc = new PlayerBloc(coordinationBloc: _coordinationBloc);
    _inviteBloc = new InviteBloc(
        coordinationBloc: _coordinationBloc,
        analyticsSubsystem: Analytics.instance,
        databaseUpdateModel: databaseUpdateModel);
    _messagesBloc =
        MessagesBloc(coordinationBloc: _coordinationBloc, teamBloc: _teamBloc);
    _clubBloc = ClubBloc(coordinationBloc: _coordinationBloc);
    _teamBloc =
        new TeamBloc(coordinationBloc: _coordinationBloc, clubBloc: _clubBloc);
    _seasonBloc = new SeasonBloc(coordinationBloc: _coordinationBloc);
    _leagueOrTournamentBloc =
        LeagueOrTournamentBloc(coordinationBloc: _coordinationBloc);
    _gameBloc =
        GameBloc(coordinationBloc: _coordinationBloc, teamBloc: _teamBloc);
    _filteredGameBloc = FilteredGameBloc(
        gameBloc: _gameBloc, teamBloc: _teamBloc, seasonBloc: _seasonBloc);
    _loadedStateBloc = LoadedStateBloc(coordinationBloc: _coordinationBloc);

    _authenticationBloc.add(AuthenticationAppStarted());
  }

  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<fluro.Router>(
          create: (BuildContext context) => AppRouter.createAppRouter(),
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AuthenticationBloc>(
            create: (BuildContext context) => _authenticationBloc,
          ),
          BlocProvider<CoordinationBloc>(
              create: (BuildContext context) => _coordinationBloc),
          BlocProvider<LoginBloc>(create: (BuildContext context) => _loginBloc),
          BlocProvider<InviteBloc>(
              create: (BuildContext context) => _inviteBloc),
          BlocProvider<TeamBloc>(create: (BuildContext context) => _teamBloc),
          BlocProvider<SeasonBloc>(
              create: (BuildContext context) => _seasonBloc),
          BlocProvider<MessagesBloc>(
              create: (BuildContext context) => _messagesBloc),
          BlocProvider<LeagueOrTournamentBloc>(
              create: (BuildContext context) => _leagueOrTournamentBloc),
          BlocProvider<ClubBloc>(create: (BuildContext context) => _clubBloc),
          BlocProvider<GameBloc>(create: (BuildContext context) => _gameBloc),
          BlocProvider<FilteredGameBloc>(
              create: (BuildContext context) => _filteredGameBloc),
          BlocProvider<PlayerBloc>(
              create: (BuildContext context) => _playerBloc),
          BlocProvider<LoadedStateBloc>(
              create: (BuildContext context) => _loadedStateBloc),
        ],
        child: _materialApp(context),
      ),
    );
  }

  @override
  void dispose() {
    _loadedStateBloc.close();
    _playerBloc.close();
    _filteredGameBloc.close();
    _gameBloc.close();
    _clubBloc.close();
    _leagueOrTournamentBloc.close();
    _messagesBloc.close();
    _teamBloc.close();
    _seasonBloc.close();
    _inviteBloc.close();
    _loginBloc.close();
    _coordinationBloc.close();
    _authenticationBloc.close();
  }

  //UserData _currentUser;
}
