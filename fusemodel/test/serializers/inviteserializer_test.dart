import 'package:fusemodel/fusemodel.dart';
import 'package:fusemodel/src/serializer.dart';
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

    Invite invite =
        serializers.deserializeWith(serializer, inviteAsAdmin.toMap());

    expect(invite.type, equals(InviteType.Admin));
  });
}
