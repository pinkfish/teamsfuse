import 'dart:async';
import 'common.dart';
import 'season.dart';
import 'userdatabasedata.dart';

enum InviteType { Player, Team, Admin, Club, LeagueAdmin, LeagueTeam }

///
/// Base class for all invites.
///
class Invite {
  /// email invites.
  String email;

  /// uid of the invite itself
  String uid;

  /// The type of the invite.
  final InviteType type;

  // Who sent the invite.
  final String sentByUid;

  static const String EMAIL = 'email';
  static const String TYPE = 'type';
  static const String SENTBYUID = 'sentbyUid';

  Invite({this.uid, this.email, this.type, this.sentByUid});

  Invite.copy(Invite invite)
      : email = invite.email,
        uid = invite.uid,
        sentByUid = invite.sentByUid,
        type = invite.type;

  Invite.fromJSON(String myUid, Map<String, dynamic> data)
      : email = getString(data[EMAIL]),
        type = InviteType.values
            .firstWhere((InviteType ty) => ty.toString() == data[TYPE]),
        uid = myUid,
        sentByUid = getString(data[SENTBYUID]);

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
        InviteToPlayer ret = new InviteToPlayer.fromJSON(uid, data);
        return ret;
      case InviteType.Team:
        InviteToTeam ret = new InviteToTeam.fromJSON(uid, data);
        return ret;
      case InviteType.Admin:
        InviteAsAdmin ret = new InviteAsAdmin.fromJSON(uid, data);
        return ret;
      case InviteType.Club:
        InviteToClub ret = new InviteToClub.fromJSON(uid, data);
        return ret;
      case InviteType.LeagueAdmin:
        InviteToLeagueAsAdmin ret =
            new InviteToLeagueAsAdmin.fromJSON(uid, data);
        return ret;
      case InviteType.LeagueTeam:
        InviteToLeagueTeam ret = new InviteToLeagueTeam.fromJSON(uid, data);
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
  final String teamName;
  final String seasonName;
  final String teamUid;
  final String seasonUid;
  final RoleInTeam role;
  List<String> playerName;

  InviteToTeam(
      {String email,
      String uid,
      String sentByUid,
      this.teamUid,
      this.teamName,
      this.seasonName,
      this.seasonUid,
      this.playerName,
      this.role = RoleInTeam.Player})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Team,
            sentByUid: sentByUid);

  InviteToTeam.copy(InviteToTeam invite)
      : teamName = invite.teamName,
        seasonName = invite.seasonName,
        teamUid = invite.teamUid,
        seasonUid = invite.seasonUid,
        playerName = new List<String>.from(invite.playerName),
        role = invite.role,
        super.copy(invite) {}

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';
  static const String SEASONNAME = 'seasonName';
  static const String SEASONUID = 'seasonUid';
  static const String ROLE = 'role';

  InviteToTeam.fromJSON(String uid, Map<String, dynamic> data)
      : teamUid = getString(data[TEAMUID]),
        seasonUid = getString(data[SEASONUID]),
        teamName = getString(data[TEAMNAME]),
        seasonName = getString(data[SEASONNAME]),
        role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE],
            orElse: () => RoleInTeam.NonPlayer),
        super.fromJSON(uid, data) {
    if (data.containsKey(NAME) && data[NAME] is List) {
      List<dynamic> nameList = data[NAME];
      playerName = nameList.map((dynamic d) => d is String ? d : "").toList();
    } else {
      playerName = [];
    }
    if (playerName == null) {
      playerName = new List<String>();
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
  final String playerUid;
  final String playerName;

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

  InviteToPlayer.copy(InviteToPlayer player)
      : playerUid = player.playerUid,
        playerName = player.playerName,
        super.copy(player);

  static const String PLAYERUID = 'playerUid';

  InviteToPlayer.fromJSON(String uid, Map<String, dynamic> data)
      : playerUid = getString(data[PLAYERUID]),
        playerName = getString(data[NAME]),
        super.fromJSON(uid, data);

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
  final String teamName;
  final String teamUid;

  InviteAsAdmin(
      {String sentByUid, String email, String uid, this.teamUid, this.teamName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.Admin,
            sentByUid: sentByUid);

  InviteAsAdmin.copy(InviteAsAdmin invite)
      : teamName = invite.teamName,
        teamUid = invite.teamUid,
        super.copy(invite);

  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';

  void acceptInvite() {
    UserDatabaseData.instance.updateModel
        .addAdmin(teamUid, UserDatabaseData.instance.userUid);
  }

  InviteAsAdmin.fromJSON(String uid, Map<String, dynamic> data)
      : teamUid = getString(data[TEAMUID]),
        teamName = getString(data[TEAMNAME]),
        super.fromJSON(uid, data);

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
  final String clubName;
  final String clubUid;
  final bool admin;

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

  InviteToClub.copy(InviteToClub invite)
      : clubName = invite.clubName,
        clubUid = invite.clubUid,
        admin = invite.admin,
        super.copy(invite);

  static const String CLUBUID = 'clubUid';
  static const String CLUBNAME = 'clubName';
  static const String ADMIN = 'admin';

  Future<void> acceptInvite() {
    return UserDatabaseData.instance.updateModel
        .addUserToClub(clubUid, UserDatabaseData.instance.userUid, admin);
  }

  InviteToClub.fromJSON(String uid, Map<String, dynamic> data)
      : clubUid = getString(data[CLUBUID]),
        clubName = getString(data[CLUBNAME]),
        admin = getBool(data[ADMIN]),
        super.fromJSON(uid, data);

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
class InviteToLeagueAsAdmin extends Invite {
  final String leagueName;

  /// If this is not null, invite as the league admin/
  final String leagueUid;

  /// If this is not null invite as the divison admin.
  final String leagueDivisonUid;

  /// If this is not null, invite as the season admin.
  final String leagueSeasonUid;

  InviteToLeagueAsAdmin(
      {String sentByUid,
      String email,
      String uid,
      this.leagueDivisonUid,
      this.leagueSeasonUid,
      this.leagueUid,
      this.leagueName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.LeagueAdmin,
            sentByUid: sentByUid) {
    assert((leagueUid != null &&
            leagueDivisonUid == null &&
            leagueSeasonUid == null) ||
        leagueUid == null);
    assert((leagueDivisonUid != null &&
            leagueUid == null &&
            leagueSeasonUid == null) ||
        leagueDivisonUid == null);
    assert((leagueSeasonUid != null &&
            leagueDivisonUid == null &&
            leagueUid == null) ||
        leagueSeasonUid == null);
  }

  InviteToLeagueAsAdmin.copy(InviteToLeagueAsAdmin invite)
      : leagueName = invite.leagueName,
        leagueUid = invite.leagueUid,
        leagueSeasonUid = invite.leagueSeasonUid,
        leagueDivisonUid = invite.leagueDivisonUid,
        super.copy(invite) {}

  static const String LEAGUEUID = 'leagueUid';
  static const String LEAGUESEASONUID = 'leagueSeasonUid';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';
  static const String LEAGUENAME = 'leagueName';

  Future<void> acceptInvite() {
    if (leagueUid != null) {
      return UserDatabaseData.instance.updateModel
          .addUserToLeague(leagueUid, UserDatabaseData.instance.userUid, true);
    }
    if (leagueSeasonUid != null) {
      return UserDatabaseData.instance.updateModel.addUserToLeagueSeason(
          leagueUid, UserDatabaseData.instance.userUid, true);
    }
    if (leagueDivisonUid != null) {
      return UserDatabaseData.instance.updateModel.addUserToLeagueDivison(
          leagueUid, UserDatabaseData.instance.userUid, true);
    }
  }

  InviteToLeagueAsAdmin.fromJSON(String uid, Map<String, dynamic> data)
      : leagueUid = getString(data[LEAGUEUID]),
        leagueName = getString(data[LEAGUENAME]),
        leagueDivisonUid = data[LEAGUEDIVISONUID] ?? "",
        leagueSeasonUid = data[LEAGUESEASONUID] ?? "",
        super.fromJSON(uid, data) {}

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUEUID] = leagueUid;
    ret[LEAGUESEASONUID] = leagueSeasonUid;
    ret[LEAGUEDIVISONUID] = leagueDivisonUid;
    return ret;
  }
}

///
/// Invited to a league team.
///
class InviteToLeagueTeam extends Invite {
  final String leagueName;
  final String leagueTeamName;
  final String leagueTeamUid;
  final String leagueDivisonUid;

  InviteToLeagueTeam(
      {String sentByUid,
      String email,
      String uid,
      this.leagueTeamUid,
      this.leagueDivisonUid,
      this.leagueTeamName,
      this.leagueName})
      : super(
            email: email,
            uid: uid,
            type: InviteType.LeagueTeam,
            sentByUid: sentByUid);

  InviteToLeagueTeam.copy(InviteToLeagueTeam invite)
      : leagueName = invite.leagueName,
        leagueTeamUid = invite.leagueTeamUid,
        leagueDivisonUid = invite.leagueDivisonUid,
        leagueTeamName = invite.leagueTeamName,
        super.copy(invite);

  static const String LEAGUETEAMUID = 'leagueTeamUid';
  static const String LEAGUENAME = 'leagueName';
  static const String LEAGUETEAMNAME = 'leagueTeamName';
  static const String LEAGUEDIVISONUID = 'leagueDivisonUid';

  ///
  /// This accepts the invite connecting the specified team to the matching
  /// season
  ///
  Future<void> acceptInvite(Season season) {
    return UserDatabaseData.instance.updateModel.connectLeagueTeamToSeason(
        leagueTeamUid, UserDatabaseData.instance.userUid, season);
  }

  /// Create a new invite from the json.
  InviteToLeagueTeam.fromJSON(String uid, Map<String, dynamic> data)
      : leagueTeamUid = getString(data[LEAGUETEAMUID]),
        leagueName = getString(data[LEAGUENAME]),
        leagueDivisonUid = data[LEAGUEDIVISONUID] ?? "",
        leagueTeamName = data[LEAGUETEAMNAME] ?? "",
        super.fromJSON(uid, data);

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = super.toJSON();
    ret[LEAGUENAME] = leagueName;
    ret[LEAGUETEAMUID] = leagueTeamUid;
    ret[LEAGUEDIVISONUID] = leagueDivisonUid;
    ret[LEAGUETEAMNAME] = leagueTeamName;
    return ret;
  }
}
