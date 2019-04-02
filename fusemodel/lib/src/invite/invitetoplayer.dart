import '../common.dart';
import 'invite.dart';

///
/// Invited as a player to the team
///
class InviteToPlayer extends Invite {
  final String playerUid;
  final String playerName;

  InviteToPlayer(
      {this.playerUid,
      this.playerName,
      String email,
      String uid,
      String sentByUid})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Player,
            sentByUid: sentByUid);

  InviteToPlayer.copy(InviteToPlayer player)
      : playerUid = player.playerUid,
        playerName = player.playerName,
        super.copy(player);

  static const String PLAYERUID = 'playerUid';

  InviteToPlayer.fromJSON(String uid, Map<String, dynamic> data)
      : playerUid = getString(data[PLAYERUID]),
        playerName = getString(data[NAME]),
        super.fromJSON(uid, data);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[PLAYERUID] = playerUid;
    ret[NAME] = playerName;

    return ret;
  }

  @override
  String toString() {
    return 'InviteToPlayer{${super.toString()} playerUid: $playerUid, playerName: $playerName}';
  }

  @override
  int compareTo(Invite other) {
    if (baseCompareTo(other) != 0) {
      return -1;
    }
    if (other is InviteToPlayer) {
      if (playerName.compareTo(other.playerName) != 0) {
        return -1;
      }
      if (playerUid.compareTo(other.playerUid) != 0) {
        return -1;
      }
      return 0;
    }
    return 1;
  }
}
