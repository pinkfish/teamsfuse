import 'dart:async';
import 'dart:io';

import 'common.dart';
import 'season.dart';
import 'winrecord.dart';
import 'game.dart';
import 'base.dart';
import 'player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Sport { Basketball, Softball, Soccer, Other }
enum Gender { Female, Male, Coed, NA }

class Opponent {
  String name;
  String teamUid;
  String contact;
  String uid;
  Map<String, WinRecord> record;

  Opponent({this.record, this.name, this.teamUid, this.contact, this.uid}) {
    if (record == null) {
      record = new Map<String, WinRecord>();
    }
  }

  Opponent.copy(Opponent copy) {
    name = copy.name;
    teamUid = copy.teamUid;
    contact = copy.contact;
    uid = copy.uid;
    record = new Map<String, WinRecord>.from(copy.record);
  }

  static const String _CONTACT = 'contact';
  static const String _SEASONS = 'seasons';

  void fromJSON(String uid, String teamUid, Map<String, dynamic> data) {
    this.uid = uid;
    this.teamUid = teamUid;
    name = getString(data[NAME]);
    contact = getString(data[_CONTACT]);
    Map<String, WinRecord> newRecord = new Map<String, WinRecord>();
    if (data[_SEASONS] != null) {
      Map<String, dynamic> innerSeason = data[_SEASONS];
      // Load the seasons.
      innerSeason.forEach((String seasonUid, dynamic value) {
        WinRecord newData = new WinRecord();
        newData.fromJSON(value);
        newRecord[seasonUid] = newData;
      });
    }
    record = newRecord;
    print('Update Opponent ' + uid);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[_CONTACT] = contact;
    Map<String, dynamic> recordSection = new Map<String, dynamic>();
    record.forEach((String key, WinRecord record) {
      recordSection[key] = record.toJSON();
    });
    ret[_SEASONS] = recordSection;
    return ret;
  }

  Future<void> updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .getCollection(OPPONENT_COLLECTION);
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON());
      this.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(uid).updateData(toJSON());
    }
  }
}

class Team {
  String name;
  num arriveEarly;
  String currentSeason;
  Gender gender;
  String league;
  Sport sport;
  String uid;
  String photoUrl;

  List<String> admins = new List<String>();
  Map<String, Opponent> opponents = new Map<String, Opponent>();
  Map<String, Season> seasons = new Map<String, Season>();

  Stream<UpdateReason> opponentStream;
  Stream<UpdateReason> thisTeamStream;

  StreamController<UpdateReason> _updateThisTeam =
      new StreamController<UpdateReason>();

  // Firebase subscriptions
  StreamSubscription<DocumentSnapshot> _teamSnapshot;
  StreamSubscription<QuerySnapshot> _gameSnapshot;
  StreamSubscription<QuerySnapshot> _opponentSnapshot;

  Team(
      {this.name,
      this.arriveEarly: 0,
      this.currentSeason,
      this.gender: Gender.NA,
      this.league,
      this.sport: Sport.Other,
      this.uid,
      this.photoUrl}) {
    thisTeamStream = _updateThisTeam.stream.asBroadcastStream();
  }

  Team.copy(Team copy) {
    name = copy.name;
    arriveEarly = copy.arriveEarly;
    currentSeason = copy.currentSeason;
    gender = copy.gender;
    league = copy.league;
    sport = copy.sport;
    uid = copy.uid;
    photoUrl = copy.photoUrl;
    admins = new List<String>.from(admins);
    opponents = opponents.map((String key, Opponent op) {
      return new MapEntry(key, new Opponent.copy(op));
    });
    seasons = seasons.map((String key, Season season) {
      return new MapEntry(key, new Season.copy(season));
    });
  }

  void _onOpponentUpdated(QuerySnapshot query) {
    Set<String> toDeleteOpponents = new Set<String>();
    SqlData sql = SqlData.instance;

    toDeleteOpponents.addAll(opponents.keys);
    query.documents.forEach((doc) {
      Opponent opponent;
      if (opponents.containsKey(doc.documentID)) {
        opponent = opponents[doc.documentID];
      } else {
        opponent = new Opponent();
      }
      opponent.fromJSON(doc.documentID, uid, doc.data);
      opponents[doc.documentID] = opponent;
      toDeleteOpponents.remove(doc.documentID);
      sql.updateTeamElement(
          SqlData.OPPONENTS_TABLE, doc.documentID, uid, toJSON());
    });
    toDeleteOpponents.forEach((String id) {
      sql.deleteElement(SqlData.OPPONENTS_TABLE, id);
      opponents.remove(id);
    });
    _updateThisTeam.add(UpdateReason.Update);
  }

  static const String _CURRENTSEASON = 'currentSeason';
  static const String _LEAGUE = 'league';
  static const String _GENDER = 'gender';
  static const String _SPORT = 'sport';
  static const String _ADMINS = 'admins';

  void fromJSON(String teamUid, Map<String, dynamic> data) {
    uid = teamUid;
    name = getString(data[NAME]);
    arriveEarly = getNum(data[ARRIVALTIME]);
    currentSeason = getString(data[_CURRENTSEASON]);
    league = getString(data[_LEAGUE]);
    photoUrl = getString(data[PHOTOURL]);
    gender = Gender.values.firstWhere((e) => e.toString() == data[_GENDER]);
    sport = Sport.values.firstWhere((e) => e.toString() == data[_SPORT]);
    if (data[_ADMINS] != null) {
      List<String> newAdmin = new List<String>();
      data[_ADMINS].forEach((String key, bool data) {
        if (data) {
          newAdmin.add(key);
        }
      });
      admins = newAdmin;
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[ARRIVALTIME] = arriveEarly;
    ret[_CURRENTSEASON] = currentSeason;
    ret[_LEAGUE] = league;
    ret[_GENDER] = gender.toString();
    ret[_SPORT] = sport.toString();
    ret[PHOTOURL] = photoUrl;
    Map<String, bool> adminMap = new Map<String, bool>();
    admins.forEach((String key) {
      adminMap[key] = true;
    });
    ret[_ADMINS] = adminMap;
    return ret;
  }

  void _onTeamUpdated(DocumentSnapshot snap) {
    fromJSON(snap.documentID, snap.data);
    print('team ' + uid);
    _updateThisTeam.add(UpdateReason.Update);
    SqlData.instance.updateElement(SqlData.TEAMS_TABLE, uid, toJSON());
  }

  void updateSeason(DocumentSnapshot doc) {
    Season season;
    if (seasons.containsKey(doc.documentID)) {
      season = seasons[doc.documentID];
      season.fromJSON(doc.documentID, doc.data);
    } else {
      season = new Season();
      season.fromJSON(doc.documentID, doc.data);
      seasons[doc.documentID] = season;
    }
    SqlData.instance.updateElement(SqlData.SEASON_TABLE, doc.documentID,
        season.toJSON(includePlayers: true));
    _updateThisTeam.add(UpdateReason.Update);
  }

  Future<void> setupSnap() async {
    if (_teamSnapshot == null) {
      _teamSnapshot = Firestore.instance
          .collection(TEAMS_COLLECTION)
          .document(uid)
          .snapshots
          .listen(this._onTeamUpdated);
    }

    if (_opponentSnapshot == null) {
      CollectionReference opCollection = Firestore.instance
          .collection(TEAMS_COLLECTION)
          .document(uid)
          .getCollection(OPPONENT_COLLECTION);
      QuerySnapshot query = await opCollection.getDocuments();

      this._onOpponentUpdated(query);
      _opponentSnapshot =
          opCollection.snapshots.listen(this._onOpponentUpdated);
    }

    if (_gameSnapshot == null) {
      Query gameQuery = Firestore.instance
          .collection(GAMES_COLLECTION)
          .where(Game.TEAMUID, isEqualTo: uid);
      QuerySnapshot query = await gameQuery.getDocuments();
      UserDatabaseData.instance.onGameUpdated(this.uid, query);
      _gameSnapshot = gameQuery.snapshots.listen((value) {
        UserDatabaseData.instance.onGameUpdated(this.uid, value);
      });
    }
  }

  void loadOpponents() async {
    Map<String, Map<String, dynamic>> opps =
        await SqlData.instance.getAllTeamElements(SqlData.OPPONENTS_TABLE, uid);

    Map<String, Opponent> ops = new Map<String, Opponent>();
    opps.forEach((String opUid, Map<String, dynamic> data) {
      Opponent op = new Opponent();
      op.fromJSON(opUid, uid, data);
      ops[opUid] = op;
    });
    this.opponents = ops;
  }

  void close() {
    _gameSnapshot.cancel();
    _opponentSnapshot.cancel();
    _teamSnapshot.cancel();
    _updateThisTeam.close();
    seasons.forEach((String key, Season season) {
      season.close();
    });
    seasons.clear();
    opponents.clear();
    admins.clear();
  }

  Future<void> updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(TEAMS_COLLECTION);
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON());
      this.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(uid).updateData(toJSON());
    }
  }

  Future<Uri> updateImage(File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("team_" + uid + ".img");
    final StorageUploadTask task = ref.put(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    this.photoUrl = snapshot.downloadUrl.toString();
    print('photurl $photoUrl');
    return snapshot.downloadUrl;
  }

  // Is one of the players associated with this user an admin?
  bool isAdmin() {
    bool ret = false;
    UserDatabaseData.instance.players.forEach((String uid, Player plauyer) {
      if (admins.any((String myUid) {
        return myUid == uid;
      })) {
        ret = true;
      }
    });
    return ret;
  }
}
