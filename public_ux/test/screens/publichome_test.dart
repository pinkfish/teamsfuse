///
/// Widget tests for the public home screen.
///
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:public_ux/screens/publichome.dart';

import '../util/testable.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final testWidget = await makeTestableWidget(PublicHomeScreen(''));

    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(milliseconds: 600));

    expect(find.text('\u2022 Works offline with no internet'), findsOneWidget);
  });

  testWidgets('Home screen, tournaments', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final testWidget = await makeTestableWidget(
        PublicHomeScreen(PublicMainTab.tournament.name));

    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(milliseconds: 600));

    expect(find.text('\u2022 Team win records and ranking'), findsOneWidget);
  });

  testWidgets('Home screen, leagues', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final testWidget =
        await makeTestableWidget(PublicHomeScreen(PublicMainTab.league.name));

    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(milliseconds: 600));

    expect(find.text('\u2022 Team win records and ranking'), findsOneWidget);
  });

  testGoldens('Home screen, golden', (WidgetTester tester) async {
    if (Platform.environment['GOLDEN'] != null) {
      final testWidget =
          await makeTestableWidget(PublicHomeScreen(PublicMainTab.about.name));

      await tester.pumpWidgetBuilder(testWidget);
      await expectLater(find.byType(PublicHomeScreen),
          matchesGoldenFile('../golden/PublicHomeScreen.png'));
    }
  });
}
