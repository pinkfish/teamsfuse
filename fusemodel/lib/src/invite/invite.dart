import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite.g.dart';

/// The type of the invite.
class InviteType extends EnumClass {
  /// The serialzier for the inner stuff.
  static Serializer<InviteType> get serializer => _$inviteTypeSerializer;

  /// The serializer for the invite type.
  static PrimitiveSerializer<InviteType> get primitiveSerializer => serializer;

  /// An invite to a player.
  static const InviteType Player = _$player;

  /// Ad invite as an admin.
  static const InviteType Admin = _$admin;

  /// An invite to the club.
  static const InviteType Club = _$club;

  /// An invite the league as an admin.
  static const InviteType LeagueAdmin = _$leagueAdmin;

  /// An invite the tp the league team.
  static const InviteType LeagueTeam = _$leagueTeam;

  const InviteType._(String name) : super(name);

  /// The values associated with this enum
  static BuiltSet<InviteType> get values => _$InviteTypeValues;

  /// The value of the invite based on the name.
  static InviteType valueOf(String name) => _$InviteTypeValueOf(name);
}

///
/// The base invite type everything is based off.
///
abstract class BaseInviteType {}

///
/// Base class for all invites.
///
@BuiltValue(instantiable: false)
abstract class Invite with BaseInviteType {
  /// email invites.
  @BuiltValueField(wireName: emailField)
  String get email;

  /// uid of the invite itself
  String get uid;

  /// Who sent the invite.
  String get sentByUid;

  /// The type of the invite.
  @BuiltValueField(wireName: typeField)
  InviteType get type;

  /// Rebuild the invite.
  Invite rebuild(void Function(InviteBuilder) updates);

  /// Creates a buillder for the invite.
  InviteBuilder toBuilder();

  /// The field associated with the type.
  static const String typeField = 'type';

  /// The field associated with the email.
  static const String emailField = 'email';
}
