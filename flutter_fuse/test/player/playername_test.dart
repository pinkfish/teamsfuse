import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../util/testable.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

void main() {
  testWidgets('uninitialized', (tester) async {
    var gameData = StreamController<Player>();
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();

    // Nothing in the queue, so uninitialized
    when(mockDb.getPlayerDetails("123")).thenAnswer((p) => gameData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => mockDb,
            ),
            RepositoryProvider<AnalyticsSubsystem>(
              create: (c) => mockAnalytics,
            ),
          ],
          child: PlayerName(playerUid: "123"),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Loading..."), findsOneWidget);
  });

  testWidgets('name set', (tester) async {
    var gameData = StreamController<Player>();
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();

    AsyncHydratedStorage.storageDirectory = Directory("fail");

    // Stub the state stream
    //singlePlayerBloc.emit(SinglePlayerUninitialized());
    when(mockDb.getPlayerDetails("123")).thenAnswer((p) => gameData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => mockDb,
            ),
            RepositoryProvider<AnalyticsSubsystem>(
              create: (c) => mockAnalytics,
            ),
          ],
          child: RepaintBoundary(
            child: PlayerName(playerUid: "123"),
          ),
        ),
      ),
    );
    gameData.add(Player((b) => b
      ..name = "Frog"
      ..uid = "123"));

    await tester.pump(Duration(milliseconds: 600));

    await expectLater(find.text("Frog"), findsOneWidget);
  });

  testWidgets('name change', (tester) async {
    var gameData = StreamController<Player>();
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();

    // Stub the state stream
    //singlePlayerBloc.emit(SinglePlayerUninitialized());
    when(mockDb.getPlayerDetails("123")).thenAnswer((p) => gameData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => mockDb,
            ),
            RepositoryProvider<AnalyticsSubsystem>(
              create: (c) => mockAnalytics,
            ),
          ],
          child: RepaintBoundary(
            child: PlayerName(playerUid: "123"),
          ),
        ),
      ),
    );
    gameData.add(Player((b) => b
      ..name = "Frog"
      ..uid = "123"));

    await tester.pump(Duration(milliseconds: 600));

    await expectLater(find.text("Frog"), findsOneWidget);

    gameData.add(Player((b) => b
      ..name = "Bluey"
      ..uid = "123"));

    await tester.pump(Duration(milliseconds: 600));

    await expectLater(find.text("Bluey"), findsOneWidget);
  });
}
