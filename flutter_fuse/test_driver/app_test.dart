// This is a basic Flutter integration test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Flutter fuse app', () {
    final forgotButton = find.byValueKey("FORGOTPASSWORD");
    final createAccountButton = find.byValueKey("CREATEACCOUNT");
    final loginButton = find.byValueKey("LOGIN");
    final logoutButton = find.byValueKey("LOGOUT");
    final submitButton = find.byValueKey("SUBMIT");
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    // Verify you can move between the login pages.
    test('Login page', () async {
      await driver.waitFor(forgotButton);
      await driver.waitFor(createAccountButton);
      await driver.tap(forgotButton);

      await driver.waitFor(loginButton);
      await driver.waitFor(createAccountButton);
      await driver.tap(createAccountButton);

      await driver.waitFor(loginButton);
      await driver.waitFor(forgotButton);
      await driver.tap(loginButton);

      await driver.waitFor(forgotButton);
      await driver.waitFor(createAccountButton);
    });

    test('Login', () async {
      await doLogin(driver);
      // FInd the fused drawer.
      await driver.waitFor(find.byType("FusedDrawer"));
    });

    test('All Teams Page', () async {
      await doLogin(driver);
      // FInd the fused drawer.
      await driver.waitFor(find.byType("FusedDrawer"));
      await driver.tap(find.byTooltip("ALL TEAMS"));
      await driver.waitFor(find.byType("TeamAnimatedList"));
    });
  });
}

Future<void> doLogin(FlutterDriver driver) async {
  final submitButton = find.byValueKey("SUBMIT");
  final userNameBox = find.byTooltip("Your email address");
  final passwordBox = find.byTooltip("Password");
  final testEmail = String.fromEnvironment("TEST_USER");
  final testPassword = String.fromEnvironment("TEST_PASSWORD");

  // Do the login.  Assumes we are on the login page.
  await driver.tap(userNameBox);
  await driver.enterText(testEmail);
  await driver.tap(passwordBox);
  await driver.enterText(testPassword);
  await driver.tap(submitButton);
}
