import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import '../serializer.dart';
import 'invite.dart';

part 'invitetoleagueasadmin.g.dart';

///
/// Invited to a league.
///
abstract class InviteToLeagueAsAdmin
    implements
        Invite,
        Built<InviteToLeagueAsAdmin, InviteToLeagueAsAdminBuilder> {
  String get leagueName;

  /// If this is not null, invite as the league admin/
  String get leagueUid;

  /// If this is not null invite as the divison admin.
  String get leagueDivisonUid;

  /// If this is not null, invite as the season admin.
  String get leagueSeasonUid;

  factory InviteToLeagueAsAdmin(
          [void Function(InviteToLeagueAsAdminBuilder) updates]) =
      _$InviteToLeagueAsAdmin;
  InviteToLeagueAsAdmin._();

  static const String LEAGUEUID = 'leagueUid';
  static const String LEAGUESEASONUID = 'leagueSeasonUid';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUENAME = 'leagueName';

  Map<String, dynamic> toMap({bool includeMembers}) {
    return dataSerializers.serializeWith(
        InviteToLeagueAsAdmin.serializer, this);
  }

  static InviteToLeagueAsAdmin fromMap(Map<String, dynamic> jsonData) {
    return dataSerializers.deserializeWith(
        InviteToLeagueAsAdmin.serializer, jsonData);
  }

  static Serializer<InviteToLeagueAsAdmin> get serializer =>
      _$inviteToLeagueAsAdminSerializer;

  static void _initializeBuilder(InviteToLeagueAsAdminBuilder b) =>
      b..type = InviteType.LeagueAdmin;
}
