import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/async_hydrated_bloc/asynchydratedbloc.dart';
import 'package:fusemodel/src/serializer/inviteserializer.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  tearDown(() {});

  test('serialize/deserialize', () {
    var inviteAsAdmin = (InviteAsAdminBuilder()
          ..uid = 'red'
          ..email = 'test@example.com'
          ..sentByUid = 'green'
          ..teamName = 'Red Herrings'
          ..teamUid = 'herring')
        .build();
    var serializer = InviteSerializer();
  });
}

enum TestEvent { Frog }

///
/// For testing the async stuff.
///
class TestAsyncHydratedBloc extends AsyncHydratedBloc<TestEvent, String> {
  TestAsyncHydratedBloc(String boxName) : super("", boxName);

  @override
  String fromJson(Map<String, dynamic> json) {
    return json['data'];
  }

  @override
  Stream<String> mapEventToState(TestEvent event) {}

  @override
  Map<String, dynamic> toJson(String state) {
    return {'data': state};
  }
}
