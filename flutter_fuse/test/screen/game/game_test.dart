import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';

import '../../util/testable.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

void main() {
  /*
  testWidgets('uninitialized', (tester) async {
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();
    var gameController = StreamController<Game>();

    AsyncHydratedStorage.storageDirectory = await getTemporaryDirectory();

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

    await tester.pumpWidget(testWidget);

    expect(find.text("Loading..."), findsOneWidget);
    gameController.close();
  });

  testWidgets('deleted', (tester) async {
    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();
    var gameController = StreamController<Game>();

    AsyncHydratedStorage.storageDirectory = await getTemporaryDirectory();

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
    await tester.pumpWidget(testWidget);
    gameController.add(null);

    await tester.pumpWidget(testWidget);

    expect(find.text("Deleted"), findsOneWidget);

    await expectLater(find.byType(GameDetailsScreen),
        matchesGoldenFile('golden/game_loading.png'));

    gameController.close();
  });
  
   */
}
