import 'package:built_value/built_value.dart';

import '../common.dart';
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

  /// The type of the invite.
  @override
  InviteType getType() => InviteType.LeagueAdmin;

  factory InviteToLeagueAsAdmin(
          [void Function(InviteToLeagueAsAdminBuilder) updates]) =
      _$InviteToLeagueAsAdmin;
  InviteToLeagueAsAdmin._();

  static const String LEAGUEUID = 'leagueUid';
  static const String LEAGUESEASONUID = 'leagueSeasonUid';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUENAME = 'leagueName';

  static InviteToLeagueAsAdminBuilder fromJSON(
      String uid, Map<String, dynamic> data) {
    InviteToLeagueAsAdminBuilder b = InviteToLeagueAsAdminBuilder();
    Invite.fromJSON(b, uid, data);
    return b
      ..leagueUid = getString(data[LEAGUEUID])
      ..leagueName = getString(data[LEAGUENAME])
      ..leagueDivisonUid = data[LEAGUEDIVISONUID] ?? ""
      ..leagueSeasonUid = data[LEAGUESEASONUID] ?? "";
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = Invite.toJSONInternal(this);
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUEUID] = leagueUid;
    ret[LEAGUESEASONUID] = leagueSeasonUid;
    ret[LEAGUEDIVISONUID] = leagueDivisonUid;
    return ret;
  }
}
