import 'package:built_value/built_value.dart';

import '../common.dart';
import 'invite.dart';

part 'invitetoclub.g.dart';

///
/// Invited to a club.
///
abstract class InviteToClub
    implements Invite, Built<InviteToClub, InviteToClubBuilder> {
  String get clubName;
  String get clubUid;
  bool get admin;

  /// The type of the invite.
  @override
  InviteType getType() => InviteType.Club;

  factory InviteToClub([void Function(InviteToClubBuilder) updates]) =
      _$InviteToClub;
  InviteToClub._();

/*
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
        */

  static const String CLUBUID = 'clubUid';
  static const String CLUBNAME = 'clubName';
  static const String ADMIN = 'admin';

  /*
  Future<void> acceptInvite() {
    return UserDatabaseData.instance.updateModel
        .addUserToClub(clubUid, UserDatabaseData.instance.userUid, admin);
  }
  */

  static InviteToClubBuilder fromJSON(String uid, Map<String, dynamic> data) {
    InviteToClubBuilder b = InviteToClubBuilder();
    Invite.fromJSON(b, uid, data);
    return b
      ..clubUid = getString(data[CLUBUID])
      ..clubName = getString(data[CLUBNAME])
      ..admin = getBool(data[ADMIN]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = Invite.toJSONInternal(this);
    ret[CLUBNAME] = clubName;
    ret[CLUBUID] = clubUid;
    ret[ADMIN] = admin;
    return ret;
  }

  /*
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
  */
}
