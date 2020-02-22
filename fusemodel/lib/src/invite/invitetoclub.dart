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

  static const String CLUBUID = 'clubUid';
  static const String CLUBNAME = 'clubName';
  static const String ADMIN = 'admin';

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
}
