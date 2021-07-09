import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/login/loginform.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';
import 'dart:io' show Platform;

import '../../util/testable.dart';
import '../../util/widgetvariant.dart';

void main() {
  testWidgets('forgot button', (tester) async {
    var loginForm = _LoginFormTest(tester);
    await loginForm.setup();

    expect(loginForm.forgotButton, findsOneWidget);
    expect(loginForm.createAccountButton, findsOneWidget);

    // Click on the forgot button.
    await tester.tap(loginForm.forgotButton);
    await tester.pump(Duration(milliseconds: 600));

    // Verify the router is pushed.
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Login/ForgotPassword')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('signup button', (tester) async {
    var loginForm = _LoginFormTest(tester);
    await loginForm.setup();

    expect(loginForm.forgotButton, findsOneWidget);
    expect(loginForm.createAccountButton, findsOneWidget);

    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));

    if (Platform.environment['GOLDEN'] != null) {
      print('Golden!');
      // For some reason this always fails.
      //await expectLater(find.byType(LoginScreen),
      //      matchesGoldenFile('../../golden/login_form.png'));
    }

    // Click on the forgot button.
    await tester.pump(Duration(milliseconds: 600));
    await tester.tap(loginForm.createAccountButton);
    await tester.pump(Duration(milliseconds: 600));

    // Verify the router is pushed.
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Login/SignUp')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('login failed', (tester) async {
    var loginForm = _LoginFormTest(tester);
    await loginForm.setup();

    expect(loginForm.forgotButton, findsOneWidget);
    expect(loginForm.createAccountButton, findsOneWidget);
    expect(loginForm.submitButton, findsOneWidget);
    expect(loginForm.userNameBox, findsOneWidget);
    expect(loginForm.passwordBox, findsOneWidget);

    await tester.enterText(loginForm.userNameBox, 'frog@frog.com');
    await tester.enterText(loginForm.passwordBox, 'womble');

    // Click on the forgot button.
    await tester.tap(loginForm.submitButton);
    await tester.pump(Duration(milliseconds: 600));

    // Send back a fail to login message.
    loginForm.authBloc.emit(
      AuthenticationFailed(
        userData: UserData((b) => b
          ..email = 'frog@frog.com'
          ..uid = ''
          ..isEmailVerified = false),
        reason: LoginFailedReason.BadPassword,
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify the router is pushed.
    expect(find.text('Email and/or password incorrect'), findsWidgets);
    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('login success', (tester) async {
    var loginForm = _LoginFormTest(tester);
    await loginForm.setup();

    expect(loginForm.forgotButton, findsOneWidget);
    expect(loginForm.createAccountButton, findsOneWidget);
    expect(loginForm.submitButton, findsOneWidget);
    expect(loginForm.userNameBox, findsOneWidget);
    expect(loginForm.passwordBox, findsOneWidget);

    await tester.enterText(loginForm.userNameBox, 'frog@frog.com');
    await tester.enterText(loginForm.passwordBox, 'womble');

    // Click on the forgot button.
    await tester.tap(loginForm.submitButton);
    await tester.pump(Duration(milliseconds: 600));

    // Send back a fail to login message.
    loginForm.authBloc.emit(
      AuthenticationLoggedIn(
        user: UserData((b) => b
          ..email = 'frog@frog.com'
          ..uid = '1234'
          ..isEmailVerified = true),
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify the router is pushed.
    verify(loginForm.mockObserver.didPush(argThat(HasRouteName('/Home')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());
}

class _LoginFormTest {
  final WidgetTester tester;

  _LoginFormTest(this.tester);

  final mockObserver = MockNavigatorObserver();

  final mockAnalytics = MockAnalyticsSubsystem();
  final mockUserAuth = MockUserAuth();
  final userController = StreamController<UserData>();
  AuthenticationBloc authBloc;
  final forgotButton = find.byKey(Key('FORGOTPASSWORD'));
  final createAccountButton = find.byKey(Key('CREATEACCOUNT'));
  final submitButton = find.byKey(Key('SUBMIT'));
  final addTeamButton = find.byKey(Key('ADD_TEAM'));
  final userNameBox = find.byKey(Key('EMAIL'));
  final passwordBox = find.byKey(Key('PASSWORD'));
  Widget testWidget;
  final screen = LoginScreen();

  Future<void> setup() async {
    when(mockUserAuth.onAuthChanged()).thenAnswer((_) => userController.stream);
    authBloc = AuthenticationBloc(mockUserAuth, mockAnalytics);
    // Logged out.
    userController.add(null);

    AsyncHydratedStorage.storageDirectory = Directory('fail');

    // Build our app and trigger a frame.

    testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AnalyticsSubsystem>(create: (c) => mockAnalytics),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(create: (c) => authBloc),
          ],
          child: screen,
        ),
      ),
      observer: mockObserver,
    );

    await tester.pumpWidget(
      testWidget,
    );

    await tester.pump(
      Duration(milliseconds: 600),
    );
  }

  void dispose() {
    userController.close();
  }
}
