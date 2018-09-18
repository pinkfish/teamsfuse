import 'dart:async';
import 'common.dart';
import 'invite.dart';
import 'winrecord.dart';
import 'userdatabasedata.dart';
import 'databaseupdatemodel.dart';
import 'team.dart';
import 'leagueortournmentteam.dart';

///
/// What role the user has in the team.
///
enum RoleInTeam { Player, Coach, NonPlayer }

///
/// The player associated with the season.  This contains season specific
/// details about the player.
///
class SeasonPlayer {
  String playerUid;
  RoleInTeam role;
  String jerseyNumber;
  String position;

  SeasonPlayer({this.playerUid, this.role, this.jerseyNumber, this.position});

  ///
  /// Make a copy of the season player.
  ///
  SeasonPlayer.copy(SeasonPlayer copy) {
    playerUid = copy.playerUid;
    role = copy.role;
    jerseyNumber = copy.jerseyNumber;
    position = copy.position;
  }

  static const String ROLE = 'role';
  static const String _JERSEY = 'jerseyNumber';
  static const String _POSITION = 'position';

  void fromJSON(Map<dynamic, dynamic> data) {
    role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE]);
    position = getString(data[_POSITION]);
    jerseyNumber = getString(data[_JERSEY]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[ROLE] = role.toString();
    ret[ADDED] = true;
    ret[_JERSEY] = jerseyNumber;
    ret[_POSITION] = position;
    return ret;
  }
}

class Season {
  String name;
  String uid;
  String teamUid;
  WinRecord record;
  List<SeasonPlayer> players = [];

  StreamController<List<InviteToTeam>> _controller;
  StreamSubscription<dynamic> inviteSnapshot;
  Stream<List<InviteToTeam>> _stream;
  List<InviteToTeam> _invites;
  PregenUidRet _pregen;

  LeagueOrTournmentTeamSubscription _teamsSub;
  Iterable<LeagueOrTournamentTeam> _cachedLeagueTeams;
  Stream<Iterable<LeagueOrTournamentTeam>> _teamsStream;
  StreamController<Iterable<LeagueOrTournamentTeam>> _teamsController =
      new StreamController<Iterable<LeagueOrTournamentTeam>>();

  Season({this.name, this.uid, this.teamUid, this.record, this.players}) {
    if (players == null) {
      players = new List<SeasonPlayer>();
    }
  }

  Season.copy(Season copy) {
    name = copy.name;
    uid = copy.uid;
    teamUid = copy.teamUid;
    record = copy.record;
    players = copy.players;
  }

  GameSubscription getGames() {
    // Get all the games for this season.
    return UserDatabaseData.instance.updateModel.getSeasonGames([], this);
  }

  List<InviteToTeam> get invites => _invites;

  static const String RECORD = 'record';
  static const String PLAYERS = 'players';
  static const String TEAMUID = 'teamUid';

  void fromJSON(String uid, Map<String, dynamic> data) {
    this.uid = uid;
    name = getString(data[NAME]);
    record = new WinRecord.fromJSON(data[RECORD] as Map<dynamic, dynamic>);
    this.teamUid = teamUid;
    this.record = record;
    this.teamUid = data[TEAMUID];
    Map<dynamic, dynamic> playersData = data[PLAYERS];
    List<SeasonPlayer> newPlayers = new List<SeasonPlayer>();
    playersData.forEach((dynamic key, dynamic val) {
      String playerUid = key;
      SeasonPlayer player = new SeasonPlayer();
      player.playerUid = playerUid;
      if (val != null) {
        player.fromJSON(val as Map<dynamic, dynamic>);
        newPlayers.add(player);
      }
    });
    players = newPlayers;
    print('Update Season ' + uid);
  }

  Map<String, dynamic> toJSON({bool includePlayers: false}) {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[RECORD] = record.toJSON();
    ret[TEAMUID] = teamUid;
    if (includePlayers) {
      Map<String, dynamic> output = new Map<String, dynamic>();
      players.forEach((value) {
        output[value.playerUid] = value.toJSON();
      });
      ret[PLAYERS] = output;
    }
    return ret;
  }

  Future<void> updateFirestore({bool includePlayers = false}) async {
    return UserDatabaseData.instance.updateModel
        .updateFirestoreSeason(this, includePlayers, _pregen);
  }

  Future<void> removePlayer(SeasonPlayer player) async {
    return UserDatabaseData.instance.updateModel
        .removePlayerFromSeason(this, player);
  }

  Future<void> updateRoleInTeam(SeasonPlayer player, RoleInTeam role) async {
    return UserDatabaseData.instance.updateModel
        .updateRoleInTeamForSeason(this, player, role);
  }

  // Send an invite to a user for this season and team.
  Future<void> inviteUser(
      {String userId, String playername, String email, RoleInTeam role}) async {
    return UserDatabaseData.instance.updateModel.inviteUserToSeason(this,
        userId: userId,
        playername: playername,
        email: normalizeEmail(email),
        role: role);
  }

  Stream<List<InviteToTeam>> get inviteStream {
    if (_stream == null) {
      _controller = new StreamController<List<InviteToTeam>>();
      _stream = _controller.stream.asBroadcastStream();
    }
    // Do an async query.
    _doInviteQuery();
    return _stream;
  }

  void setInvites(List<InviteToTeam> invites) {
    _invites = invites;
    _controller.add(invites);
  }

  Future<void> _doInviteQuery() async {
    inviteSnapshot = await UserDatabaseData.instance.updateModel
        .getInviteForSeasonStream(this);
  }

  /// This will make the uid for this without doing a query to the backend.
  String precreateUid() {
    if (_pregen == null) {
      _pregen = UserDatabaseData.instance.updateModel.precreateUidSeason(this);
    }
    return _pregen.uid;
  }

  Iterable<LeagueOrTournamentTeam> get cacheLeagueOrTournamentTeams =>
      _cachedLeagueTeams;

  /// Get the teams for this league.
  Stream<Iterable<LeagueOrTournamentTeam>> get leagueOrTournamentTeams {
    if (_teamsSub == null) {
      _teamsSub = UserDatabaseData.instance.updateModel
          .getLeagueTeamsForTeamSeason(uid);
      _teamsSub.stream.listen((Iterable<LeagueOrTournamentTeam> teams) {
        _cachedLeagueTeams = teams;
        _teamsController.add(_cachedLeagueTeams);
      });
      _teamsStream = _teamsController.stream.asBroadcastStream();
    }
    return _teamsStream;
  }

  ///
  /// Cleanup all the bits for this class.
  ///
  void dispose() {
    if (_controller != null) {
      _controller.close();
    }
    if (_stream != null) {
      _stream = null;
    }
    inviteSnapshot?.cancel();
    inviteSnapshot = null;

    _teamsSub?.dispose();
    _teamsSub = null;
    _teamsController.close();
    _teamsController = null;
  }

  ///
  /// Is the current user an admin for this season
  ///
  bool isAdmin(Map<String, Team> teams) {
    //Find the team and check there.
    if (teams.containsKey(teamUid)) {
      return teams[teamUid].isAdmin();
    }
    return false;
  }
}
