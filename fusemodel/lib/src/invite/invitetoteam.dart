import '../common.dart';
import 'invite.dart';
import '../team.dart';

///
/// Invited to the team.
///
class InviteToTeam extends Invite {
  final String teamName;
  final String seasonName;
  final String teamUid;
  final String seasonUid;
  final RoleInTeam role;
  List<String> playerName;

  InviteToTeam(
      {String email,
        String uid,
        String sentByUid,
        this.teamUid,
        this.teamName,
        this.seasonName,
        this.seasonUid,
        this.playerName,
        this.role = RoleInTeam.Player})
      : super(
      email: email,
      uid: uid,
      type: InviteType.Team,
      sentByUid: sentByUid);

  InviteToTeam.copy(InviteToTeam invite)
      : teamName = invite.teamName,
        seasonName = invite.seasonName,
        teamUid = invite.teamUid,
        seasonUid = invite.seasonUid,
        playerName = new List<String>.from(invite.playerName),
        role = invite.role,
        super.copy(invite) {}

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';
  static const String SEASONNAME = 'seasonName';
  static const String SEASONUID = 'seasonUid';
  static const String ROLE = 'role';

  InviteToTeam.fromJSON(String uid, Map<String, dynamic> data)
      : teamUid = getString(data[TEAMUID]),
        seasonUid = getString(data[SEASONUID]),
        teamName = getString(data[TEAMNAME]),
        seasonName = getString(data[SEASONNAME]),
        role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE],
            orElse: () => RoleInTeam.NonPlayer),
        super.fromJSON(uid, data) {
    if (data.containsKey(NAME) && data[NAME] is List) {
      List<dynamic> nameList = data[NAME];
      playerName = nameList.map((dynamic d) => d is String ? d : "").toList();
    } else {
      playerName = [];
    }
    if (playerName == null) {
      playerName = new List<String>();
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[TEAMUID] = teamUid;
    ret[SEASONUID] = seasonUid;
    ret[NAME] = playerName;
    ret[TEAMNAME] = teamName;
    ret[SEASONNAME] = seasonName;
    ret[ROLE] = role.toString();
    return ret;
  }
}
