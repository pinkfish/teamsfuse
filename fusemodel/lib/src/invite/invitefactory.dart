import '../serializer.dart';
import 'invite.dart';
import 'inviteasadmin.dart';
import 'invitetoclub.dart';
import 'invitetoleagueasadmin.dart';
import 'invitetoleagueteam.dart';
import 'invitetoplayer.dart';

///
/// Base class for all invites.
///
class InviteFactory {
  static Invite makeInviteFromJSON(String uid, Map<String, dynamic> data) {
    assert(uid != null);
    var type = InviteType.primitiveSerializer
        .deserialize(dataSerializers, data[Invite.typeField]);

    switch (type) {
      case InviteType.Player:
        var ret = InviteToPlayer.fromMap(data);
        return ret;
      case InviteType.Admin:
        var ret = InviteAsAdmin.fromMap(data);
        return ret;
      case InviteType.Club:
        var ret = InviteToClub.fromMap(data);
        return ret;
      case InviteType.LeagueAdmin:
        var ret = InviteToLeagueAsAdmin.fromMap(data);
        return ret;
      case InviteType.LeagueTeam:
        var ret = InviteToLeagueTeam.fromMap(data);
        return ret;
      default:
        throw FormatException();
    }
  }
}
