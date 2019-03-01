import '../common.dart';

///
/// What role the user has in the team.
///
enum RoleInTeam { Player, Coach, NonPlayer }

///
/// The player associated with the season.  This contains season specific
/// details about the player.
///
class SeasonPlayer {
  String playerUid;
  RoleInTeam role;
  String jerseyNumber;
  String position;

  SeasonPlayer({this.playerUid, this.role, this.jerseyNumber, this.position});

  ///
  /// Make a copy of the season player.
  ///
  SeasonPlayer.copy(SeasonPlayer copy) {
    playerUid = copy.playerUid;
    role = copy.role;
    jerseyNumber = copy.jerseyNumber;
    position = copy.position;
  }

  static const String ROLE = 'role';
  static const String _JERSEY = 'jerseyNumber';
  static const String _POSITION = 'position';

  void fromJSON(Map<dynamic, dynamic> data) {
    role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE]);
    position = getString(data[_POSITION]) ?? "";
    jerseyNumber = getString(data[_JERSEY]) ?? "";
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[ROLE] = role.toString();
    ret[ADDED] = true;
    ret[_JERSEY] = jerseyNumber;
    ret[_POSITION] = position;
    return ret;
  }
}