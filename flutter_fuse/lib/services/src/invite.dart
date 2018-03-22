import 'dart:async';
import 'common.dart';
import 'season.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invite {
  String email;
  String uid;
  String teamName;
  String seasonName;
  String teamUid;
  String seasonUid;
  String sentByUid;
  RoleInTeam role;
  List<String> playerName;

  Invite(
      {this.email,
      this.uid,
      this.teamUid,
      this.teamName,
      this.seasonName,
      this.seasonUid,
      this.sentByUid,
      this.playerName});

  Invite.copy(Invite invite) {
    teamName = invite.teamName;
    seasonName = invite.seasonName;
    teamUid = invite.teamUid;
    seasonUid = invite.seasonUid;
    uid = invite.uid;
    sentByUid = invite.sentByUid;
    email = invite.email;
    playerName = new List<String>.from(invite.playerName);
    role = invite.role;
  }

  static const String EMAIL = 'email';
  static const String TEAMUID = 'teamUid';
  static const String TEAMNAME = 'teamName';
  static const String SEASONNAME = 'seasonName';
  static const String SEASONUID = 'seasonUid';
  static const String SENTBYUID = 'sentbyUid';
  static const String ROLE = 'role';

  void fromJSON(String uid, Map<String, dynamic> data) {
    email = getString(data[EMAIL]);
    this.uid = uid;
    teamUid = getString(data[TEAMUID]);
    playerName = data[NAME];
    if (playerName == null) {
      playerName = new List<String>();
    }
    seasonUid = getString(data[SEASONUID]);
    sentByUid = getString(data[SENTBYUID]);
    teamName = getString(data[TEAMNAME]);
    seasonName = getString(data[SEASONNAME]);
    try {
      role = RoleInTeam.values.firstWhere((e) => e.toString() == data[ROLE]);
    } catch (e) {
      role = RoleInTeam.NonPlayer;
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[EMAIL] = email;
    ret[TEAMUID] = teamUid;
    ret[SEASONUID] = seasonUid;
    ret[NAME] = playerName;
    ret[SENTBYUID] = sentByUid;
    ret[TEAMNAME] = teamName;
    ret[SEASONNAME] = seasonName;
    ret[ROLE] = role;
    return ret;
  }

  Future<void> firestoreDelete() {
    return Firestore.instance.collection("Invites").document(uid).delete();
  }
}
