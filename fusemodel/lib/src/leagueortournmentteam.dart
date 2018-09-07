import 'common.dart';

///
/// Team associated with a league or tournament.
///
class LeagueOrTournmentTeam {
  String uid;

  /// The uid of the team associated with this league.  This will only be
  /// set if there is a team associated.  At this point the inviteEmail will
  /// be cleared.
  String teamUid;

  /// The uid of the league/tourment itself.
  String leagueOrTournmentUid;

  /// Name of the team in respect to this tournament/league.
  String name;

  /// The person who this is an invite too, if it is not yet accepted.
  String inviteEmail;

  static const String TEAMUID = "teamUid";
  static const String LEAGUEORTOURNMENTUID = "leagueOrTournmentUid";
  static const String INVITEEMAIL = "inviteEmail";

  ///
  /// Create a nice new league or tournament.
  ///
  LeagueOrTournmentTeam(
      {this.uid,
      this.teamUid,
      this.leagueOrTournmentUid,
      this.name,
      this.inviteEmail}) {
    // Cannot be both set, one must be set.
    assert(this.inviteEmail != null || this.teamUid != null);
    assert(this.inviteEmail == null || this.teamUid == null);
  }

  ///
  /// Convrt this league team into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[TEAMUID] = teamUid;
    ret[LEAGUEORTOURNMENTUID] = leagueOrTournmentUid;
    ret[INVITEEMAIL] = inviteEmail;
    return ret;
  }

  ///
  /// Load this from the wire format.
  ///
  LeagueOrTournmentTeam.fromJson(String myUid, Map<String, dynamic> data) {
    uid = myUid;
    name = data[NAME];
    teamUid = data[TEAMUID];
    leagueOrTournmentUid = data[LEAGUEORTOURNMENTUID];
    inviteEmail = data[INVITEEMAIL];
  }
}
