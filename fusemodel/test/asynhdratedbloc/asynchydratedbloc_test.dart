import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asyncstorage.dart';
import 'package:mockito/mockito.dart';

class MockAsyncStorage extends Mock implements AsyncStorage {}

void main() {
  MockAsyncStorage mockAsyncStorage;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockAsyncStorage = MockAsyncStorage();
    AsyncHydratedStorage.storageDirectory = Directory.systemTemp;
  });

  tearDown(() {});

  test('serialize/deserialize', () async {
    var completer = Completer<Map<String, dynamic>>();
    var fluff = Completer<void>();

    when(mockAsyncStorage.read('TestAsyncHydratedBloc}'))
        .thenAnswer((realInvocation) => completer.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'red'}))
        .thenAnswer((realInvocation) => fluff.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'rabbit'}))
        .thenAnswer((realInvocation) => fluff.future);

    var asyncStuff = TestAsyncHydratedBloc("frogbucket", mockAsyncStorage);
    expectLater(
      asyncStuff,
      emitsInOrder(["red", "rabbit"]),
    );

    completer.complete({'data': "red"});
    fluff.complete(null);
    asyncStuff.add(TestEvent.Rabbit);
  });

  test('update first', () async {
    var completer = Completer<Map<String, dynamic>>();
    var fluff = Completer<void>();

    when(mockAsyncStorage.read('TestAsyncHydratedBloc}'))
        .thenAnswer((realInvocation) => completer.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'yellow'}))
        .thenAnswer((realInvocation) => fluff.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'rabbit'}))
        .thenAnswer((realInvocation) => fluff.future);

    var asyncStuff = TestAsyncHydratedBloc("frogbucket", mockAsyncStorage);
    asyncStuff.add(TestEvent.Frog);
    expectLater(
      asyncStuff,
      emitsInOrder(["yellow", "rabbit"]),
    );
    await asyncStuff.first;

    completer.complete({'data': "red"});
    fluff.complete(null);
    asyncStuff.add(TestEvent.Rabbit);
  });
}

enum TestEvent { Frog, Rabbit }

///
/// For testing the async stuff.
///
class TestAsyncHydratedBloc extends AsyncHydratedBloc<TestEvent, String> {
  TestAsyncHydratedBloc(String boxName, AsyncStorage asyncStorage)
      : super("", boxName, asyncStorage: asyncStorage);

  @override
  String fromJson(Map<String, dynamic> json) {
    return json['data'];
  }

  @override
  Stream<String> mapEventToState(TestEvent event) async* {
    if (event == TestEvent.Frog) {
      yield "yellow";
    }
    if (event == TestEvent.Rabbit) {
      yield "rabbit";
    }
  }

  @override
  Map<String, dynamic> toJson(String state) {
    return {'data': state};
  }
}
