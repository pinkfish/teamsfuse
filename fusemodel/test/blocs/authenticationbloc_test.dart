import 'dart:async';

import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockUserAuthImpl extends Mock implements UserAuthImpl {}

class MockAnalyticsSubsystem extends Mock implements AnalyticsSubsystem {}

void main() {
  AuthenticationBloc authenticationBloc;
  MockUserAuthImpl userAuth;
  MockAnalyticsSubsystem analyticsSubsystem;
  StreamController<UserData> _streamController;

  setUp(() {
    userAuth = MockUserAuthImpl();
    analyticsSubsystem = MockAnalyticsSubsystem();
    _streamController = new StreamController<UserData>();
    when(userAuth.onAuthChanged()).thenAnswer((_) => _streamController.stream);
    when(analyticsSubsystem.debugMode).thenReturn(true);
    authenticationBloc = AuthenticationBloc(
        userAuth: userAuth, analyticsSubsystem: analyticsSubsystem);
  });

  tearDown(() {
    _streamController.close();
  });

  test('initial state is correct', () {
    expect(authenticationBloc.state, AuthenticationUninitialized());
  });

  test('dispose does not emit new states', () {
    expectLater(
      authenticationBloc.state,
      emitsInOrder([]),
    );
    authenticationBloc.close();
  });

  group('AppStarted', () {
    test('emits [uninitialized, unauthenticated] for invalid token', () {
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoggedOut()
      ];

      when(userAuth.onAuthChanged())
          .thenAnswer((_) => _streamController.stream);

      when(userAuth.currentUser()).thenAnswer((_) => null);

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationAppStarted());
    });

    test('emits [uninitialized, authenticated] for real data', () {
      final UserData userData = new UserData((b) => b
        ..email = "frog@frog.com"
        ..uid = "ububng"
        ..isEmailVerified = true);
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoggedIn(user: userData)
      ];

      when(userAuth.onAuthChanged())
          .thenAnswer((_) => _streamController.stream);

      when(userAuth.currentUser()).thenAnswer((_) => Future.value(userData));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationAppStarted());
    });
  });
}
