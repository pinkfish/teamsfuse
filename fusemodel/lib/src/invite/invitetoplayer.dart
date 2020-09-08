import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'invite.dart';

part 'invitetoplayer.g.dart';

///
/// Invited as a player to the team
///
abstract class InviteToPlayer
    implements Invite, Built<InviteToPlayer, InviteToPlayerBuilder> {
  String get playerUid;
  String get playerName;

  factory InviteToPlayer([void Function(InviteToPlayerBuilder) updates]) =
      _$InviteToPlayer;
  InviteToPlayer._();

  static const String PLAYERUID = 'playerUid';

  Map<String, dynamic> toMap({bool includeMembers}) {
    return serializers.serializeWith(InviteToPlayer.serializer, this);
  }

  static InviteToPlayer fromMap(Map<String, dynamic> jsonData) {
    return serializers.deserializeWith(InviteToPlayer.serializer, jsonData);
  }

  static Serializer<InviteToPlayer> get serializer =>
      _$inviteToPlayerSerializer;

  static void _initializeBuilder(InviteToPlayerBuilder b) =>
      b..type = InviteType.Player;
}
