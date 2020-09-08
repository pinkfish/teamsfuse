import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite.g.dart';

/// The type of the invite.
class InviteType extends EnumClass {
  static Serializer<InviteType> get serializer => _$inviteTypeSerializer;

  static const InviteType Player = _$player;
  static const InviteType Team = _$team;
  static const InviteType Admin = _$admin;
  static const InviteType Club = _$club;
  static const InviteType LeagueAdmin = _$leagueAdmin;
  static const InviteType LeagueTeam = _$leagueTeam;

  const InviteType._(String name) : super(name);

  static BuiltSet<InviteType> get values => _$InviteTypeValues;

  static InviteType valueOf(String name) => _$InviteTypeValueOf(name);
}

abstract class BaseInviteType {}

///
/// Base class for all invites.
///
@BuiltValue(instantiable: false)
abstract class Invite with BaseInviteType {
  /// email invites.
  @BuiltValueField(wireName: EMAIL)
  String get email;

  /// uid of the invite itself
  String get uid;

  // Who sent the invite.
  String get sentByUid;

  @BuiltValueField(wireName: TYPE)
  InviteType get type;

  Invite rebuild(void Function(InviteBuilder) updates);
  InviteBuilder toBuilder();

  static const String TYPE = 'type';
  static const String EMAIL = 'email';
}
