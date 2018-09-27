import '../common.dart';
import '../databaseupdatemodel.dart';
import 'dart:async';
import '../userdatabasedata.dart';
import 'leagueortournmentteam.dart';
import '../game.dart';

///
/// A division in a league or tournament.  The seasons are associated
/// with the division and the division is connected back to the
/// league or tournament.
///
class LeagueOrTournamentDivison {
  final String name;
  String uid;
  final String leagueOrTournmentSeasonUid;

  /// List of admin user ids. This is all user ids (not players)
  List<String> adminsUids = [];

  /// List of member user ids.  This is all user ids (not players)
  List<String> members = [];

  /// Cached list of games.
  Iterable<GameSharedData> _games;
  SharedGameSubscription _gameSub;
  Stream<Iterable<GameSharedData>> _gameStream;
  StreamController<Iterable<GameSharedData>> _gameController =
      new StreamController<Iterable<GameSharedData>>();

  // Teams
  LeagueOrTournmentTeamSubscription _teamSub;
  Iterable<LeagueOrTournamentTeam> _cachedTeams;
  Stream<Iterable<LeagueOrTournamentTeam>> _teamStream;
  StreamController<Iterable<LeagueOrTournamentTeam>> _teamController =
      new StreamController<Iterable<LeagueOrTournamentTeam>>();

  LeagueOrTournamentDivison(
      this.uid, this.name, this.leagueOrTournmentSeasonUid);

  LeagueOrTournamentDivison.copy(LeagueOrTournamentDivison copy)
      : name = copy.name,
        uid = copy.uid,
        leagueOrTournmentSeasonUid = copy.leagueOrTournmentSeasonUid;

  LeagueOrTournamentDivison.fromJSON(String myUid, Map<String, dynamic> data)
      : uid = myUid,
        name = data[NAME],
        leagueOrTournmentSeasonUid = data[LEAGUEORTOURNMENTSEASONUID] {
    if (data.containsKey(MEMBERS)) {
      for (String adminUid in data[MEMBERS].keys) {
        Map<dynamic, dynamic> adminData = data[MEMBERS][adminUid];
        if (adminData[ADDED]) {
          if (adminData[ADMIN]) {
            adminsUids.add(adminUid.toString());
          } else {
            members.add(adminUid.toString());
          }
        }
      }
    }
  }

  static const String LEAGUEORTOURNMENTSEASONUID = "seasonUid";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};

    ret[NAME] = name;
    ret[LEAGUEORTOURNMENTSEASONUID] = leagueOrTournmentSeasonUid;
    return ret;
  }

  Future<void> updateFirestore() {
    return UserDatabaseData.instance.updateModel.updateLeagueDivison(this);
  }

  Iterable<LeagueOrTournamentTeam> get cachedTeams => _cachedTeams;

  /// Get the teams for this league.
  Stream<Iterable<LeagueOrTournamentTeam>> get teamStream {
    if (_teamSub == null) {
      _teamSub =
          UserDatabaseData.instance.updateModel.getLeagueDivisionTeams(uid);
      _teamSub.subscriptions
          .add(_teamSub.stream.listen((Iterable<LeagueOrTournamentTeam> teams) {
        _cachedTeams = teams;
        _teamController.add(_cachedTeams);
      }));
      _teamStream = _teamController.stream.asBroadcastStream();
    }
    return _teamStream;
  }

  Iterable<GameSharedData> get cachedGames => _games;

  /// Get the games for this league.
  Stream<Iterable<GameSharedData>> get gameStream {
    if (_gameSub == null) {
      _gameSub =
          UserDatabaseData.instance.updateModel.getLeagueGamesForDivison(uid);
      _gameSub.subscriptions
          .add(_gameSub.stream.listen((Iterable<GameSharedData> games) {
        _games = games;
        _gameController.add(_games);
      }));
      _gameStream = _gameController.stream.asBroadcastStream();
    }
    return _gameStream;
  }

  void dispose() {
    _teamSub.dispose();
    _teamSub = null;
    _teamController.close();
    _teamController = null;
    // Dispose all the teams too.
    for (LeagueOrTournamentTeam team in _cachedTeams) {
      team.dispose();
    }
    _cachedTeams = [];

    _gameController?.close();
    _gameController = null;
    _gameSub?.dispose();
    _gameSub = null;
    // Dispose all the games too.
    _games = [];
  }
}
