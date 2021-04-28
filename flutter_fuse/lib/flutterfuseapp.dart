import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/timezone.dart';

import 'fusematerialapp.dart';
import 'services/analytics.dart';
import 'services/appconfiguration.dart';
import 'services/approuter.dart';
import 'services/blocs.dart';
import 'services/firestore/firestore.dart';
import 'services/loggingdata.dart';
import 'services/notifications.dart';

///
/// The main app for the system.
///
class FlutterFuseApp extends StatefulWidget {
  final FirestoreWrapper _firestore;
  final AppConfiguration _config;
  final LoggingData _loggingData;
  final AnalyticsSubsystemImpl _analytics;

  ///
  /// Create the app.
  ///
  FlutterFuseApp(
      this._firestore, this._config, this._loggingData, this._analytics);

  @override
  State<StatefulWidget> createState() {
    return _FuseFuseAppState();
  }
}

class _FuseFuseAppState extends State<FlutterFuseApp> {
  AuthenticationBloc _authenticationBloc;
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
  DatabaseUpdateModel _databaseUpdateModel;
  UserAuthImpl _userAuthImpl;
  Notifications _notifications;

  final ThemeData _theme = ThemeData(
    primarySwatch: Colors.green,
  );

  Widget _materialApp(BuildContext context) {
    // Setup the app and do exciting things.
    return FuseMaterialApp(_theme);
  }

  @override
  void initState() {
    super.initState();
    _userAuthImpl = UserAuthImpl(widget._firestore);
    _authenticationBloc = AuthenticationBloc(_userAuthImpl, widget._analytics);
    _databaseUpdateModel = DatabaseUpdateModelImpl(
        Firestore(), _authenticationBloc, widget._analytics);
    _coordinationBloc = CoordinationBloc(
      authenticationBloc: _authenticationBloc,
      analytics: widget._analytics,
      databaseUpdateModel: _databaseUpdateModel,
    );
    _playerBloc = PlayerBloc(
      coordinationBloc: _coordinationBloc,
      crashes: widget._analytics,
    );
    _inviteBloc = InviteBloc(
        coordinationBloc: _coordinationBloc,
        crashes: widget._analytics,
        databaseUpdateModel: _databaseUpdateModel);
    _messagesBloc = MessagesBloc(
      coordinationBloc: _coordinationBloc,
      crashes: widget._analytics,
    );
    _clubBloc = ClubBloc(
      coordinationBloc: _coordinationBloc,
      crashes: widget._analytics,
    );
    _teamBloc = TeamBloc(
      coordinationBloc: _coordinationBloc,
      clubBloc: _clubBloc,
      crashes: widget._analytics,
    );
    _seasonBloc = SeasonBloc(
      coordinationBloc: _coordinationBloc,
      crashes: widget._analytics,
    );
    _leagueOrTournamentBloc = LeagueOrTournamentBloc(
      coordinationBloc: _coordinationBloc,
      crashes: widget._analytics,
    );
    _gameBloc = GameBloc(
      coordinationBloc: _coordinationBloc,
      teamBloc: _teamBloc,
      crashes: widget._analytics,
    );
    _filteredGameBloc = FilteredGameBloc(
        gameBloc: _gameBloc, teamBloc: _teamBloc, seasonBloc: _seasonBloc);
    _loadedStateBloc = LoadedStateBloc(coordinationBloc: _coordinationBloc);

    _authenticationBloc.add(AuthenticationAppStarted());
    initDynamicLinks();
    // Setup the local notifications to work with FCM.
    _notifications = Notifications(selectNotification, _authenticationBloc);
    _notifications.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<fluro.FluroRouter>(
          create: (context) => AppRouter.createAppRouter(local),
        ),
        RepositoryProvider<AnalyticsSubsystemImpl>(
          create: (c) => widget._analytics,
        ),
        RepositoryProvider<UserAuthImpl>(
          create: (c) => _userAuthImpl,
        ),
        RepositoryProvider<Notifications>(
          create: (v) => _notifications,
        ),
        RepositoryProvider<FirebaseDynamicLinks>(
            create: (c) => FirebaseDynamicLinks.instance),
        RepositoryProvider<DatabaseUpdateModel>(
            create: (context) => _databaseUpdateModel),
        RepositoryProvider<BaseCacheManager>(
            create: (context) => DefaultCacheManager()),
        RepositoryProvider<AppConfiguration>(
            create: (context) => widget._config),
        RepositoryProvider<LoggingData>(
            create: (context) => widget._loggingData),
        RepositoryProvider<Notifications>(create: (context) => _notifications),
        RepositoryProvider<ImagePicker>(create: (context) => ImagePicker()),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AuthenticationBloc>(
            create: (context) => _authenticationBloc,
          ),
          BlocProvider<CoordinationBloc>(
              create: (context) => _coordinationBloc),
          BlocProvider<InviteBloc>(create: (context) => _inviteBloc),
          BlocProvider<TeamBloc>(create: (context) => _teamBloc),
          BlocProvider<SeasonBloc>(create: (context) => _seasonBloc),
          BlocProvider<MessagesBloc>(create: (context) => _messagesBloc),
          BlocProvider<LeagueOrTournamentBloc>(
              create: (context) => _leagueOrTournamentBloc),
          BlocProvider<ClubBloc>(create: (context) => _clubBloc),
          BlocProvider<GameBloc>(create: (context) => _gameBloc),
          BlocProvider<FilteredGameBloc>(
              create: (context) => _filteredGameBloc),
          BlocProvider<PlayerBloc>(create: (context) => _playerBloc),
          BlocProvider<LoadedStateBloc>(create: (context) => _loadedStateBloc),
        ],
        child: _materialApp(context),
      ),
    );
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final deepLink = dynamicLink?.link;

      if (deepLink != null &&
          _authenticationBloc.state is AuthenticationLoggedIn) {
        await Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.pushNamed(
      context,
      payload,
    );
  }

  @override
  void dispose() {
    super.dispose();
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
    _coordinationBloc.close();
    _authenticationBloc.close();
  }
}
