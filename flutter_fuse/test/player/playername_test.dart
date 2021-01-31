import 'package:flutter_fuse/widgets/player/playername.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Gender icon male', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(PlayerName(playerUid: "123"));
  });
}
