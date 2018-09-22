import 'dart:async';
import 'dart:io';

import 'common.dart';
import 'season.dart';
import 'winrecord.dart';
import 'databaseupdatemodel.dart';
import 'game.dart';
import 'invite.dart';
import 'userdatabasedata.dart';
import 'persistendata.dart';
import 'hasuidcomparable.dart';

/// The sport the team is involved in
enum Sport { Basketball, Softball, Soccer, Other }

/// The gender associated with the team.
enum Gender { Female, Male, Coed, NA }

///
/// An opponent for a team with all the opponent metadata associated with it.
///
class Opponent {
  String name;
  String teamUid;
  String contact;
  String uid;
  List<String> leagueTeamUid;
  Map<String, WinRecord> record;

  Opponent(
      {this.record,
      this.name,
      this.teamUid,
      this.contact,
      this.uid,
      this.leagueTeamUid}) {
    if (record == null) {
      record = new Map<String, WinRecord>();
    }
  }

  Opponent.copy(Opponent copy) {
    name = copy.name;
    teamUid = copy.teamUid;
    contact = copy.contact;
    uid = copy.uid;
    leagueTeamUid = copy.leagueTeamUid;
    record = new Map<String, WinRecord>.from(copy.record);
  }

  static const String _CONTACT = 'contact';
  static const String _SEASONS = 'seasons';
  static const String _LEAGUETEAMUIO = 'leagueTeamUid';

  void fromJSON(String uid, String teamUid, Map<String, dynamic> data) {
    this.uid = uid;
    this.teamUid = teamUid;
    name = getString(data[NAME]);
    contact = getString(data[_CONTACT]);
    if (data[_LEAGUETEAMUIO] != null) {
      List<String> newLeagues = new List<String>();
      data[_LEAGUETEAMUIO].forEach((dynamic key, dynamic data) {
        if (data is Map<dynamic, dynamic>) {
          if (data[ADDED]) {
            newLeagues.add(key as String);
          }
        }
      });
      leagueTeamUid = newLeagues;
    }
    Map<String, WinRecord> newRecord = new Map<String, WinRecord>();
    if (data[_SEASONS] != null) {
      Map<dynamic, dynamic> innerSeason =
          data[_SEASONS] as Map<dynamic, dynamic>;
      // Load the seasons.
      innerSeason.forEach((dynamic seasonUid, dynamic value) {
        WinRecord newData =
            new WinRecord.fromJSON(value as Map<dynamic, dynamic>);
        newRecord[seasonUid.toString()] = newData;
      });
    }
    record = newRecord;
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_CONTACT] = contact;
    Map<String, Map<String, dynamic>> fluff = <String, Map<String, dynamic>>{};
    for (String league in leagueTeamUid) {
      fluff[league] = <String, dynamic>{
        ADDED: true,
      };
    }
    ret[_LEAGUETEAMUIO] = fluff;
    Map<String, dynamic> recordSection = new Map<String, dynamic>();
    record.forEach((String key, WinRecord record) {
      recordSection[key] = record.toJSON();
    });
    ret[_SEASONS] = recordSection;
    return ret;
  }

  Future<void> updateFirestore() {
    return UserDatabaseData.instance.updateModel.updateFirestoreOpponent(this);
  }

  Future<void> deleteFromFirestore() {
    return UserDatabaseData.instance.updateModel.deleteFirestoreOpponent(this);
  }

  String toString() {
    return "Opponent {$uid $name $contact team: $teamUid}";
  }

  Future<Iterable<Game>> getGames() {
    // Get all the games for this season.
    return UserDatabaseData.instance.updateModel.getOpponentGames(this);
  }
}

///
/// Used to pre-create an id before we write to the db.  This lets us put this
/// id into other places when we do the submit.
///
class PregenUidRet {
  String uid;
  dynamic extra;
}

///
/// Represents a team in the system.  All the data associated with the team
/// and the database manipulation for the team.
///
class Team extends HasUIDComparable {
  String name;

  /// How early people should arrive for the game by default.  This is
  /// overridden by the club potentially.
  num _arriveEarly;
  String currentSeason;
  Gender gender;
  String league;
  Sport sport;
  String uid;
  String photoUrl;

  /// If this is not null signifies that this team is a member of a club.
  String clubUid;

  /// If we can only see public details of this team.
  final bool publicOnly;

  /// If we should track attendecne for games in this team.  This is
  /// overridden by the club potentially.
  bool _trackAttendence;

  /// This is a list of user ids, not player Ids.
  List<String> admins = [];
  Map<String, Opponent> opponents = {};
  Map<String, Season> seasons = {};

  Iterable<Season> _completeSeasonsCached;

  Stream<UpdateReason> opponentStream;
  Stream<UpdateReason> thisTeamStream;

  StreamController<UpdateReason> _updateThisTeam =
      new StreamController<UpdateReason>();

  PregenUidRet _pregen;

  // Firebase subscriptions
  List<StreamSubscription<dynamic>> _snapshots = [];

  /// Create a team with all the basic defaults set.
  Team(
      {this.name,
      num arriveEarly = 0,
      this.currentSeason,
      this.gender: Gender.NA,
      this.league = "",
      this.sport: Sport.Other,
      this.uid,
      this.photoUrl,
      this.clubUid,
      this.publicOnly = false,
      trackAttendence = true})
      : _arriveEarly = arriveEarly,
        _trackAttendence = trackAttendence {
    thisTeamStream = _updateThisTeam.stream.asBroadcastStream();
  }

  /// Make a copy of the team to do updates on it.
  Team.copy(Team copy)
      : publicOnly = copy.publicOnly,
        name = copy.name,
        _arriveEarly = copy._arriveEarly,
        currentSeason = copy.currentSeason,
        gender = copy.gender,
        league = copy.league,
        sport = copy.sport,
        uid = copy.uid,
        photoUrl = copy.photoUrl,
        clubUid = copy.clubUid,
        admins = new List<String>.from(copy.admins),
        opponents = copy.opponents.map((String key, Opponent op) {
          return new MapEntry(key, new Opponent.copy(op));
        }),
        seasons = copy.seasons.map((String key, Season season) {
          return new MapEntry(key, new Season.copy(season));
        }),
        _trackAttendence = copy._trackAttendence,
        _completeSeasonsCached =
            copy._completeSeasonsCached.map((Season season) {
          return new Season.copy(season);
        }) {
    thisTeamStream = _updateThisTeam.stream.asBroadcastStream();
  }

  // Handle invirtes.
  StreamController<List<InviteAsAdmin>> _controller;
  Stream<List<InviteAsAdmin>> _stream;
  List<InviteAsAdmin> _invites;

  static const String _CURRENTSEASON = 'currentSeason';
  static const String _LEAGUE = 'league';
  static const String _GENDER = 'gender';
  static const String _SPORT = 'sport';
  static const String ADMINS = 'admins';
  static const String _TRACKATTENDENDCE = 'trackAttendence';
  static const String CLUBUID = 'clubUid';
  static const String LEAGUEUID = 'leagueuid';

  /// Deserialize the team.
  Team.fromJSON(String teamUid, Map<String, dynamic> data,
      {this.publicOnly = false})
      : uid = teamUid {
    updateFromJSON(data);
    thisTeamStream = _updateThisTeam.stream.asBroadcastStream();
  }

  /// Serialize the team.
  Map<String, dynamic> toJSON() {
    assert(!publicOnly);
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[ARRIVALTIME] = _arriveEarly;
    ret[_CURRENTSEASON] = currentSeason;
    ret[_LEAGUE] = league;
    ret[_GENDER] = gender.toString();
    ret[_SPORT] = sport.toString();
    ret[PHOTOURL] = photoUrl;
    ret[_TRACKATTENDENDCE] = _trackAttendence;
    ret[CLUBUID] = clubUid;
    Map<String, bool> adminMap = new Map<String, bool>();
    admins.forEach((String key) {
      adminMap[key] = true;
    });
    ret[ADMINS] = adminMap;
    return ret;
  }

  void updateFromJSON(Map<String, dynamic> data) {
    name = getString(data[NAME]);
    _arriveEarly = getNum(data[ARRIVALTIME]);
    currentSeason = getString(data[_CURRENTSEASON]);
    league = getString(data[_LEAGUE]);
    photoUrl = getString(data[PHOTOURL]);
    clubUid = data[CLUBUID];
    gender = Gender.values.firstWhere((e) => e.toString() == data[_GENDER]);
    sport = Sport.values.firstWhere((e) => e.toString() == data[_SPORT]);
    _trackAttendence = getBool(data[_TRACKATTENDENDCE], defaultValue: true);
    if (!publicOnly) {
      if (data[ADMINS] != null) {
        List<String> newAdmin = new List<String>();
        data[ADMINS].forEach((dynamic key, dynamic data) {
          if (data is bool && data) {
            newAdmin.add(key as String);
          }
        });
        admins = newAdmin;
      }
    }
    if (_updateThisTeam != null) {
      _updateThisTeam.add(UpdateReason.Update);
    }
  }

  void dispose() {
    _snapshots.forEach((StreamSubscription<dynamic> snap) {
      snap.cancel();
    });
    _snapshots.clear();
    _updateThisTeam.close();
    seasons.forEach((String key, Season season) {
      season.dispose();
    });
    seasons.clear();
    _completeSeasonsCached?.forEach((Season s) => s.dispose());
    _completeSeasonsCached = null;
    opponents.clear();
    admins.clear();
  }

  ///
  /// Triggers the update method to tell everyone watching this team that
  /// something changed.
  ///
  void updateTeam() {
    _updateThisTeam.add(UpdateReason.Update);
  }

  /// Get the attendence tracking, potentially from the club.
  bool get trackAttendence {
    if (clubUid == null) {
      return _trackAttendence;
    }
    if (UserDatabaseData.instance.clubs.containsKey(clubUid)) {
      if (UserDatabaseData.instance.clubs[clubUid].trackAttendence !=
          Tristate.Unset) {
        return UserDatabaseData.instance.clubs[clubUid].trackAttendence ==
            Tristate.Yes;
      }
    }
    return _trackAttendence;
  }

  /// Update the local attendence tracking.
  set trackAttendence(bool attend) => _trackAttendence = attend;

  /// Get the early arrive, using the club value if this is 0.
  num get arriveEarly {
    if (publicOnly) {
      return 0;
    }
    if (_arriveEarly == 0 && clubUid != null) {
      num ret = UserDatabaseData.instance.clubs[clubUid].arriveBeforeGame;
      if (ret != null) {
        return ret;
      }
    }
    return _arriveEarly;
  }

  /// Sets the early arrival values.
  set arriveEarly(int early) => _arriveEarly = early;

  ///
  /// Is the current user an admin for this team.
  ///
  bool isUserAdmin(String userId) {
    if (publicOnly) {
      return false;
    }
    return admins.contains(userId);
  }

  ///
  /// Check if the current user is an admin
  ///
  bool isAdmin() {
    if (publicOnly) {
      return false;
    }
    if (clubUid != null &&
        UserDatabaseData.instance.clubs.containsKey(clubUid)) {
      return isUserAdmin(UserDatabaseData.instance.userUid) ||
          UserDatabaseData.instance.clubs[clubUid].isAdmin();
    }
    return isUserAdmin(UserDatabaseData.instance.userUid);
  }

  ///
  /// Setup all the callbacks to wait for the various pieces to update from
  /// firestore.
  ///
  Future<void> setupSnap() async {
    _snapshots =
        await UserDatabaseData.instance.updateModel.setupSnapForTeam(this);
  }

  ///
  /// Called when an opponent details are updated.  Handles adding/deleting
  /// opponents.
  ///
  void onOpponentUpdated(List<FirestoreWrappedData> data) {
    Set<String> toDeleteOpponents = new Set<String>();
    PersistenData sql = UserDatabaseData.instance.persistentData;

    toDeleteOpponents.addAll(opponents.keys);
    for (FirestoreWrappedData doc in data) {
      Opponent opponent;
      if (opponents.containsKey(doc.id)) {
        opponent = opponents[doc.id];
      } else {
        opponent = new Opponent();
      }
      opponent.fromJSON(doc.id, uid, doc.data);
      opponents[doc.id] = opponent;
      toDeleteOpponents.remove(doc.id);
      sql.updateTeamElement(
          PersistenData.opponentsTable, doc.id, uid, toJSON());
    }
    for (String id in toDeleteOpponents) {
      sql.deleteElement(PersistenData.opponentsTable, id);
      opponents.remove(id);
    }
    updateTeam();
  }

  ///
  /// Loads the opponents from the database.
  ///
  Future<void> loadOpponents() {
    if (publicOnly) {
      return new Future.value(null);
    }
    return UserDatabaseData.instance.updateModel.loadOpponents(this);
  }

  /// This will make the uid for this without doing a query to the backend.
  String precreateUid() {
    if (_pregen == null) {
      _pregen = UserDatabaseData.instance.updateModel.precreateUid(this);
    }
    return _pregen.uid;
  }

  ///
  /// Updates firstore with the changed data in this team.
  ///
  Future<void> updateFirestore() {
    if (publicOnly) {
      return new Future.value(null);
    }
    return UserDatabaseData.instance.updateModel
        .updateFirestoreTeam(this, _pregen);
  }

  ///
  /// Updates the image used for the team.  THis uploads to storage and then
  /// updates the photoUrl
  ///
  Future<Uri> updateImage(File imgFile) {
    if (publicOnly) {
      return new Future.value(null);
    }
    return UserDatabaseData.instance.updateModel.updateTeamImage(this, imgFile);
  }

  ///
  /// Deletes the admin from firestore.
  ///
  Future<void> deleteAdmin(String uid) {
    if (publicOnly) {
      return new Future.value(null);
    }
    return UserDatabaseData.instance.updateModel.deleteAdmin(this, uid);
  }

  ///
  /// Adds the admin to fireastore.  Note, this won't reflect locally
  /// till a firestore update happens.
  ///
  Future<String> addAdmin(String uid) {
    if (publicOnly) {
      return new Future.value(null);
    }
    return UserDatabaseData.instance.updateModel.addAdmin(this.uid, uid);
  }

  ///
  /// Returns the uid for the invite.
  ///
  Future<String> inviteAsAdmin(String email) {
    if (publicOnly) {
      return new Future.value(null);
    }
    return UserDatabaseData.instance.updateModel.inviteAdminToTeam(this, email);
  }

  ///
  /// Builds the invite stream for the invites if it is not already
  /// there.
  ///
  Stream<List<InviteAsAdmin>> get inviteStream {
    if (_stream == null) {
      _controller = new StreamController<List<InviteAsAdmin>>();
      _stream = _controller.stream.asBroadcastStream();
    }
    // Do an async query.
    _doInviteQuery();
    return _stream;
  }

  ///
  /// The current cached invite set
  ///
  List<InviteAsAdmin> get invites => _invites;

  ///
  /// Compares to another team.
  ///
  int compareTo(HasUIDComparable t) {
    if (t is Team) {
      Team tTeam = t as Team;
      return name.compareTo(tTeam.name);
    }
    return uid.compareTo(t.uid);
  }

  void _doInviteQuery() {
    if (publicOnly) {
      return;
    }
    _snapshots.add(
        UserDatabaseData.instance.updateModel.getInviteForTeamStream(this));
  }

  /// Set the invites for this team.
  void setInvites(List<InviteAsAdmin> invites) {
    _invites = invites;
  }

  /// Update the season details for this team.
  Season updateSeason(String seasonUid, Map<String, dynamic> data) {
    if (publicOnly) {
      return null;
    }
    Season season;
    if (seasons.containsKey(seasonUid)) {
      season = seasons[seasonUid];
      season.fromJSON(seasonUid, data);
    } else {
      season = new Season();
      season.fromJSON(seasonUid, data);
      seasons[seasonUid] = season;
    }
    _updateThisTeam.add(UpdateReason.Update);
    return season;
  }

  ///
  /// This returns the complete season cache.  We don't worry about getting
  /// this in all cases.
  ///
  Future<Iterable<Season>> getAllSeasons() async {
    if (_completeSeasonsCached != null) {
      return _completeSeasonsCached;
    }
    if (publicOnly) {
      _completeSeasonsCached = <Season>[];
      return new Future.value(null);
    }
    SeasonSubscription sub =
        UserDatabaseData.instance.updateModel.getAllSeasons(uid);
    _snapshots.addAll(sub.subscriptions);
    Iterable<Season> seasons = await sub.stream.single;
    _snapshots.add(sub.stream.listen((Iterable<Season> update) {
      _completeSeasonsCached = update;
      updateTeam();
    }));
    _completeSeasonsCached = seasons;
    return _completeSeasonsCached;
  }

  ///
  /// Makes a pretty string for the team.
  ///
  @override
  String toString() {
    return 'Team{name: $name, arriveEarly: $_arriveEarly, '
        'currentSeason: $currentSeason, gender: $gender, league: $league, '
        'sport: $sport, uid: $uid, photoUrl: $photoUrl, clubUid: $clubUid, '
        'trackAttendence: $_trackAttendence, admins: $admins, '
        'opponents: $opponents, seasons: $seasons}';
  }
}
