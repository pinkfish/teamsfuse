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
  /// The uid associated with the plauer to be invited to.
  @BuiltValueField(wireName: playerUidField)
  String get playerUid;

  /// The name of the player to be invited to.
  String get playerName;

  /// The name of the team (if a new invite).
  @nullable
  String get teamName;

  /// The name of the season to invite to (if a new invite).
  @nullable
  String get seasonName;

  /// Factory to create the invite.
  factory InviteToPlayer([void Function(InviteToPlayerBuilder) updates]) =
      _$InviteToPlayer;
  InviteToPlayer._();

  /// The name of the field associated with the player uid.
  static const String playerUidField = 'playerUid';

  /// Serialize the invite.
  Map<String, dynamic> toMap({bool includeMembers}) {
    return dataSerializers.serializeWith(InviteToPlayer.serializer, this);
  }

  /// Deserialize the invite.
  static InviteToPlayer fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(InviteToPlayer.serializer, jsonData);
  }

  /// The serializer.
  static Serializer<InviteToPlayer> get serializer =>
      _$inviteToPlayerSerializer;

  static void _initializeBuilder(InviteToPlayerBuilder b) =>
      b..type = InviteType.Player;
}
