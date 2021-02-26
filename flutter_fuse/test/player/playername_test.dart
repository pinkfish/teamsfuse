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
import '../util/widgetvariant.dart';

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
      await makeTestableWidget(
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
  }, variant: TeamsFuseTestVariant());

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
      await makeTestableWidget(
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
            child: PlayerName(
              playerUid: "123",
              style: TextStyle(
                  fontFamily: "Roboto", fontSize: 12.0, color: Colors.black),
            ),
          ),
        ),
      ),
    );
    gameData.add(Player((b) => b
      ..name = "Frog"
      ..uid = "123"));

    await tester.pumpAndSettle();

    await expectLater(find.text("Frog (Invited)"), findsOneWidget);

    if (String.fromEnvironment("GOLDEN", defaultValue: "").isNotEmpty) {
      await expectLater(find.byType(PlayerName),
          matchesGoldenFile('../golden/player_name_set.png'));
    }
  }, variant: TeamsFuseTestVariant());

  testWidgets('name change', (tester) async {
    var gameData = StreamController<Player>();
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();

    // Stub the state stream
    when(mockDb.getPlayerDetails("123")).thenAnswer((p) => gameData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      await makeTestableWidget(
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
            child: PlayerName(
              playerUid: "123",
              style: TextStyle(
                  fontFamily: "Roboto", fontSize: 12.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
    gameData.add(Player((b) => b
      ..name = "Frog"
      ..uid = "123"
      ..usersData["1232"] = PlayerUserInternal((b) => b
        ..added = true
        ..relationship = Relationship.Parent)));

    await tester.pumpAndSettle();

    await expectLater(find.text("Frog"), findsOneWidget);

    gameData.add(Player((b) => b
      ..name = "Bluey"
      ..uid = "123"));

    await tester.pumpAndSettle();

    await expectLater(find.text("Bluey (Invited)"), findsOneWidget);
  }, variant: TeamsFuseTestVariant());
}
