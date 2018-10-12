import 'dart:async';
import '../common.dart';
import '../userdatabasedata.dart';
import 'invite.dart';

///
/// Invited to a league.
///
class InviteToLeagueAsAdmin extends Invite {
  final String leagueName;

  /// If this is not null, invite as the league admin/
  final String leagueUid;

  /// If this is not null invite as the divison admin.
  final String leagueDivisonUid;

  /// If this is not null, invite as the season admin.
  final String leagueSeasonUid;

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

  static const String LEAGUEUID = 'leagueUid';
  static const String LEAGUESEASONUID = 'leagueSeasonUid';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUENAME = 'leagueName';

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

  InviteToLeagueAsAdmin.fromJSON(String uid, Map<String, dynamic> data)
      : leagueUid = getString(data[LEAGUEUID]),
        leagueName = getString(data[LEAGUENAME]),
        leagueDivisonUid = data[LEAGUEDIVISONUID] ?? "",
        leagueSeasonUid = data[LEAGUESEASONUID] ?? "",
        super.fromJSON(uid, data) {}

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUEUID] = leagueUid;
    ret[LEAGUESEASONUID] = leagueSeasonUid;
    ret[LEAGUEDIVISONUID] = leagueDivisonUid;
    return ret;
  }
}