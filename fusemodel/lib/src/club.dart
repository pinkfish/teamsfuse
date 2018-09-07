import 'common.dart';
import 'userdatabasedata.dart';
import 'databaseupdatemodel.dart';
import 'team.dart';
import 'dart:async';
import 'dart:io';
import 'invite.dart';

///
/// Keeps track of the club details.  The tracks a list of teams,
/// the admins of the club are admins of the teams.  The members of the
/// club can see other teams in the club, as a member/visitor.  You are a
/// member if you are a member of a subteam or if you are in a member in
/// the club itself.
///
class Club {
  String uid;
  String name;
  String photoUrl;

  /// Some text describing what the club is about.
  String about;

  // The sport associated with this club.
  Sport sport;

  /// This pulls through to all the teams in a club as a default and overrides
  /// the team specific settings, if this is not null.
  Tristate trackAttendence = Tristate.Unset;

  /// This is the default to arrive before a game,  It overrides the defaults
  /// on the team if this is not null.
  int arriveBeforeGame;

  /// List of admin user ids. This is all user ids (not players)
  List<String> adminsUids = [];

  /// List of member user ids.  This is all user ids (not players)
  List<String> members = [];

  // Cached list of teams.
  Iterable<Team> _teams;

  TeamSubscription _teamSub;
  Stream<Iterable<Team>> _teamStream;
  StreamController<Iterable<Team>> _teamController =
      new StreamController<Iterable<Team>>();

  Club(
      {this.uid,
      this.name,
      this.photoUrl,
        this.about,
      this.sport = Sport.Basketball,
      this.trackAttendence = Tristate.Unset,
      List<String> adminUids,
      List<String> members,
      this.arriveBeforeGame})
      : adminsUids = adminUids ?? [],
        members = members ?? [];

  Club.copy(Club club) {
    uid = club.uid;
    name = club.name;
    sport = club.sport;
    photoUrl = club.photoUrl;
    trackAttendence = club.trackAttendence;
    adminsUids = club.adminsUids;
    members = club.members;
    about = club.about;
    arriveBeforeGame = club.arriveBeforeGame;
  }

  ///
  /// Load this from the wire format.
  ///
  Club.fromJson(String myUid, Map<String, dynamic> data) {
    uid = myUid;
    name = data[NAME];
    photoUrl = data[PHOTOURL];
    if (data.containsKey(_SPORT)) {
      sport =
          Sport.values.firstWhere((Sport s) => s.toString() == data[_SPORT]);
    }
    arriveBeforeGame = data[_ARRIVEBEFOREGAME];
    adminsUids = [];
    members = [];
    about = data[_ABOUT];
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
    trackAttendence = Tristate.values.firstWhere(
        (Tristate state) => state.toString() == data[_TRACKATTENDENCE]);
  }

  static const String _TRACKATTENDENCE = "trackAttendence";
  static const String MEMBERS = "members";
  static const String _ARRIVEBEFOREGAME = "arriveBefore";
  static const String _SPORT = "sport";
  static const String _ABOUT = "about";
  static const String ADMIN = "admin";

  ///
  /// Convrt this club into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJson({bool includeMembers = false}) {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[PHOTOURL] = photoUrl;
    ret[_TRACKATTENDENCE] = trackAttendence.toString();
    ret[_SPORT] = sport.toString();
    ret[_ABOUT] = about;
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

  Iterable<Team> get cachedTeams => _teams;

  /// Get the teams for this club.
  Stream<Iterable<Team>> get teamStream {
    if (_teamSub == null) {
      _teamSub = UserDatabaseData.instance.updateModel.getClubTeams(uid);
      _teamSub.stream.listen((Iterable<Team> teams) {
        _teams = teams;
        _teamController.add(_teams);
      });
      _teamStream = _teamController.stream.asBroadcastStream();
    }
    return _teamStream;
  }

  ///
  /// Updates the club from another club.
  ///
  void updateFrom(Club club) {
    name = club.name;
    photoUrl = club.photoUrl;
    trackAttendence = club.trackAttendence;
    arriveBeforeGame = club.arriveBeforeGame;
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
        .updateClub(this, includeMembers: includeMembers)
        .then((String newUid) {
      if (uid == null) {
        uid = newUid;
      }
      return newUid;
    });
  }

  Future<Uri> updateImage(File imageFile) {
    return UserDatabaseData.instance.updateModel
        .updateClubImage(this, imageFile);
  }

  Future<void> deleteClubMember(String memberUid) {
    return UserDatabaseData.instance.updateModel
        .deleteClubMember(this, memberUid);
  }

  ///
  /// Sends the invite to this club.
  ///
  Future<String> invite(String email, bool asAdmin) {
    InviteToClub inviteToClub = new InviteToClub(
        sentByUid: UserDatabaseData.instance.userUid,
        email: email,
        admin: asAdmin,
        clubUid: uid,
        clubName: name);
    return UserDatabaseData.instance.updateModel.inviteUserToClub(inviteToClub);
  }

  @override
  String toString() {
    return 'Club{uid: $uid, name: $name, photoUrl: $photoUrl, trackAttendence: $trackAttendence, arriveBeforeGame: $arriveBeforeGame, adminsUids: $adminsUids, members: $members}';
  }
}
