import '../serializer.dart';
import 'invite.dart';
import 'inviteasadmin.dart';
import 'invitetoclub.dart';
import 'invitetoleagueasadmin.dart';
import 'invitetoleagueteam.dart';
import 'invitetoplayer.dart';
import 'invitetoteam.dart';

///
/// Base class for all invites.
///
class InviteFactory {
  static Invite makeInviteFromJSON(String uid, Map<String, dynamic> data) {
    assert(uid != null);
    InviteType type = serializers.deserialize(data[Invite.TYPE]);
    switch (type) {
      case InviteType.Player:
        InviteToPlayer ret = InviteToPlayer.fromMap(data);
        return ret;
      case InviteType.Team:
        InviteToTeam ret = InviteToTeam.fromMap(data);
        return ret;
      case InviteType.Admin:
        InviteAsAdmin ret = InviteAsAdmin.fromMap(data);
        return ret;
      case InviteType.Club:
        InviteToClub ret = InviteToClub.fromMap(data);
        return ret;
      case InviteType.LeagueAdmin:
        InviteToLeagueAsAdmin ret = InviteToLeagueAsAdmin.fromMap(data);
        return ret;
      case InviteType.LeagueTeam:
        InviteToLeagueTeam ret = InviteToLeagueTeam.fromMap(data);
        return ret;
      default:
        throw new FormatException();
    }
  }
}
