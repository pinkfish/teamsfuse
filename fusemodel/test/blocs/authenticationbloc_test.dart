import 'dart:async';

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
    _streamController = StreamController<UserData>();
    when(userAuth.onAuthChanged()).thenAnswer((_) => _streamController.stream);
    when(analyticsSubsystem.debugMode).thenReturn(true);
    authenticationBloc = AuthenticationBloc(userAuth, analyticsSubsystem);
  });

  tearDown(() {
    _streamController.close();
  });

  test('initial state is correct', () {
    expect(authenticationBloc.state, AuthenticationUninitialized());
  });

  test('dispose does not emit new states', () {
    expectLater(
      authenticationBloc,
      emitsInOrder([]),
    );
    authenticationBloc.close();
  });

  group('AppStarted', () {
    test('emits [uninitialized, unauthenticated] for invalid token', () {
      final expectedResponse = [
        AuthenticationLoggedOut(),
      ];

      when(userAuth.onAuthChanged())
          .thenAnswer((_) => _streamController.stream);

      when(userAuth.currentUser()).thenAnswer((_) => null);

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationAppStarted());
    });

    test('emits [uninitialized, authenticated] for real data', () {
      var userData = UserData((b) => b
        ..email = 'frog@frog.com'
        ..uid = 'ububng'
        ..isEmailVerified = true);
      final expectedResponse = [AuthenticationLoggedIn(user: userData)];

      when(userAuth.onAuthChanged())
          .thenAnswer((_) => _streamController.stream);

      when(userAuth.currentUser()).thenAnswer((_) => Future.value(userData));

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.add(AuthenticationAppStarted());
    });
  });
}
