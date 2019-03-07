import '../common.dart';
import '../userdatabasedata.dart';
import '../databaseupdatemodel.dart';
import 'dart:async';
import 'dart:io';
import '../invite.dart';
import 'leagueortournamentseason.dart';

///
/// The type of the league or tournment.
///
enum LeagueOrTournamentType {
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
  String currentSeason;
  String shortDescription;
  String longDescription;
  final LeagueOrTournamentType type;
  Gender gender;
  Sport sport;

  /// List of admin user ids. This is all user ids (not players)
  List<String> adminsUids = [];

  /// List of member user ids.  This is all user ids (not players)
  List<String> members = [];

  LeagueOrTournamentSeasonSubscription _seasonSub;
  Iterable<LeagueOrTournamentSeason> _cachedSeasons;
  Stream<Iterable<LeagueOrTournamentSeason>> _seasonStream;
  StreamController<Iterable<LeagueOrTournamentSeason>> _seasonController =
      new StreamController<Iterable<LeagueOrTournamentSeason>>();

  LeagueOrTournament(
      {this.uid,
      this.name,
      this.photoUrl,
      this.currentSeason,
      this.shortDescription,
      this.longDescription,
      this.type,
      this.sport = Sport.None,
      this.gender = Gender.NA,
      List<String> adminUids,
      List<String> members})
      : adminsUids = adminUids ?? [],
        members = members ?? [];

  LeagueOrTournament.copy(LeagueOrTournament league)
      : uid = league.uid,
        type = league.type {
    name = league.name;
    photoUrl = league.photoUrl;
    adminsUids = league.adminsUids;
    members = league.members;
    currentSeason = league.currentSeason;
    shortDescription = league.shortDescription;
    longDescription = league.longDescription;
    gender = league.gender;
    sport = league.sport;
  }

  ///
  /// Load this from the wire format.
  ///
  LeagueOrTournament.fromJson(String myUid, Map<String, dynamic> data)
      : uid = myUid,
        name = data[NAME],
        photoUrl = data[PHOTOURL],
        currentSeason = data[_CURRENTSEASON],
        shortDescription = data[SHORTDESCRIPTION],
        longDescription = data[LONGDESCRIPTION],
        gender = Gender.values.firstWhere(
            (Gender g) => g.toString() == data[GENDER],
            orElse: () => Gender.NA),
        sport = Sport.values.firstWhere(
            (Sport s) => s.toString() == data[SPORT],
            orElse: () => Sport.Other),
        type = LeagueOrTournamentType.values.firstWhere(
            (LeagueOrTournamentType t) => t.toString() == data[TYPE],
            orElse: () => LeagueOrTournamentType.League) {
    print('fromJSON $data');
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

  static const String TYPE = "type";
  static const String SHORTDESCRIPTION = "shortDescription";
  static const String LONGDESCRIPTION = "description";
  static const String MEMBERS = "members";
  static const String ADMIN = "admin";
  static const String SPORT = "sport";
  static const String GENDER = "gender";
  static const String _CURRENTSEASON = "currentSeason";

  ///
  /// Convrt this league into the format to use to send over the wire.
  ///
  Map<String, dynamic> toJson({bool includeMembers = false}) {
    Map<String, dynamic> ret = <String, dynamic>{};
    ret[NAME] = name;
    ret[PHOTOURL] = photoUrl;
    ret[SHORTDESCRIPTION] = shortDescription;
    ret[LONGDESCRIPTION] = longDescription;
    ret[_CURRENTSEASON] = currentSeason;
    ret[GENDER] = gender.toString();
    ret[SPORT] = sport.toString();
    ret[TYPE] = type.toString();
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

  Iterable<LeagueOrTournamentSeason> get cacheSeasons => _cachedSeasons;

  /// Get the teams for this league.
  Stream<Iterable<LeagueOrTournamentSeason>> get seasonStream {
    if (_seasonSub == null) {
      _seasonSub = UserDatabaseData.instance.updateModel.getLeagueSeasons(uid);
      _seasonSub.stream.listen((Iterable<LeagueOrTournamentSeason> teams) {
        _cachedSeasons = teams;
        _seasonController.add(_cachedSeasons);
      });
      _seasonStream = _seasonController.stream.asBroadcastStream();
    }
    return _seasonStream;
  }

  ///
  /// Updates the leageu/tournament from another league/tournament
  ///
  void updateFrom(LeagueOrTournament club) {
    name = club.name;
    photoUrl = club.photoUrl;
    members = club.members;
    gender = club.gender;
    sport = club.sport;
    shortDescription = club.shortDescription;
    longDescription = club.longDescription;
    currentSeason = club.currentSeason;
  }

  /// Close everything.
  void dispose() {
    _seasonController?.close();
    _seasonController = null;
    _seasonSub?.dispose();
    _seasonSub = null;
    if (_cachedSeasons != null) {
      for (LeagueOrTournamentSeason season in _cachedSeasons) {
        season.dispose();
      }
    }
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
  /// Sends the invite to this league as an admin.
  ///
  Future<String> invite(String email) {
    InviteToLeagueAsAdmin inviteToClub = new InviteToLeagueAsAdmin(
        sentByUid: UserDatabaseData.instance.userUid,
        email: email,
        leagueUid: uid,
        leagueName: name);
    return UserDatabaseData.instance.updateModel
        .inviteUserToLeague(inviteToClub);
  }

  @override
  String toString() {
    return 'LeagueOrTournament{uid: $uid, name: $name, photoUrl: '
    '$photoUrl, currentSeason: $currentSeason, shortDescription: $shortDescription, '
    'longDescription: $longDescription, type: $type, adminsUids: $adminsUids, '
    'members: $members, sport: $sport, gender: $gender}';
  }
}