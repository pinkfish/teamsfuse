import 'common.dart';
import 'userdatabasedata.dart';
import 'databaseupdatemodel.dart';
import 'leagueortournmentteam.dart';
import 'game.dart';
import 'dart:async';
import 'dart:io';
import 'invite.dart';

///
/// The type of the league or tournment.
///
enum LeagueOrTournmentType {
  Tournament,
  League,
}

///
/// Keeps track of the league details.
///
class LeagueOrTournament {
  String uid;
  String name;
  String photoUrl;
  LeagueOrTournmentType type;

  /// List of admin user ids. This is all user ids (not players)
  List<String> adminsUids = [];

  /// List of member user ids.  This is all user ids (not players)
  List<String> members = [];

  // Cached list of teams.
  Iterable<LeagueOrTournmentTeam> _teams;

  /// Cached list of games.
  Iterable<Game> _games;

  LeagueOrTournmentTeamSubscription _teamSub;
  Stream<Iterable<LeagueOrTournmentTeam>> _teamStream;
  StreamController<Iterable<LeagueOrTournmentTeam>> _teamController =
      new StreamController<Iterable<LeagueOrTournmentTeam>>();

  GameSubscription _gameSub;
  Stream<Iterable<Game>> _gameStream;
  StreamController<Iterable<Game>> _gameController =
      new StreamController<Iterable<Game>>();

  LeagueOrTournament(
      {this.uid,
      this.name,
      this.photoUrl,
      List<String> adminUids,
      List<String> members})
      : adminsUids = adminUids ?? [],
        members = members ?? [];

  LeagueOrTournament.copy(LeagueOrTournament club) {
    uid = club.uid;
    name = club.name;
    photoUrl = club.photoUrl;
    adminsUids = club.adminsUids;
    members = club.members;
  }

  ///
  /// Load this from the wire format.
  ///
  LeagueOrTournament.fromJson(String myUid, Map<String, dynamic> data) {
    uid = myUid;
    name = data[NAME];
    photoUrl = data[PHOTOURL];
    adminsUids = [];
    members = [];
    print(data[MEMBERS]);
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

  static const String MEMBERS = "members";
  static const String ADMIN = "admin";

  ///
  /// Convrt this league into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJson({bool includeMembers = false}) {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[PHOTOURL] = photoUrl;
    Map<String, dynamic> data = <String, dynamic>{};
    if (includeMembers) {
      for (String admin in adminsUids) {
        data[admin] = <String, bool>{ADDED: true, ADMIN: true};
      }
      for (String member in members) {
        data[member] = <String, bool>{ADDED: true, ADMIN: false};
      }
      ret[MEMBERS] = data;
    }
    return ret;
  }

  bool isUserMember(String myUid) {
    return adminsUids.contains(myUid) || members.contains(myUid);
  }

  /// Is the current user a member (or admin)?
  bool isMember() {
    return isUserMember(UserDatabaseData.instance.userUid);
  }

  bool isUserAdmin(String myUid) {
    return adminsUids.contains(myUid);
  }

  /// Is the current user an admin?
  bool isAdmin() {
    return isUserAdmin(UserDatabaseData.instance.userUid);
  }

  Iterable<LeagueOrTournmentTeam> get cachedTeams => _teams;

  /// Get the teams for this league.
  Stream<Iterable<LeagueOrTournmentTeam>> get teamStream {
    if (_teamSub == null) {
      _teamSub = UserDatabaseData.instance.updateModel.getLeagueTeams(uid);
      _teamSub.stream.listen((Iterable<LeagueOrTournmentTeam> teams) {
        _teams = teams;
        _teamController.add(_teams);
      });
      _teamStream = _teamController.stream.asBroadcastStream();
    }
    return _teamStream;
  }

  /// Get the games for this league.
  Stream<Iterable<Game>> get gameStream {
    if (_gameSub == null) {
      _gameSub = UserDatabaseData.instance.updateModel.getLeagueGames(uid);
      _gameSub.stream.listen((Iterable<Game> teams) {
        _games = teams;
        _gameController.add(_games);
      });
      _teamStream = _teamController.stream.asBroadcastStream();
    }
    return _gameStream;
  }

  ///
  /// Updates the leageu/tournament from another league/tournament
  ///
  void updateFrom(LeagueOrTournament club) {
    name = club.name;
    photoUrl = club.photoUrl;
    members = club.members;
  }

  /// Close everything.
  void dispose() {
    _teamController?.close();
    _teamController = null;
    _teamSub?.dispose();
    _teamSub = null;
  }

  Future<String> updateFirestore({bool includeMembers = false}) {
    return UserDatabaseData.instance.updateModel
        .updateLeague(this, includeMembers: includeMembers)
        .then((String newUid) {
      if (uid == null) {
        uid = newUid;
      }
      return newUid;
    });
  }

  /// Update the image for this league.
  Future<Uri> updateImage(File imageFile) {
    return UserDatabaseData.instance.updateModel
        .updateLeagueImage(this, imageFile);
  }

  /// Deletes the specific league member.
  Future<void> deleteLeagueMember(String memberUid) {
    return UserDatabaseData.instance.updateModel
        .deleteLeagueMember(this, memberUid);
  }

  ///
  /// Sends the invite to this club.
  ///
  Future<String> invite(String email, bool asAdmin) {
    InviteToLeague inviteToClub = new InviteToLeague(
        sentByUid: UserDatabaseData.instance.userUid,
        email: email,
        admin: asAdmin,
        leagueUid: uid,
        leagueName: name);
    return UserDatabaseData.instance.updateModel
        .inviteUserToLeague(inviteToClub);
  }

  @override
  String toString() {
    return 'Club{uid: $uid, name: $name, photoUrl: $photoUrl, '
        'adminsUids: $adminsUids, members: $members}';
  }
}
