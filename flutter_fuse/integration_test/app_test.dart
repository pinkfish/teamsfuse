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

  testWidgets('screenshot', (WidgetTester tester) async {
    // Build the app.
    app.main();

    // This is required prior to taking the screenshot (Android only).
    await binding.convertFlutterSurfaceToImage();

    // Trigger a frame.
    await tester.pumpAndSettle();
    await binding.takeScreenshot('screenshot-splash');
  });

  group('Flutter fuse app', () {
    final forgotButton = find.byKey(ValueKey('FORGOTPASSWORD'));
    final createAccountButton = find.byKey(ValueKey('CREATEACCOUNT'));
    final loginButton = find.byKey(ValueKey('LOGIN'));
    final addTeamButton = find.byKey(ValueKey('ADD_TEAM'));

    // Verify you can move between the login pages.
    testWidgets('Login page', (WidgetTester driver) async {
      await driver.pumpAndSettle(Duration(seconds: 1));
      expect(forgotButton, findsOneWidget);
      expect(createAccountButton, findsOneWidget);
      await driver.tap(forgotButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(loginButton, findsOneWidget);
      expect(createAccountButton, findsOneWidget);
      await driver.tap(createAccountButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(loginButton, findsOneWidget);
      expect(forgotButton, findsOneWidget);
      await driver.tap(loginButton);

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(createAccountButton, findsOneWidget);
      expect(forgotButton, findsOneWidget);
    });

    testWidgets('Login', (WidgetTester driver) async {
      await driver.pumpAndSettle(Duration(seconds: 1));
      await doLogin(driver);

      // FInd the fused drawer.
      expect(find.byType(FusedDrawer), findsOneWidget);
      await binding.takeScreenshot('screenshot-main');
    });

    testWidgets('All Teams Page', (WidgetTester driver) async {
      await driver.pumpAndSettle(Duration(seconds: 1));
      await doLogin(driver);
      // FInd the fused drawer.
      expect(find.byType(FusedDrawer), findsOneWidget);
      await driver.tap(find.byTooltip('ALL TEAMS'));

      await driver.pumpAndSettle(Duration(seconds: 1));
      expect(find.byType(TeamAnimatedList), findsOneWidget);
      await binding.takeScreenshot('screenshot-teams');
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
      await driver.tap(find.byKey(ValueKey('PLAYER')));
      await driver.tap(find.text('Rowen Bennett'));

      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(find.text('Rowen Bennett'), findsOneWidget);
      await driver.tap(find.byKey(ValueKey('CONTINUE')));

      // Team page
      await driver.enterText(find.byTooltip('Name'), 'Woggles');
      await driver.enterText(
          find.byTooltip('Current team season'), 'Spring 2021');
      await driver.tap(find.byKey(ValueKey('SPORT')));
      await driver.tap(find.text('Basketball'));
      expect(find.text('Basketball'), findsOneWidget);
      await driver.tap(find.byKey(ValueKey('CONTINUE')));
      await driver.pumpAndSettle(Duration(seconds: 1));

      // Section details.
      await driver.tap(find.byKey(ValueKey('CONTINUE')));
      await driver.pumpAndSettle(Duration(seconds: 1));

      expect(find.byType(TeamAnimatedList), findsOneWidget);
    });
  });
}

Future<void> doLogin(WidgetTester driver) async {
  final submitButton = find.byKey(ValueKey('SUBMIT'));
  final userNameBox = find.byTooltip('Your email address');
  final passwordBox = find.byTooltip('Password');
  final testEmail = String.fromEnvironment('TEST_USER');
  final testPassword = String.fromEnvironment('TEST_PASSWORD');

  // Do the login.  Assumes we are on the login page.
  await driver.pumpAndSettle(Duration(seconds: 1));

  await driver.tap(userNameBox);
  await driver.enterText(userNameBox, testEmail);
  await driver.tap(passwordBox);
  await driver.enterText(passwordBox, testPassword);
  await driver.tap(submitButton);

  await driver.pumpAndSettle(Duration(seconds: 1));
}
