import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

class MockSinglePlayerBloc extends MockBloc<int> implements SinglePlayerBloc {}

void main() {
  testWidgets('Gender icon male', (tester) async {
    var singlePlayeBloc = MockSinglePlayerBloc();

    // Stub the state stream
    when(singlePlayeBloc.state).thenReturn(
      SinglePlayerUninitialized(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      BlocProvider<SinglePlayerBloc>(
        create: (c) => singlePlayeBloc,
        child: PlayerName(playerUid: "123"),
      ),
    );

    expect(find.text("Loading"), findsOneWidget);

    singlePlayeBloc.add((SinglePlayerLoadedBuilder()
          ..type = SinglePlayerBlocStateType.Loaded
          ..player = (PlayerBuilder()
            ..name = "Frog"
            ..uid = "123"))
        .build());

    expectLater(find.text("Frog"), findsOneWidget);
  });
}
