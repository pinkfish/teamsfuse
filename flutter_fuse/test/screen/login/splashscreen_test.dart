import 'dart:async';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/login/splashscreen.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';

import '../../util/testable.dart';
import '../../util/widgetvariant.dart';

void main() {
  testWidgets('logged out', (tester) async {
    var loginForm = _SplashScreenTest(tester);
    await loginForm.setup();
    // Logged out.
    loginForm.userController.add(null);
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));

    await tester.binding.delayed(Duration(milliseconds: 50));

    // Verify the router is pushed with the logout route.
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Login/Home')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('logged in', (tester) async {
    var loginForm = _SplashScreenTest(tester);
    await loginForm.setup();
    when(loginForm.mockFirebaseDyanmicLinks.getInitialLink())
        .thenAnswer((realInvocation) => null);
    // Logged in verified.
    loginForm.userController.add(UserData((b) => b
      ..email = 'frog@frog.com'
      ..isEmailVerified = true
      ..password = ''
      ..uid = '1234'));

    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.binding.delayed(Duration(milliseconds: 50));

    // Verify the router is pushed with the logout route.
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Main/Home')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('logged in - unverified', (tester) async {
    var loginForm = _SplashScreenTest(tester);
    await loginForm.setup();
    when(loginForm.mockFirebaseDyanmicLinks.getInitialLink())
        .thenAnswer((realInvocation) => null);
    // Logged in verified.
    loginForm.userController.add(UserData((b) => b
      ..email = 'frog@frog.com'
      ..isEmailVerified = false
      ..password = ''
      ..uid = '1234'));

    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.pump(Duration(milliseconds: 600));
    await tester.binding.delayed(Duration(milliseconds: 50));

    // Verify the router is pushed with the logout route.
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Login/Verify')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('logged in - with link', (tester) async {
    var loginForm = _SplashScreenTest(tester);
    await loginForm.setup();
    final pending = MockPendingDynamicLinkData();
    when(pending.link).thenReturn(
        Uri(scheme: 'https', host: 'womble.com', path: '/Womble/Rabbit'));
    when(loginForm.mockFirebaseDyanmicLinks.getInitialLink())
        .thenAnswer((realInvocation) => Future.value(pending));
    // Logged in verified.
    loginForm.userController.add(UserData((b) => b
      ..email = 'frog@frog.com'
      ..isEmailVerified = true
      ..password = ''
      ..uid = '1234'));

    await tester.pump(Duration(milliseconds: 600));
    await tester.binding.delayed(Duration(milliseconds: 50));
    await tester.binding.delayed(Duration(milliseconds: 600));

    // Verify the router is pushed with the logout route.
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Main/Home')), any));
    verify(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Womble/Rabbit')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());

  testWidgets('logged in - with link already', (tester) async {
    var loginForm = _SplashScreenTest(tester);
    await loginForm.setup();
    final pending = MockPendingDynamicLinkData();
    when(pending.link).thenReturn(
        Uri(scheme: 'https', host: 'womble.com', path: '/Womble/Rabbit'));
    when(loginForm.mockFirebaseDyanmicLinks.getInitialLink())
        .thenAnswer((realInvocation) => Future.value(pending));
    // Logged in verified.
    loginForm.userController.add(UserData((b) => b
      ..email = 'frog@frog.com'
      ..isEmailVerified = true
      ..password = ''
      ..uid = '1234'));

    when(loginForm.mockAnalytics.getUserId()).thenReturn('1234');

    await tester.pump(Duration(milliseconds: 600));
    await tester.binding.delayed(Duration(milliseconds: 50));
    await tester.binding.delayed(Duration(milliseconds: 600));

    verifyNever(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Main/Home')), any));
    verifyNever(loginForm.mockObserver
        .didPush(argThat(HasRouteName('/Womble/Rabbit')), any));

    loginForm.dispose();
  }, variant: TeamsFuseTestVariant());
}

class _SplashScreenTest {
  final WidgetTester tester;

  _SplashScreenTest(this.tester);

  final mockObserver = MockNavigatorObserver();

  final mockAnalytics = MockAnalyticsSubsystem();
  final mockUserAuth = MockUserAuth();
  final userController = StreamController<UserData>();
  final mockFirebaseAnalytics = MockFirebaseAnalytics();
  final mockFirebaseDyanmicLinks = MockFirebaseDynamicLinks();
  final mockNotifications = MockNotifications();
  AuthenticationBloc authBloc;
  Widget testWidget;
  final screen = SplashScreen();

  Future<void> setup() async {
    setupBlocObserver();
    when(mockUserAuth.onAuthChanged()).thenAnswer((_) => userController.stream);
    when(mockAnalytics.debugMode).thenReturn(false);
    when(mockAnalytics.firebase).thenReturn(mockFirebaseAnalytics);
    when(mockFirebaseAnalytics.setUserProperty(
            name: 'developer', value: 'false'))
        .thenAnswer((realInvocation) => null);
    authBloc = AuthenticationBloc(mockUserAuth, mockAnalytics);

    AsyncHydratedStorage.storageDirectory = Directory('fail');

    // Build our app and trigger a frame.
    testWidget = await makeTestableWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AnalyticsSubsystemImpl>(
              create: (c) => mockAnalytics),
          RepositoryProvider<FirebaseDynamicLinks>(
            create: (c) => mockFirebaseDyanmicLinks,
          ),
          RepositoryProvider<Notifications>(
            create: (c) => mockNotifications,
          ),
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
