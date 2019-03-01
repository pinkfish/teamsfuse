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
    InviteType type = InviteType.values
        .firstWhere((InviteType ty) => ty.toString() == data[Invite.TYPE]);
    switch (type) {
      case InviteType.Player:
        InviteToPlayer ret = new InviteToPlayer.fromJSON(uid, data);
        return ret;
      case InviteType.Team:
        InviteToTeam ret = new InviteToTeam.fromJSON(uid, data);
        return ret;
      case InviteType.Admin:
        InviteAsAdmin ret = new InviteAsAdmin.fromJSON(uid, data);
        return ret;
      case InviteType.Club:
        InviteToClub ret = new InviteToClub.fromJSON(uid, data);
        return ret;
      case InviteType.LeagueAdmin:
        InviteToLeagueAsAdmin ret =
        new InviteToLeagueAsAdmin.fromJSON(uid, data);
        return ret;
      case InviteType.LeagueTeam:
        InviteToLeagueTeam ret = new InviteToLeagueTeam.fromJSON(uid, data);
        return ret;
      default:
        throw new FormatException();
    }
  }
}