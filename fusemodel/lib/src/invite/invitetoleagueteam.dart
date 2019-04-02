import 'dart:async';
import '../common.dart';
import '../userdatabasedata.dart';
import 'invite.dart';
import '../team.dart';

///
/// Invited to a league team.
///
class InviteToLeagueTeam extends Invite {
  final String leagueName;
  final String leagueTeamName;
  final String leagueTeamUid;
  final String leagueUid;
  final String leagueDivisonUid;
  final String leagueSeasonName;

  InviteToLeagueTeam(
      {String sentByUid,
      String email,
      String uid,
      this.leagueTeamUid,
      this.leagueDivisonUid,
      this.leagueTeamName,
      this.leagueSeasonName,
      this.leagueUid,
      this.leagueName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.LeagueTeam,
            sentByUid: sentByUid);

  InviteToLeagueTeam.copy(InviteToLeagueTeam invite)
      : leagueName = invite.leagueName,
        leagueTeamUid = invite.leagueTeamUid,
        leagueDivisonUid = invite.leagueDivisonUid,
        leagueTeamName = invite.leagueTeamName,
        leagueSeasonName = invite.leagueSeasonName,
        leagueUid = invite.leagueUid,
        super.copy(invite);

  static const String LEAGUETEAMUID = 'leagueTeamUid';
  static const String LEAGUENAME = 'leagueName';
  static const String LEAGUETEAMNAME = 'leagueTeamName';
  static const String LEAGUESEASONNAME = 'leagueSeasonName';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUEUID = 'leagueUid';

  ///
  /// This accepts the invite connecting the specified team to the matching
  /// season
  ///
  Future<void> acceptInvite(Season season) {
    return UserDatabaseData.instance.updateModel.connectLeagueTeamToSeason(
        leagueTeamUid, UserDatabaseData.instance.userUid, season);
  }

  /// Create a new invite from the json.
  InviteToLeagueTeam.fromJSON(String uid, Map<String, dynamic> data)
      : leagueTeamUid = getString(data[LEAGUETEAMUID]),
        leagueName = getString(data[LEAGUENAME]),
        leagueUid = getString(data[LEAGUEUID]) ?? "",
        leagueDivisonUid = data[LEAGUEDIVISONUID] ?? "",
        leagueTeamName = data[LEAGUETEAMNAME] ?? "",
        leagueSeasonName = data[LEAGUESEASONNAME] ?? "",
        super.fromJSON(uid, data);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUETEAMUID] = leagueTeamUid;
    ret[LEAGUEDIVISONUID] = leagueDivisonUid;
    ret[LEAGUETEAMNAME] = leagueTeamName;
    ret[LEAGUEUID] = leagueUid;
    ret[LEAGUESEASONNAME] = leagueSeasonName;
    return ret;
  }

  @override
  int compareTo(Invite other) {
    if (baseCompareTo(other) != 0) {
      return -1;
    }
    if (other is InviteToLeagueTeam) {
      if (leagueName.compareTo(other.leagueName) != 0) {
        return -1;
      }
      if (leagueUid.compareTo(other.leagueUid) != 0) {
        return -1;
      }
      if (leagueTeamUid.compareTo(other.leagueTeamUid) != 0) {
        return -1;
      }
      if (leagueTeamName.compareTo(other.leagueTeamName) != 0) {
        return -1;
      }
      if (leagueDivisonUid.compareTo(other.leagueDivisonUid) != 0) {
        return -1;
      }
      return 0;
    }
    return 1;
  }
}
