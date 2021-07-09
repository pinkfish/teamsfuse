import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:public_ux/services/algolia.dart';
import 'package:public_ux/services/messagespublic.dart';
import 'package:timezone/data/latest.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystemImpl extends Mock
    implements AnalyticsSubsystemImpl {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserAuth extends Mock implements UserAuthImpl {}

class MockStorage extends Mock implements HydratedStorage {}

class MockAlgoliaSearch extends Mock implements AlgoliaSearch {}

class MockNotifications extends Mock implements Notifications {}

///
/// Makes a happy little testable widget with a wrapper.
///
Future<Widget> makeTestableWidget(Widget child,
    {NavigatorObserver observer}) async {
  AsyncHydratedStorage.storageDirectory = Directory('fail');
  await loadAppFonts();
  initializeTimeZones();

  Bloc.observer = _SimpleBlocDelegate();

  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        MessagesTestDelegate(),
        MessagesPublicTestDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      navigatorObservers: observer != null ? [observer] : [],
      color: Colors.green,
      home: child,
      // By default this navigates back to the current route.
      onGenerateRoute: (s) {
        return MaterialPageRoute(builder: (c) => child, settings: s);
      },
    ),
  );
}

///
/// Router name checking class.
///
class HasRouteName extends CustomMatcher {
  HasRouteName(matcher) : super('Route with the name that is', 'name', matcher);
  @override
  String featureValueOf(actual) => (actual as Route).settings.name;
}

///
/// Setups the storage and the mock storage for the hydrated bloc.
///
MockStorage setupStorage() {
  final storage = MockStorage();
  HydratedBloc.storage = storage;
  when(storage.read(any)).thenReturn(<dynamic, dynamic>{});
  when(storage.write(any, any)).thenAnswer((_) => Future.value(null));
  AsyncHydratedStorage.storageDirectory = Directory('fail');
  return storage;
}

///
/// Setup the basic data to handle the db and other things.
///
class BasicData {
  final mockDb = MockDatabaseUpdateModel();
  final mockAnalytics = MockAnalyticsSubsystemImpl();
  final mockUserAuth = MockUserAuth();
  final mockObserver = MockNavigatorObserver();
  final mockAlgoliaSearch = MockAlgoliaSearch();
  final userController = StreamController<UserData>();
  AuthenticationBloc authBloc;
  final List<StreamController> _controllers = [];

  final FusedUserProfile testProfile = (FusedUserProfileBuilder()
        ..uid = 'user'
        ..displayName = 'User Profile'
        ..email = 'test@test.com'
        ..emailUpcomingGame = true
        ..emailOnUpdates = true
        ..notifyOnlyForGames = true)
      .build();
  StreamGenerator<FusedUserProfile> profileStream;

  BasicData() {
    setupStorage();
    when(mockUserAuth.onAuthChanged()).thenAnswer((_) => userController.stream);

    authBloc = AuthenticationBloc(mockUserAuth, mockAnalytics);
    _controllers.add(userController);
    profileStream = StreamGenerator<FusedUserProfile>(testProfile);
    when(mockUserAuth.getProfileStream('user'))
        .thenAnswer((_) => profileStream.stream());
  }

  void addController(StreamController cont) {
    _controllers.add(cont);
  }

  void close() async {
    for (final c in _controllers) {
      await c.close();
    }
    _controllers.clear();
  }

  Widget injectBlocs(Widget widget) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AlgoliaSearch>(create: (c) => mockAlgoliaSearch),
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystemImpl>(
              create: (c) => mockAnalytics),
          RepositoryProvider<UserAuthImpl>(create: (c) => mockUserAuth),
        ],
        child: BlocProvider<AuthenticationBloc>(
          create: (c) => authBloc,
          child: widget,
        ));
  }
}

///
/// Create all the blocs.
///
class AllBlocs extends BasicData {
  CoordinationBloc coordinationBloc;
  ClubBloc clubBloc;
  TeamBloc teamBloc;
  SeasonBloc seasonBloc;
  GameBloc gameBloc;
  MessagesBloc messagesBloc;
  LoadedStateBloc loadedStateBloc;
  InviteBloc inviteBloc;
  PlayerBloc playerBloc;
  MockNotifications mockNotifications;

  AllBlocs() {
    mockNotifications = MockNotifications();
    coordinationBloc = CoordinationBloc(
      authenticationBloc: authBloc,
      analytics: mockAnalytics,
      databaseUpdateModel: mockDb,
    );
    clubBloc = ClubBloc(
      coordinationBloc: coordinationBloc,
      crashes: mockAnalytics,
    );
    teamBloc = TeamBloc(
      coordinationBloc: coordinationBloc,
      clubBloc: clubBloc,
      crashes: mockAnalytics,
    );
    seasonBloc = SeasonBloc(
      coordinationBloc: coordinationBloc,
      crashes: mockAnalytics,
    );
    gameBloc = GameBloc(
      coordinationBloc: coordinationBloc,
      notifications: mockNotifications,
      teamBloc: teamBloc,
      crashes: mockAnalytics,
    );
    messagesBloc = MessagesBloc(
      coordinationBloc: coordinationBloc,
      crashes: mockAnalytics,
    );
    loadedStateBloc = LoadedStateBloc(
      coordinationBloc: coordinationBloc,
    );
    inviteBloc = InviteBloc(
      coordinationBloc: coordinationBloc,
      crashes: mockAnalytics,
      databaseUpdateModel: mockDb,
    );
    playerBloc =
        PlayerBloc(coordinationBloc: coordinationBloc, crashes: mockAnalytics);
  }
}

///
/// Simple delegate to print out the transitions.
///
class _SimpleBlocDelegate extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('Transition: ${transition.currentState.runtimeType.toString()} '
        'event: ${transition.event.runtimeType.toString()} '
        'nextState: ${transition.nextState.runtimeType.toString()}');
  }
}

class MS<T> extends Mock implements Stream<T> {}

class MockSubscription<T> extends Mock implements StreamSubscription<T> {}

class StreamGenerator<T> {
  final T data;
  final int maxCount;
  final Duration interval;
  final Exception throwException;

  StreamGenerator(this.data,
      {this.maxCount = 5,
      this.interval = const Duration(seconds: 1),
      this.throwException});

  Stream<T> stream() {
    var stream = MS<T>();
    when(stream.listen(any)).thenAnswer((invoc) {
      invoc.positionalArguments.single(data);

      var sub = MockSubscription<T>();
      when(sub.onError(any)).thenAnswer((invoc) {
        if (throwException != null) {
          invoc.positionalArguments.single(throwException);
        }
      });
      when(sub.cancel()).thenAnswer((invoc) {
        return;
      });
      return sub;
    });

    return stream;
    /*
    yield data;
    int i = 0;
    while (true) {
      await Future.delayed(interval);
      yield data;
      if (++i == maxCount) break;
    }

      */
  }
}
