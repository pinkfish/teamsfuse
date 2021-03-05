import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';
import 'package:flutter_fuse/services/blocs/playerbloc.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mockito/mockito.dart';

import '../../util/googlemapsplatformtest.dart';
import '../../util/loadfonts.dart';
import '../../util/testable.dart';
import '../../util/testdata.dart';
import '../../util/widgetvariant.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockPlayerBloc extends MockBloc<PlayerState> implements PlayerBloc {}

void main() {
  var platform = MockGoogleMapsFlutterPlatform();

  testWidgets('uninitialized', (tester) async {
    await loadFonts();

    var mockDb = MockDatabaseUpdateModel();
    var mockAnalytics = MockAnalyticsSubsystem();
    var gameController = StreamController<Game>();

    AsyncHydratedStorage.storageDirectory = Directory('fail');

    when(mockDb.getGame('123')).thenAnswer((_) => gameController.stream);

    // Build our app and trigger a frame.

    var testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: GameDetailsScreen('123'),
      ),
    );

    await tester.pumpWidget(
      testWidget,
    );

    //await tester.pumpWidget(testWidget);
    await tester.pump(Duration(milliseconds: 600));

    expect(find.text('Loading...'), findsOneWidget);
    await gameController.close();
  }, variant: TeamsFuseTestVariant());

  testWidgets('deleted', (tester) async {
    await loadFonts();

    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();
    final mockObserver = MockNavigatorObserver();
    final mockPlayerBloc = MockPlayerBloc();

    AsyncHydratedStorage.storageDirectory = Directory('fail');

    when(mockDb.getGame('123')).thenAnswer((_) => gameController.stream);

    // Build our app and trigger a frame.
    var testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: BlocProvider(
          create: (_) => mockPlayerBloc,
          child: GameDetailsScreen('123'),
        ),
      ),
      observer: mockObserver,
    );

    await tester.pumpWidget(testWidget);
    gameController.add(null);

    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));

    verify(mockObserver.didPop(any, any));

    await gameController.close();
  }, variant: TeamsFuseTestVariant());

  testWidgets('loaded', (tester) async {
    resetMockitoState();
    print('Made platform');
    setupGoogleMapsMock(platform);
    GoogleMapsFlutterPlatform.instance = platform;

    await loadFonts();

    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();
    final teamController = StreamController<Team>();
    final seasonController = StreamController<Season>();
    final mockObserver = MockNavigatorObserver();
    final mockPlayerBloc = MockPlayerBloc();

    when(mockDb.getGame('game123')).thenAnswer((_) => gameController.stream);
    when(mockDb.getTeamDetails(teamUid: 'team123'))
        .thenAnswer((_) => teamController.stream);
    when(mockDb.getSingleSeason('season123'))
        .thenAnswer((_) => seasonController.stream);
    whenListen(mockPlayerBloc, Stream.fromIterable([]));

    // Build our app and trigger a frame.
    var testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: BlocProvider<PlayerBloc>(
          create: (_) => mockPlayerBloc,
          child: RepaintBoundary(
            child: GameDetailsScreen('game123'),
          ),
        ),
      ),
      observer: mockObserver,
    );

    await tester.pumpWidget(testWidget);
    gameController.add(makeTestGame());

    await tester.pump(Duration(milliseconds: 600));

    // Still loading when there is no team.
    expect(find.text('Loading...'), findsOneWidget);

    await gameController.close();
  }, variant: TeamsFuseTestVariant());

  testWidgets('loaded team', (tester) async {
    resetMockitoState();
    print('Made platform');
    setupGoogleMapsMock(platform);
    GoogleMapsFlutterPlatform.instance = platform;

    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();
    final teamController = StreamController<Team>();
    final seasonController = StreamController<Season>();
    final opponentController = StreamController<Iterable<Opponent>>();
    final teamSeasonController = StreamController<BuiltList<Season>>();
    final mockObserver = MockNavigatorObserver();
    final mockPlayerBloc = MockPlayerBloc();

    when(mockDb.getGame('game123')).thenAnswer((_) => gameController.stream);
    when(mockDb.getTeamDetails(teamUid: 'team123'))
        .thenAnswer((_) => teamController.stream);
    when(mockDb.getSingleSeason('season123'))
        .thenAnswer((_) => seasonController.stream);
    when(mockDb.getTeamOpponents('team123'))
        .thenAnswer((_) => opponentController.stream);
    when(mockDb.getSeasonsForTeam('team123'))
        .thenAnswer((_) => teamSeasonController.stream);
    when(mockPlayerBloc.state)
        .thenAnswer((_) => (PlayerLoaded.fromState(PlayerUninitialized())
              ..players = MapBuilder({
                'player123': Player((b) => b
                  ..name = 'Me'
                  ..uid = 'player123')
              }))
            .build());

    // Fake out the places dialog.
    const MethodChannel('flutter_places_dialog')
        .setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'setApiKey') {
        return true; // set initial values here if desired
      }
      return null;
    });

    // Build our app and trigger a frame.
    var testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: BlocProvider<PlayerBloc>(
          create: (_) => mockPlayerBloc,
          child: RepaintBoundary(
            child: GameDetailsScreen('game123'),
          ),
        ),
      ),
      observer: mockObserver,
    );

    await tester.pumpWidget(testWidget);

    var season = makeTestSeason();
    gameController.add(makeTestGame(
        start: DateTime(2021, 3, 2, 11, 3, 1).toUtc(),
        end: DateTime(2021, 3, 44, 11, 3, 1).toUtc()));
    teamController.add(makeTestTeam());
    seasonController.add(season);
    opponentController.add([makeTestOpponent()]);
    teamSeasonController.add(BuiltList.of([season]));

    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));

    // Still loading when there is no team.
    expect(find.text('Fluff World'), findsOneWidget);

    if (Platform.environment['GOLDEN'] != null) {
      await expectLater(find.byType(GameDetailsScreen),
          matchesGoldenFile('../../golden/game_details_set.png'));
    }

    await gameController.close();
  }, variant: TeamsFuseTestVariant());

  testWidgets('loaded basketball, finished', (tester) async {
    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();
    final teamController = StreamController<Team>();
    final seasonController = StreamController<Season>();
    final opponentController = StreamController<Iterable<Opponent>>();
    final teamSeasonController = StreamController<BuiltList<Season>>();
    final mockObserver = MockNavigatorObserver();
    final mockPlayerBloc = MockPlayerBloc();

    when(mockDb.getGame('game123')).thenAnswer((_) => gameController.stream);
    when(mockDb.getTeamDetails(teamUid: 'team123'))
        .thenAnswer((_) => teamController.stream);
    when(mockDb.getSingleSeason('season123'))
        .thenAnswer((_) => seasonController.stream);
    when(mockDb.getTeamOpponents('team123'))
        .thenAnswer((_) => opponentController.stream);
    when(mockDb.getSeasonsForTeam('team123'))
        .thenAnswer((_) => teamSeasonController.stream);
    when(mockPlayerBloc.state)
        .thenAnswer((_) => (PlayerLoaded.fromState(PlayerUninitialized())
              ..players = MapBuilder({
                'player123': Player((b) => b
                  ..name = 'Me'
                  ..uid = 'player123')
              }))
            .build());

    // Fake out the places dialog.
    const MethodChannel('flutter_places_dialog')
        .setMockMethodCallHandler((methodCall) async {
      if (methodCall.method == 'setApiKey') {
        return true; // set initial values here if desired
      }
      return null;
    });

    // Build our app and trigger a frame.
    var testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: BlocProvider<PlayerBloc>(
          create: (_) => mockPlayerBloc,
          child: RepaintBoundary(
            child: GameDetailsScreen('game123'),
          ),
        ),
      ),
      observer: mockObserver,
    );

    await tester.pumpWidget(testWidget);

    var season = makeTestSeason();
    var newScores = Map<GamePeriod, GameResultPerPeriod>.fromEntries([
      MapEntry(
          GamePeriod.regulation1,
          GameResultPerPeriod((b) => b
            ..score.ptsFor = 12
            ..score.ptsAgainst = 12
            ..period = GamePeriod.regulation1.toBuilder()))
    ]);
    var game = makeTestGame(
            start: DateTime(2021, 3, 2, 11, 3, 1).toUtc(),
            end: DateTime(2021, 3, 44, 11, 3, 1).toUtc())
        .rebuild((b) => b
          ..result.inProgress = GameInProgress.Final
          ..result.result = GameResult.Win
          ..result.scoresInternal = MapBuilder(newScores));
    gameController.add(game);
    teamController
        .add(makeTestTeam().rebuild((b) => b..sport = Sport.Basketball));
    seasonController.add(season);
    opponentController.add([makeTestOpponent()]);
    teamSeasonController.add(BuiltList.of([season]));

    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));

    // Still loading when there is no team.
    expect(find.text('Fluff World'), findsOneWidget);

    if (Platform.environment['GOLDEN'] != null) {
      await expectLater(find.byType(GameDetailsScreen),
          matchesGoldenFile('../../golden/game_details_basketball.png'));
    }

    await gameController.close();
  }, variant: TeamsFuseTestVariant());
}
