import 'package:fluro/fluro.dart' as fluro;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

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
  final String _publicClub;

  ///
  /// Create the app.
  ///
  FlutterFuseApp(
      this._firestore, this._config, this._loggingData, this._publicClub);

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

  final ThemeData _theme = ThemeData(
    primarySwatch: Colors.green,
  );

  Widget _materialApp(BuildContext context) {
    // Setup the app and do exciting things.
    return FuseMaterialApp(_theme, widget._publicClub);
  }

  @override
  void initState() {
    super.initState();
    var userAuthImpl = UserAuthImpl(widget._firestore);
    _authenticationBloc =
        AuthenticationBloc(userAuthImpl, AnalyticsSubsystemImpl.instance);
    _databaseUpdateModel = DatabaseUpdateModelImpl(
        Firestore(), _authenticationBloc, AnalyticsSubsystemImpl.instance);
    if (widget._publicClub.isEmpty) {
      _coordinationBloc = CoordinationBloc(
          authenticationBloc: _authenticationBloc,
          analytics: AnalyticsSubsystemImpl.instance,
          databaseUpdateModel: _databaseUpdateModel,
          analyticsSubsystem: AnalyticsSubsystemImpl.instance);
      _playerBloc = PlayerBloc(
        coordinationBloc: _coordinationBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _inviteBloc = InviteBloc(
          coordinationBloc: _coordinationBloc,
          crashes: AnalyticsSubsystemImpl.instance,
          databaseUpdateModel: _databaseUpdateModel);
      _messagesBloc = MessagesBloc(
        coordinationBloc: _coordinationBloc,
        teamBloc: _teamBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _clubBloc = ClubBloc(
        coordinationBloc: _coordinationBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _teamBloc = TeamBloc(
        coordinationBloc: _coordinationBloc,
        clubBloc: _clubBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _seasonBloc = SeasonBloc(
        coordinationBloc: _coordinationBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _leagueOrTournamentBloc = LeagueOrTournamentBloc(
        coordinationBloc: _coordinationBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _gameBloc = GameBloc(
        coordinationBloc: _coordinationBloc,
        teamBloc: _teamBloc,
        crashes: AnalyticsSubsystemImpl.instance,
      );
      _filteredGameBloc = FilteredGameBloc(
          gameBloc: _gameBloc, teamBloc: _teamBloc, seasonBloc: _seasonBloc);
      _loadedStateBloc = LoadedStateBloc(coordinationBloc: _coordinationBloc);

      _authenticationBloc.add(AuthenticationAppStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = [];
    if (widget._publicClub.isEmpty) {
      extra.addAll([
        BlocProvider<CoordinationBloc>(create: (context) => _coordinationBloc),
        BlocProvider<InviteBloc>(create: (context) => _inviteBloc),
        BlocProvider<TeamBloc>(create: (context) => _teamBloc),
        BlocProvider<SeasonBloc>(create: (context) => _seasonBloc),
        BlocProvider<MessagesBloc>(create: (context) => _messagesBloc),
        BlocProvider<LeagueOrTournamentBloc>(
            create: (context) => _leagueOrTournamentBloc),
        BlocProvider<ClubBloc>(create: (context) => _clubBloc),
        BlocProvider<GameBloc>(create: (context) => _gameBloc),
        BlocProvider<FilteredGameBloc>(create: (context) => _filteredGameBloc),
        BlocProvider<PlayerBloc>(create: (context) => _playerBloc),
        BlocProvider<LoadedStateBloc>(create: (context) => _loadedStateBloc),
      ]);
    }

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<fluro.FluroRouter>(
          create: (context) => AppRouter.createAppRouter(),
        ),
        RepositoryProvider<AnalyticsSubsystem>(
          create: (c) => AnalyticsSubsystemImpl.instance,
        ),
        RepositoryProvider<DatabaseUpdateModel>(
            create: (context) => _databaseUpdateModel),
        RepositoryProvider<BaseCacheManager>(
            create: (context) => DefaultCacheManager()),
        RepositoryProvider<AppConfiguration>(
            create: (context) => widget._config),
        RepositoryProvider<LoggingData>(
            create: (context) => widget._loggingData),
        RepositoryProvider<Notifications>(create: (context) => Notifications()),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AuthenticationBloc>(
            create: (context) => _authenticationBloc,
          ),
          ...extra
        ],
        child: _materialApp(context),
      ),
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
