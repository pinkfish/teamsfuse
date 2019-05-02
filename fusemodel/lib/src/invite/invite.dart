import 'package:built_value/built_value.dart';

import '../common.dart';

part 'invite.g.dart';

/// The type of the invite.
enum InviteType { Player, Team, Admin, Club, LeagueAdmin, LeagueTeam }

abstract class BaseInviteType {
  /// The type of the invite.
  InviteType getType();
}

///
/// Base class for all invites.
///
@BuiltValue(instantiable: false)
abstract class Invite with BaseInviteType {
  /// email invites.
  String get email;

  /// uid of the invite itself
  String get uid;

  // Who sent the invite.
  String get sentByUid;

  Invite rebuild(void Function(InviteBuilder) updates);
  InviteBuilder toBuilder();

  static const String EMAIL = 'email';
  static const String TYPE = 'type';
  static const String SENTBYUID = 'sentbyUid';

  static InviteBuilder fromJSON(
      InviteBuilder builder, String myUid, Map<String, dynamic> data) {
    return builder
      ..email = getString(data[EMAIL])
      ..uid = myUid
      ..sentByUid = getString(data[SENTBYUID]);
  }

  Map<String, dynamic> toJSON();

  static Map<String, dynamic> toJSONInternal(Invite invite) {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[EMAIL] = invite.email;
    ret[TYPE] = invite.getType().toString();
    ret[SENTBYUID] = invite.sentByUid;
    return ret;
  }

  /*
  Future<void> firestoreDelete() {
    return UserDatabaseData.instance.updateModel.firestoreInviteDelete(this);
  }

  @override
  String toString() {
    return 'Invite{email: $email, uid: $uid, type: $type, sentByUid: $sentByUid}';
  }

  int baseCompareTo(Invite other) {
    int ret = other.uid.compareTo(uid);
    if (ret != 0) {
      return ret;
    }
    ret = other.email.compareTo(email);
    if (ret != 0) {
      return ret;
    }
    if (type != other.type) {
      return -1;
    }
    if (sentByUid.compareTo(other.sentByUid) != 0) {
      return -1;
    }
    return 0;
  }
  */
}
