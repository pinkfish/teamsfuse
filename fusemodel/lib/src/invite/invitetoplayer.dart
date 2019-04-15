import 'package:built_value/built_value.dart';

import '../common.dart';
import 'invite.dart';

part 'invitetoplayer.g.dart';

///
/// Invited as a player to the team
///
abstract class InviteToPlayer
    implements Invite, Built<InviteToPlayer, InviteToPlayerBuilder> {
  String get playerUid;
  String get playerName;

  /// The type of the invite.
  @override
  InviteType get type => InviteType.Player;

  factory InviteToPlayer([void Function(InviteToPlayerBuilder) updates]) =
      _$InviteToPlayer;
  InviteToPlayer._();

  /*
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
        */

  static const String PLAYERUID = 'playerUid';

  static InviteToPlayerBuilder fromJSON(String uid, Map<String, dynamic> data) {
    InviteToPlayerBuilder builder = InviteToPlayerBuilder();
    Invite.fromJSON(builder, uid, data);
    return builder
      ..playerUid = getString(data[PLAYERUID])
      ..playerName = getString(data[NAME]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = Invite.toJSONInternal(this);
    ret[PLAYERUID] = playerUid;
    ret[NAME] = playerName;

    return ret;
  }

  /*
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
  */
}
