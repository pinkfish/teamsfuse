import 'common.dart';
import 'winrecord.dart';
import 'userdatabasedata.dart';

///
/// Team associated with a league or tournament.  A single team can
/// be associated with multiple divisons/seasons.
///
class LeagueOrTournamentTeam {
  String uid;

  /// The uid of the season of the team associated with this league.
  /// This will only be set if there is a team associated.  At this point
  /// the inviteEmail will be cleared.
  final String seasonUid;

  /// The UID for the real team this is associated with.
  final String teamUid;

  /// The uid of the league/tourment divison the team is in.
  final String leagueOrTournamentDivisonUid;

  /// The uid of the league/tournament they are associated with.

  /// Name of the team in respect to this tournament/league.
  String name;

  /// The person who this is an invite too, if it is not yet accepted.
  String inviteEmail;

  /// The win record of this team in the divison indexed by the season.
  WinRecord record;

  static const String TEAMUID = "teamUid";
  static const String SEASONUID = "seasonUid";
  static const String LEAGUEORTOURNMENTDIVISONUID = "leagueDivisonUid";
  static const String INVITEEMAIL = "inviteEmail";
  static const String WINRECORD = "record";

  ///
  /// Create a nice new league or tournament.
  ///
  LeagueOrTournamentTeam(
      {this.uid,
      this.seasonUid,
      this.teamUid,
      this.leagueOrTournamentDivisonUid,
      this.name,
      this.inviteEmail})
      : record = WinRecord() {
    // Cannot be both set, one must be set.
    assert(this.inviteEmail != null || this.seasonUid != null);
    assert(this.inviteEmail == null || this.seasonUid == null);
  }

  ///
  /// Convrt this league team into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[SEASONUID] = seasonUid;
    ret[INVITEEMAIL] = inviteEmail;
    ret[TEAMUID] = teamUid;
    ret[LEAGUEORTOURNMENTDIVISONUID] = leagueOrTournamentDivisonUid;
    return ret;
  }

  ///
  /// Load this from the wire format.
  ///
  LeagueOrTournamentTeam.fromJSON(String myUid, Map<String, dynamic> data)
      : record = WinRecord.fromJSON(data[WINRECORD]),
        teamUid = data[TEAMUID],
        seasonUid = data[SEASONUID],
        name = data[NAME],
        uid = myUid,
        inviteEmail = data[INVITEEMAIL],
        leagueOrTournamentDivisonUid = data[LEAGUEORTOURNMENTDIVISONUID];

  /// Update the league team into the database.
  void firebaseUpdate() {
    UserDatabaseData.instance.updateModel.updateLeagueTeam(this);
  }

  void updateWinRecord(String season) {
    UserDatabaseData.instance.updateModel.updateLeagueTeamRecord(this, season);
  }
}
