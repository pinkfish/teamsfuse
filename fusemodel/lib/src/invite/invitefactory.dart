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
        InviteToPlayer ret = InviteToPlayer.fromJSON(uid, data).build();
        return ret;
      case InviteType.Team:
        InviteToTeam ret = InviteToTeam.fromJSON(uid, data).build();
        return ret;
      case InviteType.Admin:
        InviteAsAdmin ret = InviteAsAdmin.fromJSON(uid, data).build();
        return ret;
      case InviteType.Club:
        InviteToClub ret = InviteToClub.fromJSON(uid, data).build();
        return ret;
      case InviteType.LeagueAdmin:
        InviteToLeagueAsAdmin ret =
            InviteToLeagueAsAdmin.fromJSON(uid, data).build();
        return ret;
      case InviteType.LeagueTeam:
        InviteToLeagueTeam ret = InviteToLeagueTeam.fromJSON(uid, data).build();
        return ret;
      default:
        throw new FormatException();
    }
  }
}
