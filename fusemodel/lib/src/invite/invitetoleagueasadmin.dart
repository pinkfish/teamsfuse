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
  InviteType get type => InviteType.LeagueAdmin;

  factory InviteToLeagueAsAdmin(
          [void Function(InviteToLeagueAsAdminBuilder) updates]) =
      _$InviteToLeagueAsAdmin;
  InviteToLeagueAsAdmin._();

  /*
  InviteToLeagueAsAdmin(
      {String sentByUid,
      String email,
      String uid,
      this.leagueDivisonUid,
      this.leagueSeasonUid,
      this.leagueUid,
      this.leagueName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.LeagueAdmin,
            sentByUid: sentByUid) {
    assert((leagueUid != null &&
            leagueDivisonUid == null &&
            leagueSeasonUid == null) ||
        leagueUid == null);
    assert((leagueDivisonUid != null &&
            leagueUid == null &&
            leagueSeasonUid == null) ||
        leagueDivisonUid == null);
    assert((leagueSeasonUid != null &&
            leagueDivisonUid == null &&
            leagueUid == null) ||
        leagueSeasonUid == null);
  }

  InviteToLeagueAsAdmin.copy(InviteToLeagueAsAdmin invite)
      : leagueName = invite.leagueName,
        leagueUid = invite.leagueUid,
        leagueSeasonUid = invite.leagueSeasonUid,
        leagueDivisonUid = invite.leagueDivisonUid,
        super.copy(invite) {}
        */

  static const String LEAGUEUID = 'leagueUid';
  static const String LEAGUESEASONUID = 'leagueSeasonUid';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUENAME = 'leagueName';

  /*
  Future<void> acceptInvite() {
    if (leagueUid != null) {
      return UserDatabaseData.instance.updateModel
          .addUserToLeague(leagueUid, UserDatabaseData.instance.userUid, true);
    }
    if (leagueSeasonUid != null) {
      return UserDatabaseData.instance.updateModel.addUserToLeagueSeason(
          leagueUid, UserDatabaseData.instance.userUid, true);
    }
    if (leagueDivisonUid != null) {
      return UserDatabaseData.instance.updateModel.addUserToLeagueDivison(
          leagueUid, UserDatabaseData.instance.userUid, true);
    }
    return null;
  }
  */

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
/*
  @override
  int compareTo(Invite other) {
    if (baseCompareTo(other) != 0) {
      return -1;
    }
    if (other is InviteToLeagueAsAdmin) {
      if (leagueName.compareTo(other.leagueName) != 0) {
        return -1;
      }
      if (leagueUid.compareTo(other.leagueUid) != 0) {
        return -1;
      }
      if (leagueSeasonUid.compareTo(other.leagueSeasonUid) != 0) {
        return -1;
      }
      if (leagueDivisonUid.compareTo(other.leagueDivisonUid) != 0) {
        return -1;
      }
      return 0;
    }
    return 1;
  }
  */
}
