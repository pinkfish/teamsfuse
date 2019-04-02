import 'dart:async';
import '../common.dart';
import '../userdatabasedata.dart';
import 'invite.dart';

///
/// Invited to a club.
///
class InviteToClub extends Invite {
  final String clubName;
  final String clubUid;
  final bool admin;

  InviteToClub(
      {String sentByUid,
      String email,
      String uid,
      this.clubUid,
      this.clubName,
      this.admin})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Club,
            sentByUid: sentByUid);

  InviteToClub.copy(InviteToClub invite)
      : clubName = invite.clubName,
        clubUid = invite.clubUid,
        admin = invite.admin,
        super.copy(invite);

  static const String CLUBUID = 'clubUid';
  static const String CLUBNAME = 'clubName';
  static const String ADMIN = 'admin';

  Future<void> acceptInvite() {
    return UserDatabaseData.instance.updateModel
        .addUserToClub(clubUid, UserDatabaseData.instance.userUid, admin);
  }

  InviteToClub.fromJSON(String uid, Map<String, dynamic> data)
      : clubUid = getString(data[CLUBUID]),
        clubName = getString(data[CLUBNAME]),
        admin = getBool(data[ADMIN]),
        super.fromJSON(uid, data);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[CLUBNAME] = clubName;
    ret[CLUBUID] = clubUid;
    ret[ADMIN] = admin;
    return ret;
  }

  @override
  int compareTo(Invite other) {
    if (baseCompareTo(other) != 0) {
      return -1;
    }
    if (other is InviteToClub) {
      if (clubName.compareTo(other.clubName) != 0) {
        return -1;
      }
      if (clubUid.compareTo(other.clubUid) != 0) {
        return -1;
      }
      if (admin != other.admin) {
        return 1;
      }
      return 0;
    }
    return 1;
  }
}
