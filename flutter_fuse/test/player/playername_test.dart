import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/blocs.dart';

class MockSinglePlayerBloc extends MockBloc<int> implements SinglePlayerBloc {}

void main() {
  testWidgets('Gender icon male', (tester) async {
    var mock = MockSinglePlayerBloc();
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      BlocProvider<SinglePlayerBloc>(
        create: (c) => mock,
        child: PlayerName(playerUid: "123"),
      ),
    );

    expect(find.text("Loading"), findsOneWidget);

    mock.
  });
}
