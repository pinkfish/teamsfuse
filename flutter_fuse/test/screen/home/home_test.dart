import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

import '../../util/loadfonts.dart';
import '../../util/testable.dart';
import '../../util/widgetvariant.dart';

void main() {
  testWidgets(
      'uninitialized',
      (tester) async =>
          withClock(Clock.fixed(DateTime(2020, 09, 01)), () async {
            await loadFonts();

            final allBlocs = AllBlocs();
            await tz.initializeTimeZones();
            var laLoc = getLocation('America/Los_Angeles');

            setupStorage();

            // Fake out the storage so it doesn't load from anywhere or save anywhere.

            when(allBlocs.mockDb.getGame('123'))
                .thenAnswer((_) => allBlocs.gameController.stream);

            // Build our app and trigger a frame.
            print('widget make');
            final testWidget = await makeTestableWidget(
              MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<DatabaseUpdateModel>(
                      create: (c) => allBlocs.mockDb),
                  RepositoryProvider<AnalyticsSubsystem>(
                      create: (c) => allBlocs.mockAnalytics)
                ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<TeamBloc>(create: (c) => allBlocs.teamBloc),
                    BlocProvider<GameBloc>(create: (c) => allBlocs.gameBloc),
                    BlocProvider<SeasonBloc>(
                        create: (c) => allBlocs.seasonBloc),
                    BlocProvider<ClubBloc>(create: (c) => allBlocs.clubBloc),
                    BlocProvider<CoordinationBloc>(
                        create: (c) => allBlocs.coordinationBloc),
                    BlocProvider<AuthenticationBloc>(
                        create: (c) => allBlocs.authBloc),
                    BlocProvider<MessagesBloc>(
                        create: (c) => allBlocs.messagesBloc),
                    BlocProvider<LoadedStateBloc>(
                        create: (c) => allBlocs.loadedStateBloc),
                    BlocProvider<InviteBloc>(
                        create: (c) => allBlocs.inviteBloc),
                    BlocProvider<FilteredGameBloc>(
                        create: (c) => FilteredGameBloc(
                            gameBloc: allBlocs.gameBloc,
                            teamBloc: allBlocs.teamBloc,
                            seasonBloc: allBlocs.seasonBloc))
                  ],
                  child: HomeScreen(laLoc),
                ),
              ),
            );

            print('Pump');
            await tester.pumpWidget(
              testWidget,
            );

            await allBlocs.loadedStateBloc.emit(LoadedState.AllLoaded);

            //await tester.pumpWidget(testWidget);
            await tester.pump(Duration(milliseconds: 600));
            print('Second pump');

            expect(find.text('Team Fuse'), findsOneWidget);

            if (Platform.environment['GOLDEN'] != null) {
              print('Golden!');
              await expectLater(find.byType(HomeScreen),
                  matchesGoldenFile('../../golden/home_uninitialized.png'));
            }
            await tester.pump(Duration(milliseconds: 600));

            print('Fluff');

            await allBlocs.close();
          }),
      variant: TeamsFuseTestVariant());
}
