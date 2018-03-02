library services.databasedetails;

import 'dart:async';
import 'package:timezone/standalone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dson/dson.dart';

part 'databasedetails.g.dart';

class User {
  String name;
  String phoneNumber;
  String email;
  String relationship;
}

@serializable
enum RoleInTeam { Player, Coach, NonPlayer }
@serializable
enum Sport { Basketball, Softball, Soccer }
@serializable
enum Gender { Female, Male, Coed, NA }
@serializable
enum EventType { Game, Practice, Event }
@serializable
enum GameResult { Win, Loss, Tie, Unknown }
@serializable
enum UpdateReason { Delete, Update }


@serializable
class Player extends _$PlayerSerializable {
  String name;
  String uid;

  @ignore
  Stream<QuerySnapshot> _snapshot;

  void updateFrom(Map<String, dynamic> data) {
    name = data['name'];

    // Teams.
    CollectionReference ref = Firestore.instance.collection("Seasons")
        .where('players.' + uid + '.added', isEqualTo: true)
        .reference();
    _snapshot = ref.snapshots;
    _snapshot.listen(UserDatabaseData.instance._onSeasonUpdated);
  }
}

@serializable
class GameResultDetails extends _$GameResultDetailsSerializable {
  int ptsFor;
  int ptsAgainst;
  GameResult result;

  void updateFrom(Map<String, dynamic> data) {
    ptsFor = data['ptsFor'];
    ptsAgainst = data['ptsAgainst'];
    result = GameResult.values.firstWhere((e) => e.toString() == data['result']);
  }
}

@serializable
class GamePlace extends _$GamePlaceSerializable {
  String name;
  String placeId;
  String address;
  String notes;


  void updateFrom(Map<String, dynamic> data) {
    name = data['name'];
    placeId = data['placeId'];
    address = data['address'];
    notes = data['notes'];
  }
}

@serializable
class Game extends _$GameSerializable {
  String uid;
  String name;
  TZDateTime time;
  Location timezone;
  int arriveEarly;
  int gameLength;
  String notes;
  String opponentUid;
  String teamUid;
  String uniform;
  EventType type;
  GameResultDetails result;
  GamePlace place;

  void updateFrom(String teamuid, Map<String, dynamic> data) {
    teamUid = teamuid;
    name = data['name'];
    timezone = getLocation(data['timezone']);
    time = new TZDateTime.fromMillisecondsSinceEpoch(timezone, data['time']);
    arriveEarly = data['arriveEarly'];
    gameLength = data['gameLength'];
    notes = data['notes'];
    opponentUid = data['opponentUid'];
    uniform = data['uniform'];
    type = EventType.values.firstWhere((e) => e.toString() == data['type']);
    GameResultDetails details = new GameResultDetails();
    details.updateFrom(data['result']);
    result = details;
    GamePlace place = new GamePlace();
    place.updateFrom(data['place']);
    place = place;
    print('Update Game ' + uid);
  }
}

@serializable
class WinRecord extends _$WinRecordSerializable {
  int win;
  int loss;
  int tie;

  void updateFrom(Map<String, dynamic> data) {
    win = data['win'];
    loss = data['loss'];
    tie = data['tie'];
  }
}

@serializable
class Opponent extends _$OpponentSerializable {
  String name;
  String contact;
  String uid;
  WinRecord record;

  void updateFrom(Map<String, dynamic> data) {
    name = data['name'];
    contact = data['contact'];
    print('Update Opponent ' + uid);

  }
}

@serializable
class SeasonPlayer extends _$SeasonPlayerSerializable {
  String playerUid;
  RoleInTeam role;

  void updateFrom(Map<String, dynamic> data) {
    role = RoleInTeam.values.firstWhere((e) => e.toString() == data['role']);
  }
}

@serializable
class Season extends _$SeasonSerializable {
  String name;
  String uid;
  WinRecord record;
  List<SeasonPlayer> players;

  void updateFrom(Map<String, dynamic> data) {
    name = data['name'];
    record = new WinRecord();
    record.updateFrom(data['record']);
    this.record = record;
    Map<String, dynamic> playersData = data['players'];
    List<SeasonPlayer> newPlayers = new List<SeasonPlayer>();
    playersData.forEach((key, val) {
      SeasonPlayer player = new SeasonPlayer();
      player.playerUid = key;
      player.updateFrom(val);
      newPlayers.add(player);
    });
    players = newPlayers;
    print('Update Season ' + uid);
  }
}

@serializable
class Team extends _$TeamSerializable {
  String name;
  int earlyArrival;
  String currentSeason;
  Gender gender;
  String league;
  Sport sport;
  String uid;
  WinRecord record;

  List<String> admins = new List<String>();
  Map<String, Opponent> opponents = new Map<String, Opponent>();
  Map<String, Season> seasons = new Map<String, Season>();
  @ignore
  Stream<UpdateReason> opponentStream;
  @ignore
  Stream<UpdateReason> thisTeamStream;


  StreamController<UpdateReason> _opponentController = new StreamController<UpdateReason>();
  StreamController<UpdateReason> _updateThisTeam = new StreamController<UpdateReason>();

  // Firebase subscriptions
  StreamSubscription<DocumentSnapshot> _teamSnapshot;
  StreamSubscription<QuerySnapshot> _gameSnapshot;
  StreamSubscription<QuerySnapshot> _opponentSnapshot;


  Team() {
    thisTeamStream = _updateThisTeam.stream.asBroadcastStream();
    opponentStream = _opponentController.stream.asBroadcastStream();
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
      opponent.updateFrom(doc.data);
      opponents[doc.documentID] = opponent;
    });
    _updateThisTeam.add(UpdateReason.Update);
  }

   void _onTeamUpdated(DocumentSnapshot snap) {
    name = snap.data['name'];
    earlyArrival = snap.data['earlyArrival'];
    currentSeason = snap.data['currentSeason'];
    league = snap.data['league'];
    gender = Gender.values.firstWhere((e) => e.toString() == snap.data['gender']);
    sport = Sport.values.firstWhere((e) => e.toString() == snap.data['sport']);

    print('team ' + uid);
    _updateThisTeam.add(UpdateReason.Update);
  }

  void updateSeason(DocumentSnapshot doc) {
    if (seasons.containsKey(doc.documentID)) {
      seasons[doc.documentID].updateFrom(doc.data);
    } else {
      Season season = new Season();
      season.uid = doc.documentID;
      season.updateFrom(doc.data);
      seasons[doc.documentID] = season;
    }
    _updateThisTeam.add(UpdateReason.Update);
  }

  void setupSnap() {
    if (_teamSnapshot == null) {
      _teamSnapshot = Firestore.instance.collection("Teams")
          .document(uid)
          .snapshots
          .listen(this._onTeamUpdated);
    }

    if (_opponentSnapshot == null) {
      CollectionReference opCollection = Firestore.instance
          .collection("Teams")
          .document(uid)
          .getCollection("Oppponents");
      _opponentSnapshot = opCollection.snapshots
          .listen(this._onOpponentUpdated);
    }

    if (_gameSnapshot == null) {
      CollectionReference gameCollection = Firestore.instance
          .collection("Teams")
          .document(uid)
          .getCollection("Games");
      _gameSnapshot = gameCollection.snapshots
          .listen((value) {
        UserDatabaseData.instance._onGameUpdated(this.uid, value);
      });
    }
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

  StreamController<UpdateReason> _teamController = new StreamController<UpdateReason>();
  StreamController<UpdateReason> _playerController = new StreamController<UpdateReason>();
  StreamController<UpdateReason> _gameController = new StreamController<UpdateReason>();
  // From firebase.
  StreamSubscription<QuerySnapshot> _playerSnapshot;

  UserDatabaseData() {
    teamStream = _teamController.stream.asBroadcastStream();
    gameStream = _gameController.stream.asBroadcastStream();
    playerStream = _playerController.stream.asBroadcastStream();
  }

  void _onPlayerUpdated(QuerySnapshot query) {
    query.documents.forEach((doc) {
      if (_players.containsKey(doc.documentID)) {
        _players[doc.documentID].updateFrom(doc.data);
        return;
      }
      Player player = new Player();
      player.uid = doc.documentID;
      // Add in snapshots to find the teams associated with the player.
      player.updateFrom(doc.data);
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

  void  _onGameUpdated(String teamuid, QuerySnapshot query) {
    query.documents.forEach((doc) {
      Game game;
      if (_games.containsKey(doc.documentID)) {
        game = _games[doc.documentID];
      } else {
        game = new Game();
        game.uid = doc.documentID;
      }
      game.updateFrom(teamuid, doc.data);
      _games[doc.documentID] = game;
      _gameController.add(UpdateReason.Update);
    });
  }

  static UserDatabaseData instance;

  void _setUid(String uid) {
    if (this._uid != uid) {
      close();
    }
    this._uid = uid;
    // The uid everything is based off.
    Query collection =
        Firestore.instance.collection("Players")
            .where("user." + uid + ".added", isEqualTo: true);
    _playerSnapshot = collection.snapshots.listen(this._onPlayerUpdated);
  }

  void close() {
    _teams.clear();
    _games.clear();
    _players.clear();
  }

  static void load(String uid) {
    print('loading data');
    instance = new UserDatabaseData();
    instance._setUid(uid);
  }

  static void clear() {
    if (instance != null) {
      instance.close();
    }
    instance = null;
  }
}

void main() {
  _initMirrors();
}