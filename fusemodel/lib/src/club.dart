import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:fusemodel/fusemodel.dart';

import 'common.dart';

part 'club.g.dart';

///
/// Keeps track of the club details.  The tracks a list of teams,
/// the admins of the club are admins of the teams.  The members of the
/// club can see other teams in the club, as a member/visitor.  You are a
/// member if you are a member of a subteam or if you are in a member in
/// the club itself.
///
abstract class Club implements Built<Club, ClubBuilder> {
  String get uid;
  String get name;
  String get photoUrl;

  /// Some text describing what the club is about.
  String get about;

  // The sport associated with this club.
  Sport get sport;

  /// This pulls through to all the teams in a club as a default and overrides
  /// the team specific settings, if this is not null.
  Tristate get trackAttendence;

  /// This is the default to arrive before a game,  It overrides the defaults
  /// on the team if this is not null.
  int get arriveBeforeGame;

  /// List of admin user ids. This is all user ids (not players)
  BuiltSet<String> get adminsUids;

  /// List of member user ids.  This is all user ids (not players)
  BuiltSet<String> get members;

  String get userUid;

  Club._();
  factory Club([updates(ClubBuilder b)]) = _$Club;

  ///
  /// Load this from the wire format.
  ///
  static ClubBuilder fromJSON(
      String userUid, String myUid, Map<String, dynamic> data) {
    ClubBuilder builder = ClubBuilder();
    builder
      ..userUid = userUid
      ..uid = myUid
      ..name = data[NAME]
      ..photoUrl = data[PHOTOURL]
      ..about = data[_ABOUT]
      ..arriveBeforeGame = data[_ARRIVEBEFOREGAME] ?? 0
      ..trackAttendence = Tristate.values.firstWhere(
          (Tristate state) => state.toString() == data[_TRACKATTENDENCE],
          orElse: () => Tristate.Unset);
    if (data.containsKey(_SPORT)) {
      builder.sport =
          Sport.values.firstWhere((Sport s) => s.toString() == data[_SPORT]);
    }
    ;
    for (String adminUid in data[MEMBERS].keys) {
      Map<dynamic, dynamic> adminData = data[MEMBERS][adminUid];
      if (adminData[ADDED]) {
        if (adminData[ADMIN]) {
          builder.adminsUids.add(adminUid.toString());
        } else {
          builder.members.add(adminUid.toString());
        }
      }
    }
    return builder;
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
  Map<String, dynamic> toJson({String myUid, bool includeMembers = false}) {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[PHOTOURL] = photoUrl;
    ret[_TRACKATTENDENCE] = trackAttendence.toString();
    ret[_SPORT] = sport.toString();
    ret[_ABOUT] = about;
    ret[_ARRIVEBEFOREGAME] = arriveBeforeGame;
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
    return isUserMember(userUid);
  }

  bool isUserAdmin(String myUid) {
    return adminsUids.contains(myUid);
  }

  /// Is the current user an admin?
  bool isAdmin() {
    return isUserAdmin(userUid);
  }

  /*
  Iterable<Team> get cachedTeams => _teams;

  /// Get the teams for this club.
  Stream<Iterable<Team>> get teamStream {
    if (_teamSub == null) {
      _teamSub = UserDatabaseData.instance.updateModel.getClubTeams(this);
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
    InviteToClub inviteToClub = new InviteToClub((b) => b
      ..sentByUid = _userUid
      ..email = email
      ..admin = asAdmin
      ..clubUid = uid
      ..clubName = name);
    return UserDatabaseData.instance.updateModel.inviteUserToClub(inviteToClub);
  }

  @override
  String toString() {
    return 'Club{uid: $uid, name: $name, photoUrl: $photoUrl, trackAttendence: $trackAttendence, arriveBeforeGame: $arriveBeforeGame, adminsUids: $adminsUids, members: $members}';
  }
  */
}
