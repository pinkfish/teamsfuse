import 'package:built_value/built_value.dart';

part 'invite.g.dart';

/// The type of the invite.
enum InviteType { Player, Team, Admin, Club, LeagueAdmin, LeagueTeam }

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
