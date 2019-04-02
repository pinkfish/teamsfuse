import 'dart:async';

import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockUserAuthImpl extends Mock implements UserAuthImpl {}

void main() {
  AuthenticationBloc authenticationBloc;
  MockUserAuthImpl userAuth;
  StreamController<UserData> _streamController;

  setUp(() {
    userAuth = MockUserAuthImpl();
    _streamController = new StreamController<UserData>();
    authenticationBloc = AuthenticationBloc(userAuth: userAuth);
  });

  test('initial state is correct', () {
    expect(authenticationBloc.initialState, AuthenticationUninitialized());
  });

  test('dispose does not emit new states', () {
    expectLater(
      authenticationBloc.state,
      emitsInOrder([]),
    );
    authenticationBloc.dispose();
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

      authenticationBloc.dispatch(AppStarted());
    });

    test('emits [uninitialized, authenticated] for real data', () {
      final UserData userData = new UserData(
          email: "frog@frog.com", uid: "ububng", isEmailVerified: true);
      final expectedResponse = [
        AuthenticationUninitialized(),
        AuthenticationLoading(),
        AuthenticationLoggedIn(user: userData)
      ];

      when(userAuth.onAuthChanged())
          .thenAnswer((_) => _streamController.stream);

      when(userAuth.currentUser()).thenAnswer((_) => Future.value(userData));

      expectLater(
        authenticationBloc.state,
        emitsInOrder(expectedResponse),
      );

      authenticationBloc.dispatch(AppStarted());
    });
  });
}
