import 'common.dart';
import 'winrecord.dart';
import 'userdatabasedata.dart';
import 'dart:async';
import 'invite.dart';

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

  /// The win record of this team in the divison indexed by the season.
  WinRecord record;

  // Invites
  List<InviteToLeagueTeam> _inviteTeams;
  StreamSubscription<dynamic> _inviteSub;
  Stream<LeagueOrTournamentTeam> _thisTeamStream;

  StreamController<LeagueOrTournamentTeam> _updateThisTeam;

  static const String TEAMUID = "teamUid";
  static const String SEASONUID = "seasonUid";
  static const String LEAGUEORTOURNMENTDIVISONUID = "leagueDivisonUid";
  static const String WINRECORD = "record";

  ///
  /// Create a nice new league or tournament.
  ///
  LeagueOrTournamentTeam({
    this.uid,
    this.seasonUid,
    this.teamUid,
    this.leagueOrTournamentDivisonUid,
    this.name,
  }) : record = WinRecord() {
    // Cannot be both set, one must be set.
  }

  void dispose() {
    _inviteSub?.cancel();
    _inviteSub = null;
  }

  ///
  /// Convrt this league team into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[SEASONUID] = seasonUid;
    ret[TEAMUID] = teamUid;
    ret[LEAGUEORTOURNMENTDIVISONUID] = leagueOrTournamentDivisonUid;
    ret[WINRECORD] = record.toJSON();
    return ret;
  }

  ///
  /// Starts the loading process for this team.
  ///
  void loadInvites() {
    if (_inviteSub == null) {
      _inviteSub = UserDatabaseData.instance.updateModel
          .getLeagueOrTournmentTeamInvitesStream(this);
    }
  }

  ///
  /// Gets the currently cached set of invites.
  ///
  Iterable<InviteToLeagueTeam> get cachedInvites => _inviteTeams;

  ///
  /// Set the current invites to this team.
  ///
  void setInvites(List<InviteToLeagueTeam> invites) {
    _inviteTeams = invites;
    _updateThisTeam.add(this);
  }

  ///
  /// Load this from the wire format.
  ///
  LeagueOrTournamentTeam.fromJSON(String myUid, Map<String, dynamic> data)
      : record = WinRecord.fromJSON(data[WINRECORD] ?? {}),
        teamUid = data[TEAMUID],
        seasonUid = data[SEASONUID],
        name = data[NAME],
        uid = myUid,
        leagueOrTournamentDivisonUid = data[LEAGUEORTOURNMENTDIVISONUID];

  ///
  /// Stream to let people know when this team changes.
  ///
  Stream<LeagueOrTournamentTeam> get thisTeamStream {
    if (_updateThisTeam == null) {
      _updateThisTeam = new StreamController<LeagueOrTournamentTeam>();
      _thisTeamStream = _updateThisTeam.stream.asBroadcastStream();
    }
    return _thisTeamStream;
  }

  /// Update the league team into the database.
  void firebaseUpdate() {
    UserDatabaseData.instance.updateModel.updateLeagueTeam(this);
  }

  void updateWinRecord(String season) {
    UserDatabaseData.instance.updateModel.updateLeagueTeamRecord(this, season);
  }

  @override
  String toString() {
    return 'LeagueOrTournamentTeam{uid: $uid, seasonUid: $seasonUid, teamUid: $teamUid, leagueOrTournamentDivisonUid: $leagueOrTournamentDivisonUid, name: $name, record: $record}';
  }
}
