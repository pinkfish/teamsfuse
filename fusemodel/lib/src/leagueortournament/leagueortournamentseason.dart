import '../common.dart';
import '../databaseupdatemodel.dart';
import 'dart:async';
import '../userdatabasedata.dart';
import 'leagueortournamentdivision.dart';

///
/// The season associated with this league or tournment.  The
/// games connect to the season, the season is part of the division
/// and the divison is part of the league.
///
class LeagueOrTournamentSeason {
  final String name;
  String uid;
  final String leagueOrTournmentUid;

  /// List of admin user ids. This is all user ids (not players)
  List<String> adminsUids = [];

  /// List of member user ids.  This is all user ids (not players)
  List<String> members = [];

  LeagueOrTournamentDivisonSubscription _divisonSub;
  Iterable<LeagueOrTournamentDivison> _cachedDivisons;
  Stream<Iterable<LeagueOrTournamentDivison>> _divisonStream;
  StreamController<Iterable<LeagueOrTournamentDivison>> _divisonController =
  new StreamController<Iterable<LeagueOrTournamentDivison>>();

  LeagueOrTournamentSeason(this.uid, this.name, this.leagueOrTournmentUid);

  LeagueOrTournamentSeason.fromJSON(String myUid, Map<String, dynamic> data)
      : uid = myUid,
        name = data[NAME],
        leagueOrTournmentUid = data[LEAGUEORTOURNMENTUID] {
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

  static const String LEAGUEORTOURNMENTUID = "leagueUid";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = <String, dynamic>{};

    ret[NAME] = name;
    ret[LEAGUEORTOURNMENTUID] = leagueOrTournmentUid;
    return ret;
  }

  Iterable<LeagueOrTournamentDivison> get cacheDivisions => _cachedDivisons;

  /// Get the teams for this league.
  Stream<Iterable<LeagueOrTournamentDivison>> get divisonStream {
    if (_divisonSub == null) {
      _divisonSub =
          UserDatabaseData.instance.updateModel.getLeagueDivisonsForSeason(uid);
      _divisonSub.subscriptions.add(_divisonSub.stream
          .listen((Iterable<LeagueOrTournamentDivison> divisons) {
        _cachedDivisons = divisons;
        _divisonController.add(_cachedDivisons);
      }));
      _divisonStream = _divisonController.stream.asBroadcastStream();
    }
    return _divisonStream;
  }

  Future<void> updateFirestore() {
    return UserDatabaseData.instance.updateModel.updateLeagueSeason(this);
  }

  void dispose() {
    _divisonSub.dispose();
    _divisonSub = null;
    _divisonController.close();
    _divisonController = null;

    for (LeagueOrTournamentDivison div in _cachedDivisons) {
      div.dispose();
    }
    _cachedDivisons = [];
  }
}
