library services.databasedetails;

import 'dart:async';
import 'dart:io';
import 'package:timezone/timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class User {
  String name;
  String phoneNumber;
  String email;
  String relationship;
}

enum RoleInTeam { Player, Coach, NonPlayer }
enum Sport { Basketball, Softball, Soccer, Other }
enum Gender { Female, Male, Coed, NA }
enum EventType { Game, Practice, Event }
enum GameResult { Win, Loss, Tie, Unknown, InProgress }
enum GameInProgress {
  NotStarted,
  First,
  Second,
  Third,
  Fourth,
  Fifth,
  Sixth,
  Seventh,
  Eighth,
  Nineth,
  Tenth,
  Half,
  Final
}
enum UpdateReason { Delete, Update }
enum Attendance { Yes, No, Maybe }

// shared keys.
const String _NAME = 'name';
const String _ARRIVEEARLY = 'arriveEarly';
const String _NOTES = 'notes';
const String _ADDED = 'added';
const String _PHOTOURL = 'photourl';

String getString(dynamic data) {
  if (data == null) {
    return '';
  }
  return data;
}

bool getBool(dynamic data) {
  if (data == null) {
    return false;
  }
  return data;
}

num getNum(dynamic data) {
  if (data == null) {
    return 0;
  }
  return data;
}

class Player {
  String name;
  String uid;
  String photoUrl;

  Player() {}

  Player.copy(Player copy) {
    name = copy.name;
    uid = copy.uid;
    photoUrl = copy.photoUrl;
  }

  // ignore
  StreamSubscription<QuerySnapshot> get snapshot {
    return UserDatabaseData.snapshotMapping[this];
  }

  void fromJSON(Map<String, dynamic> data) {
    name = data[_NAME];
    photoUrl = data[_PHOTOURL];

    // Teams.
    CollectionReference ref = Firestore.instance
        .collection("Seasons")
        .where('players.' + uid + '.' + _ADDED, isEqualTo: true)
        .reference();
    UserDatabaseData.snapshotMapping[this] =
        ref.snapshots.listen(UserDatabaseData.instance._onSeasonUpdated);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = getString(name);
    ret[_PHOTOURL] = getString(photoUrl);
    return ret;
  }

  void close() {
    if (UserDatabaseData.snapshotMapping.containsKey(this)) {
      UserDatabaseData.snapshotMapping[this].cancel();
      UserDatabaseData.snapshotMapping.remove(this);
    }
  }

  void updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection("Players");
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

class GameResultDetails {
  num ptsFor;
  num ptsAgainst;
  GameResult result;
  GameInProgress inProgress;

  GameResultDetails() {
    ptsAgainst = 0;
    ptsFor = 0;
    result = GameResult.Unknown;
  }

  GameResultDetails.copy(GameResultDetails copy) {
    ptsAgainst = copy.ptsAgainst;
    ptsFor = copy.ptsFor;
    result = copy.result;
    inProgress = copy.inProgress;
  }

  static const String _PTS_FOR = 'ptsFor';
  static const String _PTS_AGAINST = 'ptsAgainst';
  static const String _RESULT = 'result';
  static const String _INPROGRESS = 'inProgress';

  void fromJSON(Map<String, dynamic> data) {
    ptsFor = getNum(data[_PTS_FOR]);
    ptsAgainst = getNum(data[_PTS_AGAINST]);
    if (data[_INPROGRESS] == null) {
      inProgress = GameInProgress.NotStarted;
    } else {
      String str = data[_INPROGRESS];
      if (!str.startsWith('GameInProgress')) {
        inProgress = GameInProgress.NotStarted;
      } else {
        inProgress = GameInProgress.values.firstWhere((e) =>
        e.toString() ==
            data[_INPROGRESS]);
      }
    }
    result = GameResult.values.firstWhere((e) => e.toString() == data[_RESULT]);
    if (result == null) {
      result = GameResult.Unknown;
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_PTS_FOR] = ptsFor;
    ret[_PTS_AGAINST] = ptsAgainst;
    ret[_RESULT] = result.toString();
    ret[_INPROGRESS] = inProgress.toString();
    return ret;
  }
}

class GamePlace {
  String name;
  String placeId;
  String address;
  String notes;
  num latitude;
  num longitude;

  GamePlace() {
    latitude = 0;
    longitude = 0;
  }

  GamePlace.copy(GamePlace copy) {
    name = copy.name;
    placeId = copy.placeId;
    address = copy.address;
    notes = copy.notes;
    latitude = copy.latitude;
    longitude = copy.longitude;
  }

  static const String _PLACEID = 'placeId';
  static const String _ADDRESS = 'address';
  static const String _LONGITUDE = 'longitude';
  static const String _LATITUDE = 'latitude';

  void fromJSON(Map<String, dynamic> data) {
    name = getString(data[_NAME]);
    placeId = getString(data[_PLACEID]);
    address = getString(data[_ADDRESS]);
    notes = getString(data[_NOTES]);
    longitude = getNum(data[_LONGITUDE]);
    latitude = getNum(data[_LATITUDE]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = name;
    ret[_PLACEID] = placeId;
    ret[_ADDRESS] = address;
    ret[_NOTES] = notes;
    ret[_LATITUDE] = latitude;
    ret[_LONGITUDE] = longitude;
    return ret;
  }
}

class Game {
  String uid;
  num time;
  String timezone;
  num arriveEarly;
  num gameLength;
  String notes;
  String opponentUid;
  String seasonUid;
  String teamUid;
  String uniform;
  EventType type;
  bool homegame;
  GameResultDetails result;
  GamePlace place;
  Map<String, Attendance> attendance;

  Game() {
    homegame = false;
    attendance = new Map<String, Attendance>();
  }

  Game.copy(Game copy) {
    uid = copy.uid;
    timezone = copy.timezone;
    arriveEarly = copy.arriveEarly;
    gameLength = copy.gameLength;
    notes = copy.notes;
    opponentUid = copy.opponentUid;
    seasonUid = copy.seasonUid;
    teamUid = copy.teamUid;
    uniform = copy.uniform;
    type = copy.type;
    homegame = copy.homegame;
    result = new GameResultDetails.copy(copy.result);
    place = new GamePlace.copy(copy.place);
    attendance = new Map<String, Attendance>.from(copy.attendance);
  }

  Game.newGame(this.type) {
    arriveEarly = 0;
    gameLength = 0;
    result = new GameResultDetails();
    place = new GamePlace();
    attendance = new Map<String, Attendance>();
  }

  TZDateTime get tzTime {
    Location timezone = getLocation(this.timezone);
    return new TZDateTime.fromMillisecondsSinceEpoch(timezone, time);
  }

  TZDateTime get tzArriveTime {
    Location timezone = getLocation(this.timezone);
    return new TZDateTime.fromMillisecondsSinceEpoch(
        timezone, time - arriveEarly * 60000);
  }

  static const String _TIMEZONE = 'timezone';
  static const String _TIME = 'time';
  static const String _GAMELENGTH = 'gameLength';
  static const String _OPPONENTUID = 'opponentUid';
  static const String _SEASONUID = 'seasonUid';
  static const String _UNIFORM = 'uniform';
  static const String _HOMEGAME = 'homegame';
  static const String _TYPE = 'type';
  static const String _RESULT = 'result';
  static const String _PLACE = 'place';
  static const String _ATTENDANCE = 'attendance';
  static const String _ATTENDANCEVALUE = 'value';

  void fromJSON(String teamuid, Map<String, dynamic> data) {
    teamUid = getString(teamuid);
    timezone = getString(data[_TIMEZONE]);
    time = getNum(data[_TIME]);
    arriveEarly = getNum(data[_ARRIVEEARLY]);
     gameLength = getNum(data[_GAMELENGTH]);
     notes = getString(data[_NOTES]);
    opponentUid = getString(data[_OPPONENTUID]);
    seasonUid = getString(data[_SEASONUID]);
    uniform = getString(data[_UNIFORM]);
    homegame = getBool(data[_HOMEGAME]);
     type = EventType.values.firstWhere((e) => e.toString() == data[_TYPE]);
    GameResultDetails details = new GameResultDetails();
    details.fromJSON(data[_RESULT]);
    result = details;
    GamePlace place = new GamePlace();
    place.fromJSON(data[_PLACE]);
    this.place = place;

    print('Update Game ' + uid + ' ${data}');
    // Work out attendance.
    Map<String, Attendance> newAttendanceData = new Map<String, Attendance>();
    Map<String, dynamic> attendanceData = data[_ATTENDANCE];
    if (attendanceData != null) {
      attendanceData.forEach((String key, dynamic data) {
        newAttendanceData[key] = Attendance.values
            .firstWhere((e) => e.toString() == data[_ATTENDANCEVALUE]);
      });
    }
    attendance = newAttendanceData;

    print(toJSON());
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_TYPE] = type.toString();
    ret[_TIMEZONE] = timezone;
    ret[_TIME] = time;
    ret[_ARRIVEEARLY] = arriveEarly;
    ret[_GAMELENGTH] = gameLength;
    ret[_NOTES] = notes;
    ret[_OPPONENTUID] = opponentUid;
    ret[_SEASONUID] = seasonUid;
    ret[_UNIFORM] = uniform;
    ret[_HOMEGAME] = homegame;
    ret[_TYPE] = type.toString();
    ret[_RESULT] = result.toJSON();
    ret[_PLACE] = result.toJSON();
    Map<String, dynamic> attendanceData = new Map<String, dynamic>();
    attendance.forEach((String key, Attendance value) {
      Map<String, dynamic> attendanceInner = new Map<String, dynamic>();
      attendanceInner[_ATTENDANCEVALUE] = value.toString();
      attendanceData[key] = attendanceInner;
    });
    ret[_ATTENDANCE] = attendanceData;

    return ret;
  }

  void close() {}

  void updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance
        .collection("Teams")
        .document(teamUid)
        .getCollection("Games");
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON());
      this.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(uid).updateData(toJSON());
    }
  }

  void updateFirestoreAttendence(String playerUid, Attendance attend) {
    DocumentReference ref = Firestore.instance
        .collection("Teams")
        .document(teamUid)
        .getCollection("Games")
        .document(uid);

    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_ATTENDANCE + "." + playerUid + "." + _ATTENDANCEVALUE] =
        attend.toString();
    ref.updateData(data);
  }


  void updateFirestoreGameResult(GameResultDetails result) {
    DocumentReference ref = Firestore.instance
        .collection("Teams")
        .document(teamUid)
        .getCollection("Games")
        .document(uid);

    Map<String, dynamic> data = new Map<String, dynamic>();
    data[_RESULT] = result.toJSON();
    ref.updateData(data);
  }

}

class WinRecord {
  num win;
  num loss;
  num tie;

  WinRecord() {
    win = 0;
    loss = 0;
    tie = 0;
  }

  WinRecord.copy(WinRecord copy) {
    win = copy.win;
    loss = copy.loss;
    tie = copy.tie;
  }

  static const String _WIN = 'win';
  static const String _LOSS = 'loss';
  static const String _TIE = 'tie';

  void fromJSON(Map<String, dynamic> data) {
    win = getNum(data[_WIN]);
    loss = getNum(data[_LOSS]);
    tie = getNum(data[_TIE]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_TIE] = tie;
    ret[_LOSS] = loss;
    ret[_WIN] = win;
    return ret;
  }
}

class Opponent {
  String name;
  String teamUid;
  String contact;
  String uid;
  WinRecord record;

  Opponent({this.record, this.name, this.teamUid, this.contact, this.uid}) {
    if (record == null) {
      record = new WinRecord();
    }
  }

  Opponent.copy(Opponent copy) {
    name = copy.name;
    teamUid = copy.teamUid;
    contact = copy.contact;
    uid = copy.uid;
    record = copy.record;
  }

  static const String _CONTACT = 'contact';

  void fromJSON(Map<String, dynamic> data) {
    name = getString(data[_NAME]);
    contact = getString(data[_CONTACT]);
    print('Update Opponent ' + uid);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = name;
    ret[_CONTACT] = contact;
    return ret;
  }

  void updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance
        .collection("Teams")
        .document(teamUid)
        .getCollection("Opponents");
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

class SeasonPlayer {
  String playerUid;
  String displayName;
  RoleInTeam role;

  SeasonPlayer({this.playerUid, this.displayName, this.role});

  SeasonPlayer.copy(SeasonPlayer copy) {
    playerUid = copy.playerUid;
    displayName = copy.displayName;
    role = copy.role;
  }

  static const String _ROLE = 'role';

  void fromJSON(Map<String, dynamic> data) {
    role = RoleInTeam.values.firstWhere((e) => e.toString() == data[_ROLE]);
    displayName = getString(data[_NAME]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_ROLE] = role.toString();
    ret[_NAME] = displayName;
    ret[_ADDED] = true;
    return ret;
  }
}

class Season {
  String name;
  String uid;
  String teamUid;
  WinRecord record;
  List<SeasonPlayer> players;

  Season({this.name, this.uid, this.teamUid, this.record, this.players}) {
    if (players == null) {
      players = new List<SeasonPlayer>();
    }
  }

  Season.copy(Season copy) {
    name = copy.name;
    uid = copy.uid;
    teamUid = copy.teamUid;
    record = copy.record;
    players = copy.players;
  }

  Iterable<Game> getGames() {
    // Get all the games for this season.
    return UserDatabaseData.instance.games.values.where((game) {
      return game.teamUid == this.teamUid && game.seasonUid == uid;
    });
  }

  static const String _RECORD = 'record';
  static const String _PLAYERS = 'players';

  void fromJSON(String teamUid, Map<String, dynamic> data) {
    name = getString(data[_NAME]);
    record = new WinRecord();
    record.fromJSON(data[_RECORD]);
    this.record = record;
    this.teamUid = getString(teamUid);
    Map<String, dynamic> playersData = data[_PLAYERS];
    List<SeasonPlayer> newPlayers = new List<SeasonPlayer>();
    playersData.forEach((key, val) {
      SeasonPlayer player = new SeasonPlayer();
      player.playerUid = key;
      player.fromJSON(val);
      newPlayers.add(player);
    });
    players = newPlayers;
    print('Update Season ' + uid);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = name;
    ret[_RECORD] = record.toJSON();
    players.forEach((value) {
      ret[value.playerUid] = value.toJSON();
    });
    return ret;
  }

  void updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection("Seasons");
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
    query.documents.forEach((doc) {
      Opponent opponent;
      if (opponents.containsKey(doc.documentID)) {
        opponent = opponents[doc.documentID];
      } else {
        opponent = new Opponent();
        opponent.uid = doc.documentID;
      }
      opponent.teamUid = this.uid;
      opponent.fromJSON(doc.data);
      opponents[doc.documentID] = opponent;
    });
    _updateThisTeam.add(UpdateReason.Update);
  }

  static const String _CURRENTSEASON = 'currentSeason';
  static const String _LEAGUE = 'league';
  static const String _GENDER = 'gender';
  static const String _SPORT = 'sport';

  void fromJSON(Map<String, dynamic> data) {
    name = getString(data[_NAME]);
    arriveEarly = getNum(data[_ARRIVEEARLY]);
      currentSeason = getString(data[_CURRENTSEASON]);
    league = getString(data[_LEAGUE]);
    photoUrl = getString(data[_PHOTOURL]);
    gender = Gender.values.firstWhere((e) => e.toString() == data[_GENDER]);
    sport = Sport.values.firstWhere((e) => e.toString() == data[_SPORT]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = name;
    ret[_ARRIVEEARLY] = arriveEarly;
    ret[_CURRENTSEASON] = currentSeason;
    ret[_LEAGUE] = league;
    ret[_GENDER] = gender.toString();
    ret[_SPORT] = sport.toString();
    ret[_PHOTOURL] = photoUrl;
    return ret;
  }

  void _onTeamUpdated(DocumentSnapshot snap) {
    fromJSON(snap.data);
    this.uid = snap.documentID;
    print('team ' + uid);
    _updateThisTeam.add(UpdateReason.Update);
  }

  void updateSeason(DocumentSnapshot doc) {
    if (seasons.containsKey(doc.documentID)) {
      seasons[doc.documentID].fromJSON(uid, doc.data);
    } else {
      Season season = new Season();
      season.uid = doc.documentID;
      season.fromJSON(uid, doc.data);
      seasons[doc.documentID] = season;
    }
    _updateThisTeam.add(UpdateReason.Update);
  }

  void setupSnap() {
    if (_teamSnapshot == null) {
      _teamSnapshot = Firestore.instance
          .collection("Teams")
          .document(uid)
          .snapshots
          .listen(this._onTeamUpdated);
    }

    if (_opponentSnapshot == null) {
      CollectionReference opCollection = Firestore.instance
          .collection("Teams")
          .document(uid)
          .getCollection("Opponents");
      _opponentSnapshot =
          opCollection.snapshots.listen(this._onOpponentUpdated);
    }

    if (_gameSnapshot == null) {
      CollectionReference gameCollection = Firestore.instance
          .collection("Teams")
          .document(uid)
          .getCollection("Games");
      _gameSnapshot = gameCollection.snapshots.listen((value) {
        UserDatabaseData.instance._onGameUpdated(this.uid, value);
      });
    }
  }

  void close() {
    _gameSnapshot.cancel();
    _opponentSnapshot.cancel();
    _teamSnapshot.cancel();
    _updateThisTeam.close();
  }

  void updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection("Teams");
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
    print('photurl ${photoUrl}');
    return snapshot.downloadUrl;
  }
}

class UserDatabaseData {
  String _uid;
  Map<String, Player> _players = new Map<String, Player>();
  Map<String, Team> _teams = new Map<String, Team>();
  Map<String, Game> _games = new Map<String, Game>();
  Stream<UpdateReason> teamStream;
  Stream<UpdateReason> gameStream;
  Stream<UpdateReason> playerStream;

  Map<String, Player> get players => _players;

  Map<String, Team> get teams => _teams;

  Map<String, Game> get games => _games;

  StreamController<UpdateReason> _teamController =
      new StreamController<UpdateReason>();
  StreamController<UpdateReason> _playerController =
      new StreamController<UpdateReason>();
  StreamController<UpdateReason> _gameController =
      new StreamController<UpdateReason>();

  // From firebase.
  StreamSubscription<QuerySnapshot> _playerSnapshot;

  static UserDatabaseData _instance;
  static Map<Object, dynamic> snapshotMapping = new Map<Object, dynamic>();

  UserDatabaseData() {
    teamStream = _teamController.stream.asBroadcastStream();
    gameStream = _gameController.stream.asBroadcastStream();
    playerStream = _playerController.stream.asBroadcastStream();
  }

  void _onPlayerUpdated(QuerySnapshot query) {
    query.documents.forEach((doc) {
      if (_players.containsKey(doc.documentID)) {
        _players[doc.documentID].fromJSON(doc.data);
        return;
      }
      Player player = new Player();
      player.uid = doc.documentID;
      // Add in snapshots to find the teams associated with the player.
      player.fromJSON(doc.data);
      _players[player.uid] = player;
      print('player ' + player.uid);
      _playerController.add(UpdateReason.Update);
    });
  }

  void _onSeasonUpdated(QuerySnapshot query) {
    query.documents.forEach((doc) {
      // Get the team from the season.
      String teamUid = doc.data['teamUid'];
      Team team;
      if (_teams.containsKey(teamUid)) {
        team = _teams[teamUid];
        team.uid = teamUid;
      } else {
        team = new Team();
        team.uid = teamUid;
      }
      team.setupSnap();
      team.updateSeason(doc);
      _teams[teamUid] = team;
      _teamController.add(UpdateReason.Update);
    });
  }

  void _onGameUpdated(String teamuid, QuerySnapshot query) {
    query.documents.forEach((doc) {
      Game game;
      if (_games.containsKey(doc.documentID)) {
        game = _games[doc.documentID];
      }
      if (game == null) {
        game = new Game();
        game.uid = doc.documentID;
      }
      game.fromJSON(teamuid, doc.data);
      _games[doc.documentID] = game;
      _gameController.add(UpdateReason.Update);
    });
  }

  static UserDatabaseData get instance {
    if (_instance == null) {
      _instance = new UserDatabaseData();
    }
    return _instance;
  }

  void _setUid(String uid) {
    if (this._uid != uid) {
      close();
    }
    this._uid = uid;
    // The uid everything is based off.
    Query collection = Firestore.instance
        .collection("Players")
        .where("user." + uid + ".added", isEqualTo: true);
    _playerSnapshot = collection.snapshots.listen(this._onPlayerUpdated);
  }

  void close() {
    if (_playerSnapshot != null) {
      _playerSnapshot.cancel();
    }
    _teams.forEach((String key, Team value) {
      value.close();
    });
    _teams.clear();
    _games.forEach((String key, Game value) {
      value.close();
    });
    _games.clear();
    _players.forEach((String key, Player value) {
      value.close();
    });
    _players.clear();
  }

  static void load(String uid) {
    print('loading data');
    instance._setUid(uid);
  }

  static void clear() {
    if (_instance != null) {
      instance.close();
    }
  }
}
