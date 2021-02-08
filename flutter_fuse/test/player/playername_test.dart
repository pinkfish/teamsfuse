import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../util/testable.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

void main() {
  testWidgets('uninitialized', (tester) async {
    var mockDb = MockDatabaseUpdateModel();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        RepositoryProvider<DatabaseUpdateModel>(
          create: (c) => mockDb,
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

    await tester.pumpAndSettle();

    await expectLater(find.text("Frog"), findsOneWidget);
  });
}
