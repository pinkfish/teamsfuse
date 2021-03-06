import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/game/gamedetails.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../../util/fakeplatformcontroller.dart';
import '../../util/testable.dart';
import '../../util/testdata.dart';
import '../../util/widgetvariant.dart';

void main() {
  final FakePlatformViewsController fakePlatformViewsController =
      FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });

  testWidgets('uninitialized', (tester) async {
    resetMockitoState();

    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();

    setupStorage();

    when(mockDb.getGame('123')).thenAnswer((_) => gameController.stream);

    // Build our app and trigger a frame.

    final testWidget = await makeTestableWidget(
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
    final mockDb = MockDatabaseUpdateModel();
    final mockAnalytics = MockAnalyticsSubsystem();
    final gameController = StreamController<Game>();
    final mockObserver = MockNavigatorObserver();

    AsyncHydratedStorage.storageDirectory = Directory('fail');

    when(mockDb.getGame('123')).thenAnswer((_) => gameController.stream);

    // Build our app and trigger a frame.
    final testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(create: (c) => mockDb),
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics)
        ],
        child: GameDetailsScreen('123'),
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
    setupStorage();

    final teamController = StreamController<Team>();
    final seasonController = StreamController<Season>();
    final allBlocs = AllBlocs();

    when(allBlocs.mockDb.getGame('game123'))
        .thenAnswer((_) => allBlocs.gameController.stream);
    when(allBlocs.mockDb.getTeamDetails(teamUid: 'team123'))
        .thenAnswer((_) => teamController.stream);
    when(allBlocs.mockDb.getSingleSeason('season123'))
        .thenAnswer((_) => seasonController.stream);

    // Build our app and trigger a frame.
    final testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => allBlocs.mockDb),
          RepositoryProvider<AnalyticsSubsystem>(
              create: (c) => allBlocs.mockAnalytics)
        ],
        child: BlocProvider<PlayerBloc>(
          create: (_) => allBlocs.playerBloc,
          child: RepaintBoundary(
            child: GameDetailsScreen('game123'),
          ),
        ),
      ),
      observer: allBlocs.mockObserver,
    );

    await tester.pumpWidget(testWidget);
    allBlocs.gameController.add(makeTestGame());

    await tester.pump(Duration(milliseconds: 600));

    // Still loading when there is no team.
    expect(find.text('Loading...'), findsOneWidget);

    await allBlocs.close();
  }, variant: TeamsFuseTestVariant());

  testWidgets('loaded team', (tester) async {
    final teamController = StreamController<Team>();
    final seasonController = StreamController<Season>();
    final opponentController = StreamController<Iterable<Opponent>>();
    final teamSeasonController = StreamController<BuiltList<Season>>();
    final allStuff = AllBlocs();

    when(allStuff.mockDb.getGame('game123'))
        .thenAnswer((_) => allStuff.gameController.stream);
    when(allStuff.mockDb.getTeamDetails(teamUid: 'team123'))
        .thenAnswer((_) => teamController.stream);
    when(allStuff.mockDb.getSingleSeason('season123'))
        .thenAnswer((_) => seasonController.stream);
    when(allStuff.mockDb.getTeamOpponents('team123'))
        .thenAnswer((_) => opponentController.stream);
    when(allStuff.mockDb.getSeasonsForTeam('team123'))
        .thenAnswer((_) => teamSeasonController.stream);
    allStuff.playerBloc.emit((PlayerLoaded.fromState(PlayerUninitialized())
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
    final testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => allStuff.mockDb),
          RepositoryProvider<AnalyticsSubsystem>(
              create: (c) => allStuff.mockAnalytics)
        ],
        child: BlocProvider<PlayerBloc>(
          create: (_) => allStuff.playerBloc,
          child: RepaintBoundary(
            child: GameDetailsScreen('game123'),
          ),
        ),
      ),
      observer: allStuff.mockObserver,
    );

    await tester.pumpWidget(testWidget);

    final season = makeTestSeason();
    allStuff.gameController.add(makeTestGame(
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

    await allStuff.close();
  }, variant: TeamsFuseTestVariant());

  testWidgets('loaded basketball, finished', (tester) async {
    final teamController = StreamController<Team>();
    final seasonController = StreamController<Season>();
    final opponentController = StreamController<Iterable<Opponent>>();
    final teamSeasonController = StreamController<BuiltList<Season>>();
    final allBlocs = AllBlocs();

    when(allBlocs.mockDb.getGame('game123'))
        .thenAnswer((_) => allBlocs.gameController.stream);
    when(allBlocs.mockDb.getTeamDetails(teamUid: 'team123'))
        .thenAnswer((_) => teamController.stream);
    when(allBlocs.mockDb.getSingleSeason('season123'))
        .thenAnswer((_) => seasonController.stream);
    when(allBlocs.mockDb.getTeamOpponents('team123'))
        .thenAnswer((_) => opponentController.stream);
    when(allBlocs.mockDb.getSeasonsForTeam('team123'))
        .thenAnswer((_) => teamSeasonController.stream);

    allBlocs.playerBloc.emit((PlayerLoaded.fromState(PlayerUninitialized())
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
    final testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => allBlocs.mockDb),
          RepositoryProvider<AnalyticsSubsystem>(
              create: (c) => allBlocs.mockAnalytics)
        ],
        child: BlocProvider<PlayerBloc>(
          create: (_) => allBlocs.playerBloc,
          child: RepaintBoundary(
            child: GameDetailsScreen('game123'),
          ),
        ),
      ),
      observer: allBlocs.mockObserver,
    );

    await tester.pumpWidget(testWidget);

    final season = makeTestSeason();
    final newScores = Map<GamePeriod, GameResultPerPeriod>.fromEntries([
      MapEntry(
          GamePeriod.regulation1,
          GameResultPerPeriod((b) => b
            ..score.ptsFor = 12
            ..score.ptsAgainst = 12
            ..period = GamePeriod.regulation1.toBuilder()))
    ]);
    final game = makeTestGame(
            start: DateTime(2021, 3, 2, 11, 3, 1).toUtc(),
            end: DateTime(2021, 3, 44, 11, 3, 1).toUtc())
        .rebuild((b) => b
          ..result.inProgress = GameInProgress.Final
          ..result.result = GameResult.Win
          ..result.scoresInternal = MapBuilder(newScores));
    allBlocs.gameController.add(game);
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

    await allBlocs.close();
    seasonController.close();
    opponentController.close();
    teamSeasonController.close();
    teamController.close();
  }, variant: TeamsFuseTestVariant());
}
