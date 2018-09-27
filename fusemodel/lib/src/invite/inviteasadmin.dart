
import 'dart:async';
import '../common.dart';
import '../userdatabasedata.dart';
import 'invite.dart';

///
/// Invited as an admin to the team.
///
class InviteAsAdmin extends Invite {
  final String teamName;
  final String teamUid;

  InviteAsAdmin(
      {String sentByUid, String email, String uid, this.teamUid, this.teamName})
      : super(
      email: email,
      uid: uid,
      type: InviteType.Admin,
      sentByUid: sentByUid);

  InviteAsAdmin.copy(InviteAsAdmin invite)
      : teamName = invite.teamName,
        teamUid = invite.teamUid,
        super.copy(invite);

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';

  void acceptInvite() {
    UserDatabaseData.instance.updateModel
        .addAdmin(teamUid, UserDatabaseData.instance.userUid);
  }

  InviteAsAdmin.fromJSON(String uid, Map<String, dynamic> data)
      : teamUid = getString(data[TEAMUID]),
        teamName = getString(data[TEAMNAME]),
        super.fromJSON(uid, data);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[TEAMUID] = teamUid;
    ret[TEAMNAME] = teamName;
    return ret;
  }

  @override
  String toString() {
    return 'InviteAsAdmin{${super.toString()}, teamName: $teamName, teamUid: $teamUid}';
  }
}