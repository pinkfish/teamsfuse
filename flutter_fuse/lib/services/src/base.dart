import 'game.dart';
import 'message.dart';
import 'player.dart';
import 'season.dart';
import 'common.dart';
import 'invite.dart';
import 'team.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';



class FilterDetails {
  Set<String> teamUids = new Set<String>();
  Set<String> playerUids = new Set<String>();
  GameResult result;
  EventType eventType;
  bool allGames = true;
  TZDateTime startDate = new TZDateTime.now(local);
  TZDateTime endDate = new TZDateTime.now(local).add(new Duration(days: 30));
}


class UserDatabaseData {
  String userUid;
  Map<String, Player> _players = new Map<String, Player>();
  Map<String, Team> _teams = new Map<String, Team>();
  Map<String, Game> _games = new Map<String, Game>();
  Map<String, Invite> _invites = new Map<String, Invite>();

  Stream<UpdateReason> teamStream;
  Stream<UpdateReason> gameStream;
  Stream<UpdateReason> playerStream;
  Stream<UpdateReason> inviteStream;

  bool _completedLoading = false;
  bool _loadedPlayers = false;
  bool _loadedTeams = false;
  bool _loadedGames = false;
  bool _loadedInvites = false;

  Map<String, Player> get players => _players;
  Map<String, Team> get teams => _teams;
  Map<String, Game> get games => _games;
  Map<String, Invite> get invites => _invites;

  bool get loading => _completedLoading;

  StreamController<UpdateReason> _teamController =
  new StreamController<UpdateReason>();
  StreamController<UpdateReason> _playerController =
  new StreamController<UpdateReason>();
  StreamController<UpdateReason> _gameController =
  new StreamController<UpdateReason>();
  StreamController<UpdateReason> _inviteController =
  new StreamController<UpdateReason>();

  // From firebase.
  StreamSubscription<QuerySnapshot> _playerSnapshot;
  StreamSubscription<QuerySnapshot> _inviteSnapshot;

  static UserDatabaseData _instance;
  static Map<Object, dynamic> snapshotMapping = new Map<Object, dynamic>();

  UserDatabaseData() {
    initStuff();
  }

  void initStuff() {
    teamStream = _teamController.stream.asBroadcastStream();
    gameStream = _gameController.stream.asBroadcastStream();
    playerStream = _playerController.stream.asBroadcastStream();
    inviteStream = _inviteController.stream.asBroadcastStream();
  }

  Future<Invite> getInvite(String inviteUid) async {
    DocumentSnapshot doc = await Firestore.instance
        .collection("Invites")
        .document(inviteUid)
        .get();
    Invite invite = new Invite();
    if (doc.exists) {
      invite.fromJSON(doc.documentID, doc.data);
      return invite;
    } else {
      _invites.remove(invite.uid);
      _inviteController.add(UpdateReason.Update);
    }
    return null;
  }

  Future<bool> acceptInvite(
      Invite invite, String playerUid, String name) async {
    // We add ourselves to the season.
    DocumentSnapshot doc = await Firestore.instance
        .collection("Seasons")
        .document(invite.seasonUid)
        .get();
    if (doc.exists) {
      // Update it!  First we add to the player.
      Map<String, dynamic> data = new Map<String, dynamic>();
      SeasonPlayer seasonPlayer = new SeasonPlayer(
          playerUid: playerUid, displayName: name, role: invite.role);
      data[Season.PLAYERS + "." + playerUid] = seasonPlayer.toJSON();
      doc.reference.updateData(data);
      return true;
    }
    return false;
  }

  Future<String> addPlayer(String name, Relationship rel) async {
    // We add ourselves to the season.
    CollectionReference ref = Firestore.instance.collection("Players");
    Player player = new Player();
    player.name = name;
    player.users = new Map<String, PlayerUser>();
    player.users[this.userUid] = new PlayerUser();
    player.users[this.userUid].relationship = rel;
    DocumentReference doc = await ref.add(player.toJSON(includeUsers: true));
    return doc.documentID;
  }

  Future<Player> getPlayer(String playerId, {bool withProfile}) async {
    DocumentSnapshot ref =
    await Firestore.instance.collection("Players").document(playerId).get();
    if (ref.exists) {
      Player player = new Player();
      player.fromJSON(playerId, ref.data);
      // Fill in all the user data.
      if (withProfile) {
        await Future.forEach(player.users.values, (PlayerUser user) async {
          return user.getProfile();
        });
      }
      return player;
    }
    print('No player $playerId');
    return null;
  }

  // Filter the games down.
  Future<Iterable<Game>> getGames(FilterDetails details) async {
    // Do the time range with the filter, or if no time range then
    // the team filter.  Do the rest in code.
    // Filter the games locally.
    return games.values.where((Game game) {
      if (details.teamUids.length != 0) {
        if (!details.teamUids.contains(game.teamUid)) {
          return false;
        }
      }
      if (details.playerUids.length > 0) {
        Season season = UserDatabaseData
            .instance.teams[game.teamUid].seasons[game.seasonUid];

        if (!details.playerUids
            .any((String str) => season.players.contains(str))) {
          print('Not player');
          return false;
        }
      }
      if (details.result != null) {
        if (game.result != details.result &&
            !(game.result == GameResult.InProgress &&
                details.result == GameResult.Unknown)) {
          print('not result');
          return false;
        }
      }
      if (details.eventType != null) {
        if (details.eventType != game.type) {
          print ('not event');
          return false;
        }
      }
      if (!details.allGames) {
        if (game.time < details.endDate.millisecondsSinceEpoch && game.time > details.startDate.millisecondsSinceEpoch) {
          print('not in range');
          return false;
        }
      }
      return true;
    });
  }

  void _updateLoading() {
    _completedLoading =
        _loadedPlayers && _loadedGames && _loadedInvites && _loadedTeams;
    print(
        "Loading! $_completedLoading} ${_loadedPlayers} ${_loadedTeams} ${_loadedInvites} ${_loadedGames}");
  }

  void _onPlayerUpdated(QuerySnapshot query) {
    Set<String> toDeletePlayers = new Set<String>();
    SqlData sql = SqlData.instance;

    toDeletePlayers.addAll(_players.keys);
    query.documents.forEach((doc) {
      Player player;
      if (_players.containsKey(doc.documentID)) {
        player = _players[doc.documentID];
        player.fromJSON(doc.documentID, doc.data);
        player.setupSnap();
      } else {
        player = new Player();
        // Add in snapshots to find the teams associated with the player.
        player.fromJSON(doc.documentID, doc.data);
        player.setupSnap();
        _players[player.uid] = player;
        print('player ' + player.uid);
      }
      toDeletePlayers.remove(doc.documentID);
      sql.updateElement(
          SqlData.PLAYERS_TABLE, player.uid, player.toJSON(includeUsers: true));
    });
    toDeletePlayers.forEach((String id) {
      _players.remove(id);
      sql.deleteElement(SqlData.PLAYERS_TABLE, id);
    });
    _loadedPlayers = true;
    _updateLoading();
    _playerController.add(UpdateReason.Update);
  }

  void onSeasonUpdated(QuerySnapshot query) {
    Set<String> toDeleteSeasons;
    String teamUid;
    SqlData sql = SqlData.instance;

    Future.forEach(query.documents, (doc) async {
      // Get the team from the season.
      teamUid = doc.data[Season.TEAMUID];
      Team team;
      if (_teams.containsKey(teamUid)) {
        team = _teams[teamUid];
        team.uid = teamUid;
      } else {
        team = new Team();
        team.uid = teamUid;
      }
      if (toDeleteSeasons == null) {
        toDeleteSeasons = new Set<String>();
        toDeleteSeasons.addAll(team.seasons.keys);
      }
      team.updateSeason(doc);
      toDeleteSeasons.remove(doc.documentID);
      return team.setupSnap().then((Null) async {
        _teams[teamUid] = team;
      });
    }).then((e) {
      _loadedTeams = true;
      _updateLoading();
    });
    if (toDeleteSeasons != null) {
      toDeleteSeasons.forEach((String id) {
        _teams[teamUid].seasons.remove(id);
        sql.deleteElement(SqlData.SEASON_TABLE, id);
      });
    }
    _teamController.add(UpdateReason.Update);
  }

  void onGameUpdated(String teamuid, QuerySnapshot query) {
    // See if anything got deleted.
    Set<String> toDeleteGames = new Set();
    SqlData sql = SqlData.instance;

    toDeleteGames.addAll(
        _games.keys.where((String id) => _games[id].teamUid == teamuid));
    query.documents.forEach((doc) {
      Game game;
      if (_games.containsKey(doc.documentID)) {
        game = _games[doc.documentID];
      }
      if (game == null) {
        game = new Game();
      }
      game.fromJSON(doc.documentID, doc.data);
      _games[doc.documentID] = game;
      toDeleteGames.remove(doc.documentID);
      sql.updateElement(SqlData.GAME_TABLE, doc.documentID, game.toJSON());
    });
    toDeleteGames.forEach((String id) {
      _games.remove(id);
      sql.deleteElement(SqlData.GAME_TABLE, id);
    });
    _loadedGames = true;
    _updateLoading();
    _gameController.add(UpdateReason.Update);
  }

  void _onInviteUpdated(QuerySnapshot query) {
    Map<String, Invite> newInvites = new Map<String, Invite>();
    SqlData sql = SqlData.instance;

    // Completely clear the invite table.
    sql.clearTable(SqlData.INVITES_TABLE);
    query.documents.forEach((DocumentSnapshot doc) {
      String uid = doc.documentID;
      Invite invite = new Invite();
      invite.fromJSON(uid, doc.data);
      newInvites[uid] = invite;
      sql.updateElement(SqlData.INVITES_TABLE, uid, invite.toJSON());
    });
    _invites = newInvites;
    _loadedInvites = true;
    _updateLoading();
    _inviteController.add(UpdateReason.Update);
  }

  static UserDatabaseData get instance {
    if (_instance == null) {
      _instance = new UserDatabaseData();
    }
    return _instance;
  }

  void _setUid(String uid, String email) async {
    _completedLoading = false;
    if (this.userUid != uid && this.userUid != null) {
      close();
      initStuff();
      print('Updating uid to $uid dropping database');
      SqlData.instance.dropDatabase();
    }
    // Load from SQL first.
    try {
      SqlData sql = SqlData.instance;
      Map<String, Map<String, dynamic>> data =
      await sql.getAllElements(SqlData.TEAMS_TABLE);
      Map<String, Team> newTeams = new Map<String, Team>();
      await Future.forEach(data.keys, (String uid) {
        Map<String, dynamic> input = data[uid];
        Team team = new Team();
        team.fromJSON(uid, input);
        team.setupSnap();
        // Load opponents.
        newTeams[uid] = team;
        return team.loadOpponents();
      });
      _teams = newTeams;
      _teamController.add(UpdateReason.Update);

      data = await sql.getAllElements(SqlData.PLAYERS_TABLE);
      Map<String, Player> newPlayers = new Map<String, Player>();
      data.forEach((String uid, Map<String, dynamic> input) {
        Player player = new Player();
        player.fromJSON(uid, input);
        newPlayers[uid] = player;
      });
      _players = newPlayers;
      _playerController.add(UpdateReason.Update);

      data = await sql.getAllElements(SqlData.GAME_TABLE);
      Map<String, Game> newGames = new Map<String, Game>();
      data.forEach((String uid, Map<String, dynamic> input) {
        Game game = new Game();
        game.fromJSON(uid, input);
        newGames[uid] = game;
      });
      _games = newGames;
      _gameController.add(UpdateReason.Update);

      data = await sql.getAllElements(SqlData.INVITES_TABLE);
      Map<String, Invite> newInvites = new Map<String, Invite>();
      data.forEach((String uid, Map<String, dynamic> input) {
        Invite invite = new Invite();
        invite.fromJSON(uid, input);
        newInvites[uid] = invite;
      });
      _invites = newInvites;
      _inviteController.add(UpdateReason.Update);
    } catch (e) {
      // Any exception and we cleanup all the data to nothing.
      print('Caught exception $e');
      _games.clear();
      _teams.clear();
      _invites.clear();
      _players.clear();
    }

    this.userUid = uid;
    // The uid everything is based off.
    Query collection = Firestore.instance
        .collection("Players")
        .where(Player.USERS + "." + uid + "." + ADDED, isEqualTo: true);
    _playerSnapshot = collection.snapshots.listen(this._onPlayerUpdated);
    Query inviteCollection = Firestore.instance
        .collection("Invites")
        .where(Invite.EMAIL, isEqualTo: email);
    inviteCollection.getDocuments().then((QuerySnapshot query) {
      this._onInviteUpdated(query);
    });
    _inviteSnapshot = inviteCollection.snapshots.listen(this._onInviteUpdated);
  }

  void close() {
    _completedLoading = false;
    if (_playerSnapshot != null) {
      _playerSnapshot.cancel();
      _playerSnapshot = null;
      playerStream = null;
    }
    if (_inviteSnapshot != null) {
      _inviteSnapshot.cancel();
      _inviteSnapshot = null;
      inviteStream = null;
    }
    if (_teamController != null) {
      _teamController.close();
      teamStream = null;
      _teamController = null;
    }
    if (_playerController != null) {
      _playerController.close();
      playerStream = null;
      _playerController = null;
    }
    if (_inviteController != null) {
      _inviteController.close();
      inviteStream = null;
      _inviteController = null;
    }
    if (_gameController != null) {
      _gameController.close();
      _gameController = null;
      gameStream = null;
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
    _invites.clear();
  }

  static void load(String uid, String email) {
    print('loading data');
    instance._setUid(uid, email);
  }

  static void clear() {
    if (_instance != null) {
      instance.close();
    }
  }
}
