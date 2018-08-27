import 'dart:async';
import 'common.dart';
import 'season.dart';
import 'userdatabasedata.dart';

enum InviteType { Player, Team, Admin, Club }

///
/// Base class for all invites.
///
class Invite {
  /// email invites.
  String email;

  /// uid of the invite itself
  String uid;

  /// The type of the invite.
  InviteType type;
  // Who sent the invite.
  String sentByUid;

  static const String EMAIL = 'email';
  static const String TYPE = 'type';
  static const String SENTBYUID = 'sentbyUid';

  Invite({this.uid, this.email, this.type, this.sentByUid});

  Invite.copy(Invite invite) {
    this.email = invite.email;
    this.uid = invite.uid;
  }

  void fromJSON(String uid, Map<String, dynamic> data) {
    email = getString(data[EMAIL]);
    type = InviteType.values
        .firstWhere((InviteType ty) => ty.toString() == data[TYPE]);
    this.uid = uid;
    sentByUid = getString(data[SENTBYUID]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[EMAIL] = email;
    ret[TYPE] = type.toString();
    ret[SENTBYUID] = sentByUid;
    return ret;
  }

  static Invite makeInviteFromJSON(String uid, Map<String, dynamic> data) {
    assert(uid != null);
    InviteType type = InviteType.values
        .firstWhere((InviteType ty) => ty.toString() == data[TYPE]);
    switch (type) {
      case InviteType.Player:
        InviteToPlayer ret = new InviteToPlayer();
        ret.fromJSON(uid, data);
        return ret;
      case InviteType.Team:
        InviteToTeam ret = new InviteToTeam();
        ret.fromJSON(uid, data);
        return ret;
      case InviteType.Admin:
        InviteAsAdmin ret = new InviteAsAdmin();
        ret.fromJSON(uid, data);
        return ret;
      case InviteType.Club:
        InviteToClub ret = new InviteToClub();
        ret.fromJSON(uid, data);
        return ret;
      default:
        throw new FormatException();
    }
  }

  Future<void> firestoreDelete() {
    return UserDatabaseData.instance.updateModel.firestoreInviteDelete(this);
  }

  @override
  String toString() {
    return 'Invite{email: $email, uid: $uid, type: $type, sentByUid: $sentByUid}';
  }


}

///
/// Invited to the team.
///
class InviteToTeam extends Invite {
  String teamName;
  String seasonName;
  String teamUid;
  String seasonUid;
  RoleInTeam role;
  List<String> playerName;

  InviteToTeam(
      {String email,
      String uid,
      String sentByUid,
      this.teamUid,
      this.teamName,
      this.seasonName,
      this.seasonUid,
      this.playerName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Team,
            sentByUid: sentByUid);

  InviteToTeam.copy(InviteToTeam invite) : super.copy(invite) {
    teamName = invite.teamName;
    seasonName = invite.seasonName;
    teamUid = invite.teamUid;
    seasonUid = invite.seasonUid;
    sentByUid = invite.sentByUid;
    playerName = new List<String>.from(invite.playerName);
    role = invite.role;
  }

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';
  static const String SEASONNAME = 'seasonName';
  static const String SEASONUID = 'seasonUid';
  static const String ROLE = 'role';

  void fromJSON(String uid, Map<String, dynamic> data) {
    super.fromJSON(uid, data);
    teamUid = getString(data[TEAMUID]);
    if (data.containsKey(NAME) && data[NAME] is List) {
      List<dynamic> nameList = data[NAME];
      playerName = nameList.map((dynamic d) => d is String ? d : "").toList();
    } else {
      playerName = [];
    }
    if (playerName == null) {
      playerName = new List<String>();
    }
    seasonUid = getString(data[SEASONUID]);
    teamName = getString(data[TEAMNAME]);
    seasonName = getString(data[SEASONNAME]);
    try {
      role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE]);
    } catch (e) {
      role = RoleInTeam.NonPlayer;
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[TEAMUID] = teamUid;
    ret[SEASONUID] = seasonUid;
    ret[NAME] = playerName;
    ret[TEAMNAME] = teamName;
    ret[SEASONNAME] = seasonName;
    ret[ROLE] = role.toString();
    return ret;
  }
}

///
/// Invited as a player to the team
///
class InviteToPlayer extends Invite {
  String playerUid;
  String playerName;

  InviteToPlayer(
      {this.playerUid,
      this.playerName,
      String email,
      String uid,
      String sentByUid})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Player,
            sentByUid: sentByUid);

  InviteToPlayer.copy(InviteToPlayer player) : super.copy(player) {
    playerUid = player.playerUid;
  }

  static const String PLAYERUID = 'playerUid';

  void fromJSON(String uid, Map<String, dynamic> data) {
    super.fromJSON(uid, data);
    playerUid = getString(data[PLAYERUID]);
    playerName = getString(data[NAME]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[PLAYERUID] = playerUid;
    ret[NAME] = playerName;

    return ret;
  }

  @override
  String toString() {
    return 'InviteToPlayer{${super.toString()} playerUid: $playerUid, playerName: $playerName}';
  }

}

///
/// Invited as an admin to the team.
///
class InviteAsAdmin extends Invite {
  String teamName;
  String teamUid;

  InviteAsAdmin(
      {String sentByUid, String email, String uid, this.teamUid, this.teamName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Admin,
            sentByUid: sentByUid);

  InviteAsAdmin.copy(InviteAsAdmin invite) : super.copy(invite) {
    teamName = invite.teamName;
    teamUid = invite.teamUid;
  }

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';

  void acceptInvite() {
    UserDatabaseData.instance.updateModel
        .addAdmin(teamUid, UserDatabaseData.instance.userUid);
  }

  void fromJSON(String uid, Map<String, dynamic> data) {
    super.fromJSON(uid, data);
    teamUid = getString(data[TEAMUID]);
    teamName = getString(data[TEAMNAME]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[TEAMUID] = teamUid;
    ret[TEAMNAME] = teamName;
    return ret;
  }

  @override
  String toString() {
    return 'InviteAsAdmin{${super.toString()}, teamName: $teamName, teamUid: $teamUid}';
  }
}

///
/// Invited to a club.
///
class InviteToClub extends Invite {
  String clubName;
  String clubUid;
  bool admin;

  InviteToClub(
      {String sentByUid,
      String email,
      String uid,
      this.clubUid,
      this.clubName,
      this.admin})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Club,
            sentByUid: sentByUid);

  InviteToClub.copy(InviteToClub invite) : super.copy(invite) {
    clubName = invite.clubName;
    clubUid = invite.clubUid;
  }

  static const String CLUBUID = 'clubUid';
  static const String CLUBNAME = 'clubName';
  static const String ADMIN = 'admin';

  Future<void> acceptInvite() {
    return UserDatabaseData.instance.updateModel
        .addUserToClub(clubUid, UserDatabaseData.instance.userUid, admin);
  }

  void fromJSON(String uid, Map<String, dynamic> data) {
    super.fromJSON(uid, data);
    clubUid = getString(data[CLUBUID]);
    clubName = getString(data[CLUBNAME]);
    admin = getBool(data[ADMIN]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[CLUBNAME] = clubName;
    ret[CLUBUID] = clubUid;
    ret[ADMIN] = admin;
    return ret;
  }
}

///
/// Invited to a league.
///
class InviteToLeague extends Invite {
  String leagueName;
  String leagueUid;
  bool admin;

  InviteToLeague(
      {String sentByUid,
      String email,
      String uid,
      this.leagueUid,
      this.leagueName,
      this.admin})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Club,
            sentByUid: sentByUid);

  InviteToLeague.copy(InviteToLeague invite) : super.copy(invite) {
    leagueName = invite.leagueName;
    leagueUid = invite.leagueUid;
  }

  static const String LEAGUEUID = 'leagueUid';
  static const String LEAGUENAME = 'leagueName';
  static const String ADMIN = 'admin';

  Future<void> acceptInvite() {
    return UserDatabaseData.instance.updateModel
        .addUserToLeague(leagueUid, UserDatabaseData.instance.userUid, admin);
  }

  void fromJSON(String uid, Map<String, dynamic> data) {
    super.fromJSON(uid, data);
    leagueUid = getString(data[LEAGUEUID]);
    leagueName = getString(data[LEAGUENAME]);
    admin = getBool(data[ADMIN]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUEUID] = leagueUid;
    ret[ADMIN] = admin;
    return ret;
  }
}
