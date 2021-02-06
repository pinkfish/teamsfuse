import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/blocs.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../util/testable.dart';

class MockSinglePlayerBloc extends MockBloc<int> implements SinglePlayerBloc {}

void main() {
  testWidgets('uninitialized', (tester) async {
    var singlePlayerBloc = MockSinglePlayerBloc();

    // Stub the state stream
    //singlePlayerBloc.emit(SinglePlayerUninitialized());
    when(singlePlayerBloc.state).thenReturn(
      SinglePlayerUninitialized(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        BlocProvider<SinglePlayerBloc>(
          create: (c) => singlePlayerBloc,
          child: PlayerName(playerUid: "123"),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Loading..."), findsOneWidget);
  });

  testWidgets('name set', (tester) async {
    var singlePlayerBloc = MockSinglePlayerBloc();

    // Stub the state stream
    //singlePlayerBloc.emit(SinglePlayerUninitialized());
    when(singlePlayerBloc.state).thenReturn(
      (SinglePlayerLoadedBuilder()
            ..type = SinglePlayerBlocStateType.Loaded
            ..player = (PlayerBuilder()
              ..name = "Frog"
              ..uid = "123"))
          .build(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      makeTestableWidget(
        BlocProvider<SinglePlayerBloc>(
          create: (c) => singlePlayerBloc,
          child: RepaintBoundary(
            child: PlayerName(playerUid: "123"),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(find.text("Frog"), findsOneWidget);

    //await expectLater(find.byType(PlayerName),
     //   matchesGoldenFile('golden/player_name_set.png'));
  });
}
