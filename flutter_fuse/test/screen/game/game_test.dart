import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';
import 'package:flutter_fuse/services/blocs/single/singlegamebloc.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../../util/testable.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

class MockSingleGameBloc extends MockBloc<int> implements SingleGameBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets('uninitialized', (tester) async {
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();
    var gameController = StreamController<Game>();

    AsyncHydratedStorage.storageDirectory = Directory("fail");

    when(mockDb.getGame("123")).thenAnswer((_) => gameController.stream);

    // Build our app and trigger a frame.

    var testWidget = makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: GameDetailsScreen("123"),
      ),
    );

    await tester.pumpWidget(
      testWidget,
    );

    //await tester.pumpWidget(testWidget);
    await tester.pump(Duration(milliseconds: 600));

    expect(find.text("Loading..."), findsOneWidget);
    gameController.close();
  });

  testWidgets('deleted', (tester) async {
    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();
    final mockObserver = MockNavigatorObserver();

    AsyncHydratedStorage.storageDirectory = Directory("fail");

    when(mockDb.getGame("123")).thenAnswer((_) => gameController.stream);

    // Build our app and trigger a frame.
    var testWidget = makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: GameDetailsScreen("123"),
      ),
      observer: mockObserver,
    );

    await tester.pumpWidget(testWidget);
    gameController.add(null);

    await tester.pump(Duration(milliseconds: 600));

    verify(mockObserver.didPop(any, any));

    gameController.close();
  });
}
