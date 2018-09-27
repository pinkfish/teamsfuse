import 'dart:async';
import '../common.dart';
import '../userdatabasedata.dart';

enum InviteType { Player, Team, Admin, Club, LeagueAdmin, LeagueTeam }

///
/// Base class for all invites.
///
abstract class Invite {
  /// email invites.
  String email;

  /// uid of the invite itself
  String uid;

  /// The type of the invite.
  final InviteType type;

  // Who sent the invite.
  final String sentByUid;

  static const String EMAIL = 'email';
  static const String TYPE = 'type';
  static const String SENTBYUID = 'sentbyUid';

  Invite({this.uid, this.email, this.type, this.sentByUid});

  Invite.copy(Invite invite)
      : email = invite.email,
        uid = invite.uid,
        sentByUid = invite.sentByUid,
        type = invite.type;

  Invite.fromJSON(String myUid, Map<String, dynamic> data)
      : email = getString(data[EMAIL]),
        type = InviteType.values
            .firstWhere((InviteType ty) => ty.toString() == data[TYPE]),
        uid = myUid,
        sentByUid = getString(data[SENTBYUID]);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[EMAIL] = email;
    ret[TYPE] = type.toString();
    ret[SENTBYUID] = sentByUid;
    return ret;
  }

  Future<void> firestoreDelete() {
    return UserDatabaseData.instance.updateModel.firestoreInviteDelete(this);
  }

  @override
  String toString() {
    return 'Invite{email: $email, uid: $uid, type: $type, sentByUid: $sentByUid}';
  }
}

