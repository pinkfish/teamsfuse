// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:public_ux/screens/publichome.dart';

import '../util/testable.dart';

void main() {
  testWidgets('Home screen, show team', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final testWidget = await makeTestableWidget(PublicHomeScreen(""));

    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(milliseconds: 600));

    if (Platform.environment['GOLDEN'] != null) {
      print('Golden!');
      await expectLater(find.byType(PublicHomeScreen),
          matchesGoldenFile('../golden/home_uninitialized.png'));
    }

    expect(find.text('Team Fuse'), findsOneWidget);
  });
}
