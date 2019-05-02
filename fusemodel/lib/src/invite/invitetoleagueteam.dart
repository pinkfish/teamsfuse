import 'package:built_value/built_value.dart';

import '../common.dart';
import 'invite.dart';

part 'invitetoleagueteam.g.dart';

///
/// Invited to a league team.
///
abstract class InviteToLeagueTeam
    implements Invite, Built<InviteToLeagueTeam, InviteToLeagueTeamBuilder> {
  String get leagueName;
  String get leagueTeamName;
  String get leagueTeamUid;
  String get leagueUid;
  String get leagueDivisonUid;
  String get leagueSeasonName;

  /// The type of the invite.
  @override
  InviteType getType() => InviteType.LeagueTeam;

  factory InviteToLeagueTeam(
          [void Function(InviteToLeagueTeamBuilder) updates]) =
      _$InviteToLeagueTeam;
  InviteToLeagueTeam._();

  /*
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
        */

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
  /*
  Future<void> acceptInvite(Season season) {
    return UserDatabaseData.instance.updateModel.connectLeagueTeamToSeason(
        leagueTeamUid, UserDatabaseData.instance.userUid, season);
  }
  */

  /// Create a new invite from the json.
  static InviteToLeagueTeamBuilder fromJSON(
      String uid, Map<String, dynamic> data) {
    InviteToLeagueTeamBuilder builder = InviteToLeagueTeamBuilder();
    Invite.fromJSON(builder, uid, data);
    return builder
      ..leagueTeamUid = getString(data[LEAGUETEAMUID])
      ..leagueName = getString(data[LEAGUENAME])
      ..leagueUid = getString(data[LEAGUEUID]) ?? ""
      ..leagueDivisonUid = data[LEAGUEDIVISONUID] ?? ""
      ..leagueTeamName = data[LEAGUETEAMNAME] ?? ""
      ..leagueSeasonName = data[LEAGUESEASONNAME] ?? "";
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = Invite.toJSONInternal(this);
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUETEAMUID] = leagueTeamUid;
    ret[LEAGUEDIVISONUID] = leagueDivisonUid;
    ret[LEAGUETEAMNAME] = leagueTeamName;
    ret[LEAGUEUID] = leagueUid;
    ret[LEAGUESEASONNAME] = leagueSeasonName;
    return ret;
  }

  /*
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
  */
}
