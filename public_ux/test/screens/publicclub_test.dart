///
/// Widget tests for the public home screen.
///
import 'dart:async';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:public_ux/screens/publicclubhome.dart';

import '../util/teamfusetestvariant.dart';
import '../util/testable.dart';

void main() {
  final testClub = (ClubBuilder()
        ..name = 'Fluff'
        ..uid = 'club'
        ..isPublic = true
        ..about = 'This club is all about fluff'
        ..sport = Sport.Basketball
        ..arriveBeforeGame = 0
        ..photoUrl = '')
      .build();
  final testTeam = (TeamBuilder()
        ..uid = 'frog'
        ..name = 'Waffle'
        ..arriveEarlyInternal = 0
        ..sport = Sport.Basketball
        ..gender = Gender.Female
        ..league = 'AAU'
        ..clubUid = 'club'
        ..currentSeason = 'season'
        ..trackAttendenceInternal = true
        ..isPublic = true)
      .build();
  final testSeason = (SeasonBuilder()
        ..uid = 'frog'
        ..name = 'Waffle'
        ..teamUid = 'frog'
        ..isPublic = true
        ..playersData = MapBuilder({
          'rabbit': (SeasonPlayerBuilder()
                ..playerUid = 'rabbit'
                ..isPublic = true
                ..jerseyNumber = '42'
                ..added = true
                ..role = RoleInTeam.Player)
              .build(),
        })
        ..record.loss = 0
        ..record.win = 0
        ..record.tie = 0)
      .build();
  final testCoach = (CoachBuilder()
        ..uid = 'frog'
        ..photoUrl = ''
        ..about = 'Great at catching flies'
        ..clubUid = 'club'
        ..name = 'Frog froggy')
      .build();
  final testPlayer = (PlayerBuilder()
        ..uid = 'rabbit'
        ..photoUrl = ''
        ..name = 'Bunny Wunny')
      .build();
  final testNewsItem = (NewsItemBuilder()
        ..uid = 'news'
        ..subject = 'More fluff'
        ..body = 'More fluff was found'
        ..clubUid = 'club'
        ..postedByName = 'Big Fluff'
        ..postedByUid = 'user'
        ..timeCreated = Timestamp.fromDateTime(DateTime(2021, 10, 9, 12, 3)))
      .build();

  testWidgets(
    'Club loading',
    (WidgetTester tester) async {
      final clubController = StreamController<Club>();
      final basicData = BasicData();
      basicData.addController(clubController);

      when(basicData.mockDb.getClubData(clubUid: 'club'))
          .thenAnswer((_) => clubController.stream);
      // Build our app and trigger a frame.
      final testWidget =
          await makeTestableWidget(PublicClubHomeScreen('', 'club', ''));

      await tester.pumpWidget(basicData.injectBlocs(testWidget));

      await tester.pump(Duration(milliseconds: 600));

      expect(find.text('Loading...'), findsNWidgets(2));

      await basicData.close();
    },
    variant: TeamsFuseTestVariant(),
  );

  testWidgets(
    'Club loaded',
    (WidgetTester tester) async {
      final clubController = StreamController<Club>();
      final basicData = BasicData();
      basicData.addController(clubController);

      when(basicData.mockDb.getClubData(clubUid: anyNamed('clubUid')))
          .thenAnswer((_) => clubController.stream);

      // Build our app and trigger a frame.
      final testWidget = await makeTestableWidget(
          PublicClubHomeScreen(PublicClubTab.club.name, 'club', ''));

      await tester.pumpWidget(basicData.injectBlocs(testWidget));
      clubController.add(testClub);

      await tester.pump(Duration(milliseconds: 600));
      await tester.pump();

      expect(find.text('Fluff'), findsNWidgets(2));

      await basicData.close();
    },
    variant: TeamsFuseTestVariant(),
  );

  testWidgets(
    'Club coaches',
    (WidgetTester tester) async {
      final coachesController = StreamController<BuiltList<Coach>>();
      final clubController = StreamController<Club>();
      final coachController = StreamController<Coach>();
      final basicData = BasicData();
      basicData.addController(clubController);
      basicData.addController(coachController);

      when(basicData.mockDb.getSingleClubCoach('club', 'frog'))
          .thenAnswer((_) => coachController.stream);
      when(basicData.mockDb.getClubCoaches('club'))
          .thenAnswer((_) => coachesController.stream);
      when(basicData.mockDb.getClubData(clubUid: anyNamed('clubUid')))
          .thenAnswer((_) => clubController.stream);

      // Build our app and trigger a frame.
      final testWidget = await makeTestableWidget(
          PublicClubHomeScreen(PublicClubTab.coaches.name, 'club', ''));

      await tester.pumpWidget(basicData.injectBlocs(testWidget));
      clubController.add(testClub);

      await tester.pump(Duration(milliseconds: 600));
      await tester.pump();

      expect(find.text('Fluff'), findsNWidgets(1));
      expect(find.text('Loading...'), findsOneWidget);

      final coaches = <Coach>[
        testCoach,
      ];
      coachesController.add(BuiltList.of(coaches));
      coachController.add(coaches[0]);

      await tester.pump(Duration(milliseconds: 600));
      await tester.pump();
      expect(find.text('Frog froggy'), findsOneWidget);

      await basicData.close();
    },
    variant: TeamsFuseTestVariant(),
  );

  testWidgets(
    'Club team',
    (WidgetTester tester) async {
      final clubController = StreamGenerator<Club>(testClub);
      final teamController = StreamGenerator<Team>(testTeam);
      final seasonController = StreamGenerator<Season>(testSeason);
      final playersController = StreamGenerator<Player>(testPlayer);
      final basicData = BasicData();

      when(basicData.mockDb.getTeamDetails(teamUid: anyNamed('teamUid')))
          .thenAnswer((_) => teamController.stream());
      when(basicData.mockDb.getClubData(clubUid: anyNamed('clubUid')))
          .thenAnswer((_) => clubController.stream());
      when(basicData.mockDb.getSingleSeason('season'))
          .thenAnswer((_) => seasonController.stream());
      when(basicData.mockDb.getPlayerDetails('rabbit'))
          .thenAnswer((_) => playersController.stream());

      // Build our app and trigger a frame.
      final testWidget = await makeTestableWidget(
          PublicClubHomeScreen(PublicClubTab.team.name, 'club', 'team'));

      await tester.pumpWidget(basicData.injectBlocs(testWidget));
      await tester.pump();

      // Loading at this point.
      expect(find.text('Loading...'), findsNWidgets(2));

      // Some bits should be loaded here, the title at least.
      await tester.pump(Duration(milliseconds: 600));
      await tester.pump();

      expect(find.text('Fluff'), findsOneWidget);
      expect(find.text('Loading...'), findsNWidgets(2));

      await tester.pump(Duration(milliseconds: 600));
      await tester.pump();

      if (Platform.environment['GOLDEN'] != null) {
        await expectLater(find.byWidget(testWidget),
            matchesGoldenFile('../golden/PublicClubHomeScreen_team.png'));
      }

      expect(find.text('Waffle'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);

      await basicData.close();
    },
    variant: TeamsFuseTestVariant(),
  );

  testWidgets(
    'Club news',
    (WidgetTester tester) async => withClock(
      Clock.fixed(DateTime(2020, 09, 01)),
      () async {
        final clubController = StreamGenerator<Club>(testClub);
        final teamController = StreamGenerator<Team>(testTeam);
        final seasonController = StreamGenerator<Season>(testSeason);
        final playersController = StreamGenerator<Player>(testPlayer);
        final newsItemsController =
            StreamGenerator<BuiltList<NewsItem>>(BuiltList.of([testNewsItem]));
        final singeNewsItemsController =
            StreamGenerator<NewsItem>(testNewsItem);
        final basicData = BasicData();

        when(basicData.mockDb.getTeamDetails(teamUid: anyNamed('teamUid')))
            .thenAnswer((_) => teamController.stream());
        when(basicData.mockDb.getClubData(clubUid: anyNamed('clubUid')))
            .thenAnswer((_) => clubController.stream());
        when(basicData.mockDb.getSingleSeason('season'))
            .thenAnswer((_) => seasonController.stream());
        when(basicData.mockDb.getPlayerDetails('rabbit'))
            .thenAnswer((_) => playersController.stream());
        when(basicData.mockDb.getClubNews('club',
                start: anyNamed('start'), limit: anyNamed('limit')))
            .thenAnswer((_) => newsItemsController.stream());
        when(basicData.mockDb.getSingleClubNews('club', 'news'))
            .thenAnswer((_) => singeNewsItemsController.stream());

        // Build our app and trigger a frame.
        final testWidget = await makeTestableWidget(
            PublicClubHomeScreen(PublicClubTab.news.name, 'club', ''));

        await tester.pumpWidget(basicData.injectBlocs(testWidget));

        await tester.pump(Duration(milliseconds: 600));
        await tester.pump();
        await tester.pump();
        await tester.pump();
        await tester.pump();

        if (Platform.environment['GOLDEN'] != null) {
          await expectLater(find.byWidget(testWidget),
              matchesGoldenFile('../golden/PublicClubHomeScreen_news.png'));
        }

        expect(find.text('Fluff'), findsNWidgets(2));
        expect(find.text('More fluff'), findsOneWidget);
        expect(find.text('By User Profile'), findsOneWidget);
        expect(find.text('More fluff was found'), findsOneWidget);

        await basicData.close();
      },
    ),
    variant: TeamsFuseTestVariant(),
  );

  testGoldens(
    'Home screen, golden',
    (WidgetTester tester) async {
      if (Platform.environment['GOLDEN'] != null) {
        final clubController = StreamController<Club>();
        final basicData = BasicData();
        basicData.addController(clubController);

        when(basicData.mockDb.getClubData(clubUid: anyNamed('clubUid')))
            .thenAnswer((_) => clubController.stream);

        // Build our app and trigger a frame.
        final testWidget = await makeTestableWidget(
            PublicClubHomeScreen(PublicClubTab.club.name, 'club', ''));

        final injected = basicData.injectBlocs(testWidget);
        await tester.pumpWidget(injected);
        clubController.add(testClub);

        await tester.pump(Duration(milliseconds: 600));
        await tester.pump();

        await expectLater(find.byType(PublicClubHomeScreen),
            matchesGoldenFile('../golden/PublicClubHomeScreen.png'));

        await basicData.close();
      }
    },
  );
}
