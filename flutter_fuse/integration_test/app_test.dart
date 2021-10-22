// This is a basic Flutter integration test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/teams/teamanimatedlist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_fuse/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
  final forgotButton = find.byKey(Key('FORGOTPASSWORD'));

  Future<void> pumpFor(Duration maxDuration, WidgetTester tester,
      {Duration interval = const Duration(milliseconds: 16)}) {
    var elapsed = Duration.zero;
    return TestAsyncUtils.guard<void>(() async {
      while (elapsed < maxDuration) {
        await tester.pump(interval);
        elapsed += interval;
      }
    });
  }

  testWidgets('splash screen', (WidgetTester tester) async {
    // Build the app.
    app.mainInner(false);

    //await tester.pumpAndSettle(Duration(seconds: 1));
    await pumpFor(Duration(seconds: 1), tester);
    //dumpWidgetTree();
    print(forgotButton.evaluate());
    expect(forgotButton, findsOneWidget);
  });

  group('Flutter fuse app', () {
    final createAccountButton = find.byKey(Key('CREATEACCOUNT'));
    final submitButton = find.byKey(Key('SUBMIT'));
    final addTeamButton = find.byKey(Key('ADD_TEAM'));
    final userNameBox = find.byKey(Key('EMAIL'));
    final passwordBox = find.byKey(Key('PASSWORD'));

    Future<void> doLogin(WidgetTester driver) async {
      final testEmail = String.fromEnvironment('TEST_USER');
      final testPassword = String.fromEnvironment('TEST_PASSWORD');

      // Build the app.
      app.mainInner(false);

      // Do the login.  Assumes we are on the login page.
      await pumpFor(Duration(seconds: 1), driver);

      await driver.enterText(userNameBox, testEmail);
      await driver.enterText(passwordBox, testPassword);
      await driver.tap(submitButton);

      await driver.pump(Duration(seconds: 1));
    }

    // Verify you can move between the login pages.
    testWidgets('Login page', (WidgetTester driver) async {
      // Build the app.
      app.mainInner(false);

      await driver.pumpAndSettle(Duration(seconds: 1));
      expect(forgotButton, findsOneWidget);
      expect(createAccountButton, findsOneWidget);
      await driver.tap(forgotButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(submitButton, findsOneWidget);
      expect(createAccountButton, findsOneWidget);
      await driver.tap(createAccountButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(submitButton, findsOneWidget);
      expect(forgotButton, findsOneWidget);
      await driver.tap(submitButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(createAccountButton, findsOneWidget);
      expect(forgotButton, findsOneWidget);
    });

    testWidgets('Login', (WidgetTester driver) async {
      await doLogin(driver);

      // FInd the fused drawer.
      expect(find.byType(FusedDrawer), findsOneWidget);
    });

    testWidgets('All Teams Page', (WidgetTester driver) async {
      await doLogin(driver);
      // FInd the fused drawer.
      expect(find.byType(FusedDrawer), findsOneWidget);
      await driver.tap(find.byTooltip('ALL TEAMS'));

      await driver.pumpAndSettle(Duration(seconds: 1));
      expect(find.byType(TeamAnimatedList), findsOneWidget);
    });

    testWidgets('Add Team, delete team', (WidgetTester driver) async {
      await doLogin(driver);
      // FInd the fused drawer.
      expect(find.byType(FusedDrawer), findsOneWidget);

      await driver.tap(find.byTooltip('ALL TEAMS'));
      expect(addTeamButton, findsOneWidget);
      await driver.tap(addTeamButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      // Now in the add team form.
      // PLayer page
      await driver.tap(find.byKey(Key('PLAYER')));
      await driver.tap(find.text('Rowen Bennett'));

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(find.text('Rowen Bennett'), findsOneWidget);
      await driver.tap(find.byKey(Key('CONTINUE')));

      // Team page
      await driver.enterText(find.byTooltip('Name'), 'Woggles');
      await driver.enterText(
          find.byTooltip('Current team season'), 'Spring 2021');
      await driver.tap(find.byKey(Key('SPORT')));
      await driver.tap(find.text('Basketball'));
      expect(find.text('Basketball'), findsOneWidget);
      await driver.tap(find.byKey(Key('CONTINUE')));
      await driver.pumpAndSettle(Duration(seconds: 1));

      // Section details.
      await driver.tap(find.byKey(Key('CONTINUE')));
      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(find.byType(TeamAnimatedList), findsOneWidget);
    });
  });
}
