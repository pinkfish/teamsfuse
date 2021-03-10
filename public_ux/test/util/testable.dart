import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:public_ux/services/messagespublic.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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
  HasRouteName(matcher) : super('Route with the nme that is', 'name', matcher);
  @override
  featureValueOf(actual) => (actual as Route).settings.name;
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

  AllBlocs() {
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
