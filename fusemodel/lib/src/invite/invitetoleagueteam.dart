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

  static const String LEAGUETEAMUID = 'leagueTeamUid';
  static const String LEAGUENAME = 'leagueName';
  static const String LEAGUETEAMNAME = 'leagueTeamName';
  static const String LEAGUESEASONNAME = 'leagueSeasonName';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUEUID = 'leagueUid';

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
}
