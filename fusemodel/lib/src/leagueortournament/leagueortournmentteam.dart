import '../common.dart';
import '../winrecord.dart';
import '../userdatabasedata.dart';
import 'dart:async';
import '../invite/invitetoleagueteam.dart';
import '../game/gamesharedata.dart';
import '../databaseupdatemodel.dart';

///
/// Team associated with a league or tournament.  A single team can
/// be associated with multiple divisons/seasons.
///
class LeagueOrTournamentTeam {
  String uid;

  /// The uid of the season of the team associated with this league.
  /// This will only be set if there is a team associated.  At this point
  /// the inviteEmail will be cleared.
  String seasonUid;

  /// The UID for the real team this is associated with.
  final String teamUid;

  /// The uid of the league/tourment divison the team is in.
  final String leagueOrTournamentDivisonUid;

  /// The uid of the league/tournament they are associated with.

  /// Name of the team in respect to this tournament/league.
  String name;

  /// The win record of this team indexed by the divison.
  Map<String, WinRecord> record;

  // Invites
  List<InviteToLeagueTeam> _inviteTeams;
  StreamSubscription<dynamic> _inviteSub;
  Stream<LeagueOrTournamentTeam> _thisTeamStream;
  // Games
  List<GameSharedData> _games;
  SharedGameSubscription _sharedGameSub;
  Stream<Iterable<GameSharedData>> _gameStream;
  StreamController<Iterable<GameSharedData>> _gameController;

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
  }) : record = <String, WinRecord>{} {
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
    Map<String, dynamic> inner = {};
    for (String str in record.keys) {
      inner[str] = record[str].toJSON();
    }
    ret[WINRECORD] = inner;
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
      : teamUid = data[TEAMUID],
        seasonUid = data[SEASONUID],
        name = data[NAME],
        uid = myUid,
        leagueOrTournamentDivisonUid = data[LEAGUEORTOURNMENTDIVISONUID] {
    record = {};
    if (data[WINRECORD] is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> stuff = data[WINRECORD] as Map<dynamic, dynamic>;
      for (String key in stuff.keys) {
        if (stuff[key] is Map<dynamic, dynamic>) {
          record[key] = WinRecord.fromJSON(stuff[key]);
        }
      }
    }
  }

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

  ///
  /// The cached games for this league team.
  ///
  Iterable<GameSharedData> get cachedGames => _games;

  Stream<Iterable<GameSharedData>> get games {
    if (_gameStream != null) {
      return _gameStream;
    }
    _gameController = new StreamController();
    _gameStream = _gameController.stream.asBroadcastStream();
    _sharedGameSub =
        UserDatabaseData.instance.updateModel.getLeagueGamesForTeam(uid);
    _sharedGameSub.subscriptions
        .add(_sharedGameSub.stream.listen((Iterable<GameSharedData> gs) {
      _games = gs;
      _gameController.add(gs);
    }));
    return _gameStream;
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