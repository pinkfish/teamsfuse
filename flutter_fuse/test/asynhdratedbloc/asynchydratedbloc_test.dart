import 'dart:async';
import 'dart:io';

import 'package:flutter_fuse/util/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:flutter_fuse/util/async_hydrated_bloc/asyncstorage.dart';
import 'package:flutter_test/flutter_test.dart';
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
    final completer = Completer<Map<String, dynamic>>();
    final fluff = Completer<void>();

    when(mockAsyncStorage.read('TestAsyncHydratedBloc}'))
        .thenAnswer((_) => completer.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'red'}))
        .thenAnswer((_) => fluff.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'rabbit'}))
        .thenAnswer((_) => fluff.future);

    final asyncStuff = TestAsyncHydratedBloc('frogbucket', mockAsyncStorage);
    expect(asyncStuff.state, '');
    completer.complete({'data': 'red'});
    await asyncStuff.loaded.future;
    expect(asyncStuff.state, 'red');
    asyncStuff.add(TestEvent.Rabbit);
    expect(asyncStuff.state, 'rabbit');
  });

  test('update first', () async {
    final completer = Completer<Map<String, dynamic>>();
    final fluff = Completer<void>();

    when(mockAsyncStorage.read('TestAsyncHydratedBloc}'))
        .thenAnswer((realInvocation) => completer.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'red'}))
        .thenAnswer((realInvocation) => fluff.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'yellow'}))
        .thenAnswer((realInvocation) => fluff.future);
    when(mockAsyncStorage.write('TestAsyncHydratedBloc}', {'data': 'rabbit'}))
        .thenAnswer((realInvocation) => fluff.future);

    final asyncStuff = TestAsyncHydratedBloc('frogbucket', mockAsyncStorage);
    expect(asyncStuff.state, '');
    asyncStuff.add(TestEvent.Frog);
    await asyncStuff.loaded.future;
    expect(asyncStuff.state, 'yellow');

    completer.complete({'data': 'red'});
    fluff.complete(null);
    asyncStuff.add(TestEvent.Rabbit);
    expect(asyncStuff.state, 'rabbit');
  });
}

enum TestEvent { Frog, Rabbit }

///
/// For testing the async stuff.
///
class TestAsyncHydratedBloc extends AsyncHydratedBloc<TestEvent, String> {
  final loaded = Completer<bool>();

  TestAsyncHydratedBloc(String boxName, AsyncStorage asyncStorage)
      : super('', boxName, asyncStorage: asyncStorage);

  @override
  String fromJson(Map<String, dynamic> json) {
    if (!loaded.isCompleted) {
      loaded.complete(true);
    }
    return json['data'];
  }

  @override
  Stream<String> mapEventToState(TestEvent event) async* {
    print('vent $event');
    if (!loaded.isCompleted) {
      loaded.complete(true);
    }
    if (event == TestEvent.Frog) {
      yield 'yellow';
    }
    if (event == TestEvent.Rabbit) {
      yield 'rabbit';
    }
    print('end $event');
  }

  @override
  Map<String, dynamic> toJson(String state) {
    return {'data': state};
  }
}
