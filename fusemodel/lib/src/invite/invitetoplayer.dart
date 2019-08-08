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
  InviteType getType() => InviteType.Player;

  factory InviteToPlayer([void Function(InviteToPlayerBuilder) updates]) =
      _$InviteToPlayer;
  InviteToPlayer._();

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
}
