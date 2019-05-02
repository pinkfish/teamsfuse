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

  /*
  void acceptInvite() {
    UserDatabaseData.instance.updateModel
        .addAdmin(teamUid, UserDatabaseData.instance.userUid);
  }
  */

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
/*
  @override
  String toString() {
    return 'InviteAsAdmin{${super.toString()}, teamName: $teamName, teamUid: $teamUid}';
  }

  @override
  int compareTo(Invite other) {
    if (baseCompareTo(other) != 0) {
      return -1;
    }
    if (other is InviteAsAdmin) {
      if (teamName.compareTo(other.teamName) != 0) {
        return -1;
      }
      if (teamUid.compareTo(other.teamUid) != 0) {
        return -1;
      }
      return 0;
    }
    return 1;
  }
  */
}
