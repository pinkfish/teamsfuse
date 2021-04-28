import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/blocs/playerbloc.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../util/testable.dart';
import '../util/widgetvariant.dart';

void main() {
  testWidgets('uninitialized', (tester) async {
    final playerData = StreamController<Player>();
    final blocs = AllBlocs();

    // Nothing in the queue, so uninitialized
    when(blocs.mockDb.getPlayerDetails('123'))
        .thenAnswer((p) => playerData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      await makeTestableWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => blocs.mockDb,
            ),
            RepositoryProvider<AnalyticsSubsystemImpl>(
              create: (c) => blocs.mockAnalytics,
            ),
            RepositoryProvider<PlayerBloc>(
              create: (c) => blocs.playerBloc,
            ),
          ],
          child: PlayerName(playerUid: '123'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Loading...'), findsOneWidget);
  }, variant: TeamsFuseTestVariant());

  testWidgets('name set', (tester) async {
    final gameData = StreamController<Player>();
    final blocs = AllBlocs();

    AsyncHydratedStorage.storageDirectory = Directory('fail');

    // Stub the state stream
    //singlePlayerBloc.emit(SinglePlayerUninitialized());
    when(blocs.mockDb.getPlayerDetails('123'))
        .thenAnswer((p) => gameData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      await makeTestableWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => blocs.mockDb,
            ),
            RepositoryProvider<AnalyticsSubsystemImpl>(
              create: (c) => blocs.mockAnalytics,
            ),
            RepositoryProvider<PlayerBloc>(
              create: (c) => blocs.playerBloc,
            ),
          ],
          child: RepaintBoundary(
            child: PlayerName(
              playerUid: '123',
              style: TextStyle(
                  fontFamily: 'Roboto', fontSize: 12.0, color: Colors.black),
            ),
          ),
        ),
      ),
    );
    gameData.add(Player((b) => b
      ..name = 'Frog'
      ..uid = '123'));

    await tester.pumpAndSettle();

    await expectLater(find.text('Frog (Invited)'), findsOneWidget);

    if (Platform.environment['GOLDEN'] != null) {
      await expectLater(find.byType(PlayerName),
          matchesGoldenFile('../golden/player_name_set.png'));
    }
  }, variant: TeamsFuseTestVariant());

  testWidgets('name change', (tester) async {
    final gameData = StreamController<Player>();
    final blocs = AllBlocs();

    // Stub the state stream
    when(blocs.mockDb.getPlayerDetails('123'))
        .thenAnswer((p) => gameData.stream);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      await makeTestableWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<DatabaseUpdateModel>(
              create: (c) => blocs.mockDb,
            ),
            RepositoryProvider<AnalyticsSubsystemImpl>(
              create: (c) => blocs.mockAnalytics,
            ),
            RepositoryProvider<PlayerBloc>(
              create: (c) => blocs.playerBloc,
            ),
          ],
          child: RepaintBoundary(
            child: PlayerName(
              playerUid: '123',
              style: TextStyle(
                  fontFamily: 'Roboto', fontSize: 12.0, color: Colors.white),
            ),
          ),
        ),
      ),
    );
    gameData.add(Player((b) => b
      ..name = 'Frog'
      ..uid = '123'
      ..usersData['1232'] = PlayerUserInternal((b) => b
        ..added = true
        ..relationship = Relationship.Parent)));

    await tester.pumpAndSettle();

    await expectLater(find.text('Frog'), findsOneWidget);

    gameData.add(Player((b) => b
      ..name = 'Bluey'
      ..uid = '123'));

    await tester.pumpAndSettle();

    await expectLater(find.text('Bluey (Invited)'), findsOneWidget);
  }, variant: TeamsFuseTestVariant());
}
