import 'package:built_value/built_value.dart';

import '../common.dart';
import 'invite.dart';

part 'inviteasadmin.g.dart';

///
/// Invited as an admin to the team.
///
abstract class InviteAsAdmin
    implements Invite, Built<InviteAsAdmin, InviteAsAdminBuilder> {
  String get teamName;
  String get teamUid;

  /// The type of the invite.
  @override
  InviteType getType() => InviteType.Admin;

  factory InviteAsAdmin([void Function(InviteAsAdminBuilder) updates]) =
      _$InviteAsAdmin;
  InviteAsAdmin._();

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';

  static InviteAsAdminBuilder fromJSON(String uid, Map<String, dynamic> data) {
    InviteAsAdminBuilder b = InviteAsAdminBuilder();
    Invite.fromJSON(b, uid, data);
    return b
      ..teamUid = getString(data[TEAMUID])
      ..teamName = getString(data[TEAMNAME]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = Invite.toJSONInternal(this);
    ret[TEAMUID] = teamUid;
    ret[TEAMNAME] = teamName;
    return ret;
  }
}
