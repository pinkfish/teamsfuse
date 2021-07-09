import 'dart:io';
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystemImpl {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseDynamicLinks extends Mock implements FirebaseDynamicLinks {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockNotifications extends Mock implements Notifications {}

class MockPendingDynamicLinkData extends Mock
    implements PendingDynamicLinkData {}

class MockUserAuth extends Mock implements UserAuthImpl {}

class MockStorage extends Mock implements HydratedStorage {}

///
/// Makes a happy little testable widget with a wrapper.
///
Future<Widget> makeTestableWidget(Widget child,
    {NavigatorObserver observer}) async {
  AsyncHydratedStorage.storageDirectory = Directory('fail');
  await loadAppFonts();
  initializeTimeZones();

  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        MessagesTestDelegate(),
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
        return SlideInOutPageRoute(builder: (c) => child, settings: s);
      },
    ),
  );
}

///
/// Router name checking class.
///
class HasRouteName extends CustomMatcher {
  HasRouteName(matcher) : super('Route with the nme that is', 'name', matcher);
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
  final mockAnalytics = MockAnalyticsSubsystem();
  final mockUserAuth = MockUserAuth();
  final gameController = StreamController<Game>();
  final userController = StreamController<UserData>();
  final mockObserver = MockNavigatorObserver();
  AuthenticationBloc authBloc;

  BasicData() {
    setupStorage();
    when(mockUserAuth.onAuthChanged()).thenAnswer((_) => userController.stream);
    authBloc = AuthenticationBloc(mockUserAuth, mockAnalytics);
  }

  void close() {
    userController.close();
    gameController.close();
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

/// Mocked stream.
class MS<T> extends Mock implements Stream<T> {}

/// Mock subscription for the generator.
class MockSubscription<T> extends Mock implements StreamSubscription<T> {}

/// Simple generator that always returns the same result from a stream.
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
    when(stream.listen(any)).thenAnswer((invocation) {
      invocation.positionalArguments.single(data);

      var sub = MockSubscription<T>();
      when(sub.onError(any)).thenAnswer((invocation) {
        if (throwException != null) {
          invocation.positionalArguments.single(throwException);
        }
      });
      when(sub.cancel()).thenAnswer((invocation) {
        return;
      });
      return sub;
    });

    return stream;
  }
}

///
/// Setup a bloc observer for the tests so we can see what is happening
/// in tests.
///
void setupBlocObserver() {
  Bloc.observer = _SimpleBlocDelegate();
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

class SlideInOutPageRoute<T> extends PageRouteBuilder<T> {
  SlideInOutPageRoute({@required WidgetBuilder builder, RouteSettings settings})
      : super(
          settings: settings,
          transitionDuration: Duration(seconds: 0),
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return child;
          },
        );

  @override
  AnimationController get controller => super.controller;
}
