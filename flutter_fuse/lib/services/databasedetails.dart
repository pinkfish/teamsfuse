import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';
export 'package:fusemodel/fusemodel.dart';
import 'authentication.dart';

class FilterDetails {
  Set<String> teamUids = new Set<String>();
  Set<String> playerUids = new Set<String>();
  GameResult result;
  EventType eventType;
  bool allGames = false;
  TZDateTime startDate =
      new TZDateTime.now(local).subtract(new Duration(days: 2));
  TZDateTime endDate = new TZDateTime.now(local).add(new Duration(days: 120));
}

class UserDatabaseData {
  static const num MAX_MESSAGES = 20;

  // User id for us!
  String userUid;

  Map<String, Player> _players = {};
  Map<String, Team> _teams = {};
  Map<String, Game> _games = {};
  Map<String, Invite> _invites = {};
  Map<String, Message> _messages = {};

  Stream<UpdateReason> teamStream;
  Stream<UpdateReason> gameStream;
  Stream<UpdateReason> playerStream;
  Stream<UpdateReason> inviteStream;
  Stream<UpdateReason> messagesStream;

  // Current loading status.
  bool _completedLoading = false;
  bool _loadedPlayers = false;
  bool _loadedTeams = false;
  bool _loadedGames = false;
  bool _loadedInvites = false;
  bool _loadedReadMessages = false;
  bool _loadedUnreadMessages = false;
  bool _createdMePlayer = false;

  Map<String, Player> get players => _players;
  Map<String, Team> get teams => _teams;
  Map<String, Game> get games => _games;
  Map<String, Invite> get invites => _invites;
  Map<String, Message> get messages => _messages;
  int unreadMessageCount = 0;

  bool get loadedDatabase => _completedLoading;
  bool get loadedMessages => _loadedReadMessages && _loadedUnreadMessages;

  StreamController<UpdateReason> _teamController;
  StreamController<UpdateReason> _playerController;
  StreamController<UpdateReason> _gameController;
  StreamController<UpdateReason> _inviteController;
  StreamController<UpdateReason> _messageController;

  // From firebase.
  StreamSubscription<QuerySnapshot> _playerSnapshot;
  StreamSubscription<QuerySnapshot> _inviteSnapshot;
  StreamSubscription<QuerySnapshot> _messageSnapshot;
  StreamSubscription<QuerySnapshot> _readMessageSnapshot;

  static UserDatabaseData _instance;
  static Map<Object, dynamic> snapshotMapping = new Map<Object, dynamic>();

  UserDatabaseData() {
    initStuff();
  }

  void initStuff() {
    _teamController = new StreamController<UpdateReason>();
    _playerController = new StreamController<UpdateReason>();
    _gameController = new StreamController<UpdateReason>();
    _inviteController = new StreamController<UpdateReason>();
    _messageController = new StreamController<UpdateReason>();
    teamStream = _teamController.stream.asBroadcastStream();
    gameStream = _gameController.stream.asBroadcastStream();
    playerStream = _playerController.stream.asBroadcastStream();
    inviteStream = _inviteController.stream.asBroadcastStream();
    messagesStream = _messageController.stream.asBroadcastStream();
  }

  Player get mePlayer {
    return _players.values.firstWhere(
        (Player play) => play.users[userUid].relationship == Relationship.Me);
  }

  Future<Invite> getInvite(String inviteUid) async {
    DocumentSnapshot doc = await Firestore.instance
        .collection(INVITE_COLLECTION)
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

  Future<bool> acceptInvite(Invite inputInvite,
      {String playerUid, String name, Relationship relationship}) async {
    if (inputInvite is InviteToTeam) {
      InviteToTeam invite = inputInvite;
      // We add ourselves to the season.
      DocumentSnapshot doc = await Firestore.instance
          .collection(SEASONS_COLLECTION)
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
    }
    if (inputInvite is InviteToPlayer) {
      InviteToPlayer invite = inputInvite;
      // Add ourselves to the player.
      DocumentSnapshot doc = await Firestore.instance
          .collection(PLAYERS_COLLECTION)
          .document(invite.playerUid)
          .get();
      if (doc.exists) {
        // Yay!  We have a player.
        PlayerUser playerUser =
            new PlayerUser(userUid: userUid, relationship: relationship);
        Map<String, dynamic> data = {};
        data[Player.USERS + "." + userUid] = playerUser.toJSON();
        doc.reference.updateData(data);
        return true;
      }
    }
    return false;
  }

  Future<String> addPlayer(String name, Relationship rel) async {
    // We add ourselves to the season.
    CollectionReference ref = Firestore.instance.collection(PLAYERS_COLLECTION);
    Player player = new Player();
    player.name = name;
    player.users = new Map<String, PlayerUser>();
    player.users[this.userUid] = new PlayerUser();
    player.users[this.userUid].relationship = rel;
    DocumentReference doc = await ref.add(player.toJSON(includeUsers: true));
    return doc.documentID;
  }

  Future<Player> getPlayer(String playerId, {bool withProfile}) async {
    DocumentSnapshot ref = await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(playerId)
        .get();
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
        if (game.result.result != details.result &&
            !(game.result.result == GameResult.Unknown)) {
          print('no result');
          return false;
        }
      }
      if (details.eventType != null) {
        if (details.eventType != game.type) {
          print('not event');
          return false;
        }
      }
      if (!details.allGames) {
        if (game.time > details.endDate.millisecondsSinceEpoch ||
            game.time < details.startDate.millisecondsSinceEpoch) {
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
        "loading $_completedLoading $_loadedPlayers $_loadedGames $_loadedInvites $_loadedTeams");
  }

  void _onPlayerUpdated(QuerySnapshot query) {
    print('_onPlayerUpdated ${query.documents.length}');
    Set<String> toDeletePlayers = new Set<String>();
    SqlData sql = SqlData.instance;
    bool foundMe = false;

    toDeletePlayers.addAll(_players.keys);
    query.documents.forEach((DocumentSnapshot doc) {
      print('here ${doc.documentID}');
      Player player;
      if (_players.containsKey(doc.documentID)) {
        player = _players[doc.documentID];
        player.fromJSON(doc.documentID, doc.data);
        player.setupSnap();
        if (player.users[userUid].relationship == Relationship.Me) {
          if (foundMe) {
            print("Player len ${player.uid}");
            if (player.users.length <= 1) {
              Firestore.instance
                  .collection(PLAYERS_COLLECTION)
                  .document(player.uid)
                  .delete().then((val) {
                print('Deleted ${doc.documentID}');
              });
            }
          }
          foundMe = true;
        }
      } else {
        player = new Player();
        // Add in snapshots to find the teams associated with the player.
        player.fromJSON(doc.documentID, doc.data);
        player.setupSnap();
        _players[player.uid] = player;
        if (player.users[userUid].relationship == Relationship.Me) {
          if (foundMe) {
            print("Player len ${player.users.length}");
            if (player.users.length <= 1) {
              Firestore.instance
                  .collection(PLAYERS_COLLECTION)
                  .document(player.uid)
                  .delete();
            }
          }
          foundMe = true;
        }
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
    if (query.documents.length == 0) {
      if (!foundMe && !_createdMePlayer) {
        print('Docs are empty');
        Player player = new Player();
        player.name = UserAuth.instance.currentUserNoWait().profile.displayName;
        PlayerUser playerUser = new PlayerUser();
        playerUser.userUid = UserAuth.instance.currentUserNoWait().uid;
        playerUser.relationship = Relationship.Me;
        player.users[playerUser.userUid] = playerUser;
        print('Updating firestore');
        _createdMePlayer = true;
        player.updateFirestore(includeUsers: true).then((void val) {
          print('Done!');
          _loadedGames = true;
          _loadedTeams = true;
          _updateLoading();
          _gameController.add(UpdateReason.Update);
        }).catchError((e) {
          print('Print stuff');
          throw e;
        });
      } else {
        print('Loaded for fluff');
        _loadedGames = true;
        _loadedTeams = true;
        _updateLoading();
        _gameController.add(UpdateReason.Update);
      }
    }
    _loadedPlayers = true;
    _updateLoading();
    _playerController.add(UpdateReason.Update);
  }

  void _onUnreadMessagesUpdated(QuerySnapshot query) async {
    SqlData sql = SqlData.instance;

    // Fill in all the messages.
    await Future.forEach(query.documents, (DocumentSnapshot doc) async {
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient();
      recipient.fromJSON(doc.documentID, doc.data);

      if (messages.containsKey(recipient.messageId)) {
        Message mess = messages[recipient.messageId];
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        sql.updateElement(SqlData.MESSAGES_TABLE, doc.documentID,
            mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        DocumentSnapshot ref = await Firestore.instance
            .collection(MESSAGES_COLLECTION)
            .document(recipient.messageId)
            .get();
        if (ref.exists) {
          Message mess = new Message();
          mess.recipients = {};
          mess.fromJSON(ref.documentID, ref.data);
          mess.recipients[recipient.userId] = recipient;
          messages[mess.uid] = mess;
          sql.updateElement(SqlData.MESSAGES_TABLE, doc.documentID,
              mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    });
    unreadMessageCount = query.documents.length;
    query.documentChanges.forEach((DocumentChange change) {
      if (change.type == DocumentChangeType.removed) {
        MessageRecipient rec = new MessageRecipient();
        rec.fromJSON(change.document.documentID, change.document.data);
        messages.remove(rec.messageId);
        sql.deleteElement(SqlData.MESSAGES_TABLE, rec.messageId);
      }
    });
    _loadedUnreadMessages = true;
    print('Loaded unread');
    _messageController.add(UpdateReason.Update);
  }

  void _onReadMessagesUpdated(QuerySnapshot query) async {
    SqlData sql = SqlData.instance;

    await Future.forEach(query.documents, (DocumentSnapshot doc) async {
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient();
      recipient.fromJSON(doc.documentID, doc.data);

      if (messages.containsKey(recipient.messageId)) {
        Message mess = messages[recipient.messageId];
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        sql.updateElement(SqlData.MESSAGES_TABLE, doc.documentID,
            mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        DocumentSnapshot ref = await Firestore.instance
            .collection(MESSAGES_COLLECTION)
            .document(recipient.messageId)
            .get();
        if (ref.exists) {
          Message mess = new Message();
          mess.recipients = {};
          mess.fromJSON(ref.documentID, ref.data);
          mess.recipients[recipient.userId] = recipient;
          messages[mess.uid] = mess;
          sql.updateElement(SqlData.MESSAGES_TABLE, doc.documentID,
              mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    });
    query.documentChanges.forEach((DocumentChange change) {
      if (change.type == DocumentChangeType.removed) {
        MessageRecipient rec = new MessageRecipient();
        rec.fromJSON(change.document.documentID, change.document.data);
        messages.remove(rec.messageId);
        sql.deleteElement(SqlData.MESSAGES_TABLE, rec.messageId);
      }
    });
    unreadMessageCount = messages.keys
        .where((String key) =>
            messages[key].recipients[userUid].state == MessageState.Unread)
        .length;
    _loadedReadMessages = true;
    print('Loaded read');
    _messageController.add(UpdateReason.Update);
  }

  void onSeasonUpdated(QuerySnapshot query) async {
    Set<String> toDeleteSeasons;
    String teamUid;
    SqlData sql = SqlData.instance;

    await Future.forEach(query.documents, (DocumentSnapshot doc) async {
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
      team.updateSeason(doc.documentID, doc.data);
      toDeleteSeasons.remove(doc.documentID);
      return team.setupSnap().then((dynamic n) async {
        _teams[teamUid] = team;
      });
    }).then((e) {
      _loadedTeams = true;
      if (_teams.length == 0) {
        _loadedGames = true;
        _updateLoading();
        _gameController.add(UpdateReason.Update);
      } else {
        _updateLoading();
      }
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
      Invite invite = Invite.makeInviteFromJSON(doc.documentID, doc.data);
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
    if (_teamController == null) {
      initStuff();
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

      data = await sql.getAllElements(SqlData.MESSAGES_TABLE);
      Map<String, Message> newMessages = {};
      data.forEach((String uid, Map<String, dynamic> input) {
        Message mess = new Message();
        print("fluff $uid ${mess.teamUid}");
        mess.fromJSON(uid, input);
        newMessages[uid] = mess;
      });
      _messages = newMessages;
      unreadMessageCount = _messages.keys
          .where((String key) =>
              _messages[key].recipients[userUid].state == MessageState.Unread)
          .length;
      _messageController.add(UpdateReason.Update);
    } catch (e) {
      // Any exception and we cleanup all the data to nothing.
      print('Caught exception $e');
      print(e.stackTrace.toString());
      _games.clear();
      _teams.clear();
      _invites.clear();
      _players.clear();
    }

    this.userUid = uid;
    // The uid everything is based off.
    Query collection = Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .where(Player.USERS + "." + uid + "." + ADDED, isEqualTo: true);
    _playerSnapshot = collection.snapshots.listen(this._onPlayerUpdated);

    print('getting invites');
    Query inviteCollection = Firestore.instance
        .collection(INVITE_COLLECTION)
        .where(Invite.EMAIL, isEqualTo: normalizeEmail(email));
    inviteCollection.getDocuments().then((QuerySnapshot query) {
      print("Got some invites ${query.documents.length}");
      this._onInviteUpdated(query);
    });
    _inviteSnapshot = inviteCollection.snapshots.listen(this._onInviteUpdated);

    Query unreadQuery = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .where(MessageRecipient.USERID, isEqualTo: uid)
        .where(MessageRecipient.STATE,
            isEqualTo: MessageState.Unread.toString());
    unreadQuery.getDocuments().then((QuerySnapshot results) {
      print("Got some messages $results");
      this._onUnreadMessagesUpdated(results);
    });
    _messageSnapshot =
        unreadQuery.snapshots.listen(this._onUnreadMessagesUpdated);
    Query readQuery = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .where(MessageRecipient.USERID, isEqualTo: uid)
        .orderBy(MessageRecipient.SENTAT)
        .limit(MAX_MESSAGES);
    readQuery.getDocuments().then((QuerySnapshot results) {
      print("Got some read $results");
      this._onReadMessagesUpdated(results);
    });
    _readMessageSnapshot =
        readQuery.snapshots.listen(this._onReadMessagesUpdated);
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
    if (_messageSnapshot != null) {
      _messageSnapshot.cancel();
      _messageSnapshot = null;
    }
    if (_readMessageSnapshot != null) {
      _readMessageSnapshot.cancel();
      _readMessageSnapshot = null;
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
    if (_messageController != null) {
      _messageController.close();
      _messageController = null;
      messagesStream = null;
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
    _createdMePlayer = false;
  }

  void deletePersistentData() {
    SqlData.instance.dropDatabase();
  }

  static void load(String uid, String email) {
    instance._setUid(uid, email);
  }

  static void clear() {
    if (_instance != null) {
      instance.deletePersistentData();
      instance.close();
    }
  }
}
