import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';

import '../../util/loadfonts.dart';
import '../../util/testable.dart';
import '../../util/widgetvariant.dart';

class MockDatabaseUpdateModel extends Mock implements DatabaseUpdateModel {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserAuth extends Mock implements UserAuthImpl {}

class MockStorage extends Mock implements HydratedStorage {}

void main() {
  testWidgets(
      'uninitialized',
      (tester) async =>
          withClock(Clock.fixed(DateTime(2020, 09, 01)), () async {
            loadFonts();

            var mockDb = MockDatabaseUpdateModel();
            var mockAnalytics = MockAnalyticsSubsystem();
            var gameController = StreamController<Game>();
            var userController = StreamController<UserData>();

            // Fake out the storage so it doesn't load from anywhere or save anywhere.
            AsyncHydratedStorage.storageDirectory = Directory("fail");
            print("Make storage");
            var storage = MockStorage();
            HydratedBloc.storage = storage;
            when(storage.read(any)).thenReturn(<dynamic, dynamic>{});
            when(storage.write(any, any)).thenAnswer((_) => Future.value(null));

            when(mockDb.getGame("123"))
                .thenAnswer((_) => gameController.stream);

            // Build our app and trigger a frame.
            var mockUserAuth = MockUserAuth();
            when(mockUserAuth.onAuthChanged())
                .thenAnswer((_) => userController.stream);

            var authBloc = AuthenticationBloc(mockUserAuth, mockAnalytics);
            var coordinationBloc = CoordinationBloc(
              authenticationBloc: authBloc,
              analytics: mockAnalytics,
              databaseUpdateModel: mockDb,
            );
            var clubBloc = ClubBloc(
              coordinationBloc: coordinationBloc,
              crashes: mockAnalytics,
            );
            var teamBloc = TeamBloc(
              coordinationBloc: coordinationBloc,
              clubBloc: clubBloc,
              crashes: mockAnalytics,
            );
            var seasonBloc = SeasonBloc(
              coordinationBloc: coordinationBloc,
              crashes: mockAnalytics,
            );
            var gameBloc = GameBloc(
              coordinationBloc: coordinationBloc,
              teamBloc: teamBloc,
              crashes: mockAnalytics,
            );
            var messagesBloc = MessagesBloc(
              coordinationBloc: coordinationBloc,
              crashes: mockAnalytics,
            );
            var loadedStateBloc = LoadedStateBloc(
              coordinationBloc: coordinationBloc,
            );
            var inviteBloc = InviteBloc(
              coordinationBloc: coordinationBloc,
              crashes: mockAnalytics,
              databaseUpdateModel: mockDb,
            );
            print("widget make");
            var testWidget = await makeTestableWidget(
              MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<DatabaseUpdateModel>(
                      create: (c) => mockDb),
                  RepositoryProvider<AnalyticsSubsystem>(
                      create: (c) => mockAnalytics)
                ],
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<TeamBloc>(create: (c) => teamBloc),
                    BlocProvider<GameBloc>(create: (c) => gameBloc),
                    BlocProvider<SeasonBloc>(create: (c) => seasonBloc),
                    BlocProvider<ClubBloc>(create: (c) => clubBloc),
                    BlocProvider<CoordinationBloc>(
                        create: (c) => coordinationBloc),
                    BlocProvider<AuthenticationBloc>(create: (c) => authBloc),
                    BlocProvider<MessagesBloc>(create: (c) => messagesBloc),
                    BlocProvider<LoadedStateBloc>(
                        create: (c) => loadedStateBloc),
                    BlocProvider<InviteBloc>(create: (c) => inviteBloc),
                    BlocProvider<FilteredGameBloc>(
                        create: (c) => FilteredGameBloc(
                            gameBloc: gameBloc,
                            teamBloc: teamBloc,
                            seasonBloc: seasonBloc))
                  ],
                  child: HomeScreen(),
                ),
              ),
            );

            print("Pump");
            await tester.pumpWidget(
              testWidget,
            );

            loadedStateBloc.emit(LoadedState.AllLoaded);

            //await tester.pumpWidget(testWidget);
            await tester.pump(Duration(milliseconds: 600));
            print("Second pump");

            expect(find.text("Team Fuse"), findsOneWidget);

            if (Platform.environment["GOLDEN"] != null) {
              print("Golden!");
              await expectLater(find.byType(HomeScreen),
                  matchesGoldenFile('../../golden/home_uninitialized.png'));
            }
            await tester.pump(Duration(milliseconds: 600));

            print("Fluff");

            userController.close();
            gameController.close();
          }),
      variant: TeamsFuseTestVariant());
}
