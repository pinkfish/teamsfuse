import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'persistendata.dart';
import 'loggingdata.dart';
import 'analytics.dart';
import 'fusederrordetails.dart';
import 'club.dart';
import 'firestore/authentication.dart';
import 'firestore/databaseupdatemodelimpl.dart';
import 'firestore/firestore.dart';

class UserDatabaseData {
  static const num MAX_MESSAGES = 20;

  // User id for us!
  String userUid;

  Map<String, Player> _players = {};
  Map<String, Team> _teams = {};
  Map<String, Game> _gamesCache = {};
  Map<String, Invite> _invites = {};
  Map<String, Message> _messages = {};
  Map<String, Club> _clubs = {};

  Stream<UpdateReason> teamStream;
  Stream<UpdateReason> playerStream;
  Stream<UpdateReason> inviteStream;
  Stream<UpdateReason> messagesStream;
  Stream<UpdateReason> clubStream;

  // Current loading status.
  bool _completedLoading = false;
  bool _loadedPlayers = false;
  bool _loadedTeams = false;
  bool _loadedGames = false;
  bool _loadedInvites = false;
  bool _loadedReadMessages = false;
  bool _loadedUnreadMessages = false;
  bool _loadedClubs = false;
  bool _createdMePlayer = false;
  bool _loadedFromSql = false;

  Map<String, Player> get players => _players;
  Map<String, Team> get teams => _teams;
  Map<String, Game> get gamesCache => _gamesCache;
  Map<String, Invite> get invites => _invites;
  Map<String, Message> get messages => _messages;
  Map<String, Club> get clubs => _clubs;
  int unreadMessageCount = 0;

  bool get loadedDatabase => _completedLoading;
  bool get loadedMessages => _loadedReadMessages && _loadedUnreadMessages;
  bool get loadedFromSQL => _loadedFromSql;

  StreamController<UpdateReason> _teamController;
  StreamController<UpdateReason> _playerController;
  StreamController<UpdateReason> _inviteController;
  StreamController<UpdateReason> _messageController;
  StreamController<UpdateReason> _clubController;

  // From firebase.
  StreamSubscription<FirestoreChangedData> _playerSnapshot;
  StreamSubscription<FirestoreChangedData> _inviteSnapshot;
  StreamSubscription<FirestoreChangedData> _messageSnapshot;
  StreamSubscription<FirestoreChangedData> _readMessageSnapshot;
  StreamSubscription<FirestoreChangedData> _clubSnapshot;
  StreamSubscription<Iterable<Game>> _gameSubecription;
  InitialSubscription _playersInitialData;
  InitialSubscription _inviteInitialData;
  InitialSubscription _messageInitialData;
  InitialSubscription _unreadMessageInitialData;
  InitialSubscription _clubInitialData;

  // Game details.
  GameSubscription _basicGames;

  static UserDatabaseData _instance;
  static Map<Object, dynamic> snapshotMapping = new Map<Object, dynamic>();
  TraceProxy _loadingDataTrace;
  AnalyticsSubsystem _analytics;
  FusedUserProfile _profile;
  LoggingDataBase _logging;
  PersistenData persistentData;
  DatabaseUpdateModel updateModel;
  UserAuthImpl userAuth;

  UserDatabaseData(this._analytics, this._logging, this.persistentData,
      FirestoreWrapper wrapper)
      : userAuth = new UserAuthImpl(wrapper, persistentData),
        updateModel = new DatabaseUpdateModelImpl(wrapper, persistentData) {
    initStuff();
  }

  // Set the instance to use for getting the data.
  static set instance(UserDatabaseData data) {
    _instance = data;
  }

  static UserDatabaseData get instance {
    return _instance;
  }

  void initStuff() {
    _teamController = new StreamController<UpdateReason>();
    _playerController = new StreamController<UpdateReason>();
    _inviteController = new StreamController<UpdateReason>();
    _messageController = new StreamController<UpdateReason>();
    _clubController = new StreamController<UpdateReason>();
    teamStream = _teamController.stream.asBroadcastStream();
    playerStream = _playerController.stream.asBroadcastStream();
    inviteStream = _inviteController.stream.asBroadcastStream();
    messagesStream = _messageController.stream.asBroadcastStream();
    clubStream = _clubController.stream.asBroadcastStream();
  }

  Player get mePlayer {
    if (_players.values.length == 0) {
      return null;
    }
    return _players.values.firstWhere(
        (Player play) => play.users[userUid].relationship == Relationship.Me);
  }

  Future<bool> acceptInvite(Invite inputInvite,
      {String playerUid, String name, Relationship relationship}) async {
    if (inputInvite is InviteToTeam) {
      _analytics.logSignUp(signUpMethod: "inviteToTeam");
      InviteToTeam invite = inputInvite;
      // We add ourselves to the season.
      Season doc = await updateModel.getSeason(invite.seasonUid);
      if (doc != null) {
        // Update it!  First we add to the player.
        SeasonPlayer seasonPlayer =
            new SeasonPlayer(playerUid: playerUid, role: invite.role);
        await updateModel.addPlayerToSeason(invite.seasonUid, seasonPlayer);
        await invite.firestoreDelete();
        return true;
      }
    }
    if (inputInvite is InviteToPlayer) {
      _analytics.logSignUp(signUpMethod: "inviteToPlayer");
      InviteToPlayer invite = inputInvite;
      // Add ourselves to the player.
      bool exists = await updateModel.playerExists(invite.playerUid);
      if (exists) {
        // Yay!  We have a player.
        PlayerUser playerUser =
            new PlayerUser(userUid: userUid, relationship: relationship);
        await updateModel.addUserToPlayer(invite.playerUid, playerUser);
        await invite.firestoreDelete();
        return true;
      }
    }
    return false;
  }

  Future<String> addPlayer(String name, Relationship rel) async {
    // We add ourselves to the season.
    Player player = new Player();
    player.name = name;
    player.users = new Map<String, PlayerUser>();
    player.users[this.userUid] = new PlayerUser();
    player.users[this.userUid].relationship = rel;
    return updateModel.createPlayer(player);
  }

  Future<Player> getPlayer(String playerId, {bool withProfile = false}) async {
    if (players.containsKey(playerId)) {
      Player player = players[playerId];
      print('Short circuit');
      if (withProfile) {
        await Future.forEach(player.users.values, (PlayerUser user) async {
          return user.getProfile();
        });
      }
      return player;
    }
    Player player = await updateModel.getPlayerDetails(playerId);
    if (player != null) {
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

  Future<Club> getClub(String clubUid) async {
    if (clubs.containsKey(clubUid)) {
      return clubs[clubUid];
    }
    return updateModel.getClubData(clubUid);
  }

  // Filter the games down.
  GameSubscription getGames(
      FilterDetails details, DateTime start, DateTime end) {
    // Do the time range with the filter, or if no time range then
    // the team filter.  Do the rest in code.
    // Filter the games locally.
    Iterable<Game> cachedGames = _gamesCache.values.where((Game game) {
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
          return false;
        }
      }
      if (details.result != null) {
        if (game.result.result != details.result &&
            !(game.result.result == GameResult.Unknown)) {
          return false;
        }
      }
      if (details.eventType != null) {
        if (details.eventType != game.sharedData.type) {
          return false;
        }
      }
      return game.sharedData.tzEndTime.isAfter(start) &&
          game.sharedData.tzEndTime.isBefore(end);
    });
    GameSubscription sub =
        updateModel.getGames(cachedGames, _teams.keys.toSet(), start, end);
    return sub;
  }

  void _updateLoading() {
    _completedLoading = _loadedPlayers &&
        _loadedGames &&
        _loadedInvites &&
        _loadedTeams &&
        _loadedClubs;
    if (_completedLoading) {
      // Stop it and delete it.
      _loadingDataTrace?.stop();
      _loadingDataTrace = null;
    }
    print(
        "loading $_completedLoading $_loadedPlayers $_loadedGames $_loadedInvites $_loadedTeams $_loadedClubs sql $_loadedFromSql");
  }

  void _onPlayerUpdated(List<FirestoreWrappedData> query) {
    Set<String> toDeletePlayers = new Set<String>();
    bool foundMe = false;

    toDeletePlayers.addAll(_players.keys);
    for (FirestoreWrappedData doc in query) {
      _loadingDataTrace?.incrementCounter("player");
      Player player;
      if (_players.containsKey(doc.id)) {
        player = _players[doc.id];
        player.fromJSON(doc.id, doc.data);
        player.setupSnap();
        if (player.users[userUid].relationship == Relationship.Me) {
          if (foundMe) {
            if (player.users.length <= 1) {
              updateModel.deletePlayer(player.uid);
            }
          }
          foundMe = true;
        }
      } else {
        player = new Player();
        // Add in snapshots to find the teams associated with the player.
        player.fromJSON(doc.id, doc.data);
        player.setupSnap();
        _players[player.uid] = player;
        if (player.users[userUid].relationship == Relationship.Me) {
          if (foundMe) {
            if (player.users.length <= 1) {
              updateModel.deletePlayer(player.uid);
            }
          }
          foundMe = true;
        }
      }
      toDeletePlayers.remove(doc.id);
      persistentData.updateElement(PersistenData.playersTable, player.uid,
          player.toJSON(includeUsers: true));
    }
    toDeletePlayers.forEach((String id) {
      _loadingDataTrace?.incrementCounter("deleteplayer");
      _players.remove(id);
      persistentData.deleteElement(PersistenData.playersTable, id);
    });
    if (query.length == 0) {
      if (!foundMe && !_createdMePlayer) {
        print('Docs are empty');
        Player player = new Player();
        player.name = _profile.displayName;
        PlayerUser playerUser = new PlayerUser();
        playerUser.userUid = userUid;
        playerUser.relationship = Relationship.Me;
        player.users[playerUser.userUid] = playerUser;
        print('Updating firestore');
        _createdMePlayer = true;
        player.updateFirestore(includeUsers: true).then((void val) {
          print('Done!');
          _loadedGames = true;
          _loadedTeams = true;
          _updateLoading();
        }).catchError((e) {
          print('Print stuff');
          throw e;
        });
      } else {
        print('Loaded for fluff');
        _loadedGames = true;
        _loadedTeams = true;
        _updateLoading();
      }
    }
    _loadedPlayers = true;
    _updateLoading();
    _playerController.add(UpdateReason.Update);
  }

  void _onUnreadMessagesUpdated(FirestoreChangedData data) async {
    // Fill in all the messages.
    await Future.forEach(data.newList, (FirestoreWrappedData doc) async {
      _loadingDataTrace?.incrementCounter("message");
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient.fromJSON(doc.id, doc.data);

      if (messages.containsKey(recipient.messageId)) {
        Message mess = messages[recipient.messageId];
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        persistentData.updateElement(PersistenData.messagesTable, doc.id,
            mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        Message mess = await updateModel.getMessage(recipient.messageId);
        if (mess != null) {
          messages[mess.uid] = mess;
          mess.recipients[recipient.userId] = recipient;
          persistentData.updateElement(PersistenData.messagesTable, doc.id,
              mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    });
    unreadMessageCount = data.newList.length;
    for (FirestoreWrappedData change in data.removed) {
      _loadingDataTrace?.incrementCounter("deletemessage");
      MessageRecipient rec =
          new MessageRecipient.fromJSON(change.id, change.data);
      messages.remove(rec.messageId);
      persistentData.deleteElement(PersistenData.messagesTable, rec.messageId);
    }
    _loadedUnreadMessages = true;
    print('Loaded unread');
    _messageController.add(UpdateReason.Update);
  }

  void _onReadMessagesUpdated(FirestoreChangedData data) async {
    await Future.forEach(data.newList, (FirestoreWrappedData doc) async {
      _loadingDataTrace?.incrementCounter("message");
      MessageRecipient recipient;
      // Update in place to keep the fetched and seen times.
      recipient = new MessageRecipient.fromJSON(doc.id, doc.data);

      if (messages.containsKey(recipient.messageId)) {
        Message mess = messages[recipient.messageId];
        // Update just my recipient piece of this.
        mess.recipients[recipient.userId] = recipient;
        persistentData.updateElement(PersistenData.messagesTable, doc.id,
            mess.toJSON(includeMessage: true, forSQL: true));
      } else {
        // Otherwise we need to load it.
        Message mess = await updateModel.getMessage(recipient.messageId);
        if (mess != null) {
          mess.recipients[recipient.userId] = recipient;
          messages[mess.uid] = mess;
          persistentData.updateElement(PersistenData.messagesTable, doc.id,
              mess.toJSON(includeMessage: true, forSQL: true));
        }
      }
    });
    for (FirestoreWrappedData change in data.removed) {
      _loadingDataTrace?.incrementCounter("deletemessage");
      MessageRecipient rec =
          new MessageRecipient.fromJSON(change.id, change.data);
      messages.remove(rec.messageId);
      persistentData.deleteElement(PersistenData.messagesTable, rec.messageId);
    }
    unreadMessageCount = messages.keys
        .where((String key) =>
            messages[key].recipients[userUid].state == MessageState.Unread)
        .length;
    _loadedReadMessages = true;
    print('Loaded read');
    _messageController.add(UpdateReason.Update);
  }

  void onSeasonUpdated(List<FirestoreWrappedData> query) {
    Set<String> toDeleteSeasons = new Set<String>();
    String teamUid;
    List<Future<void>> newSnaps = [];

    for (FirestoreWrappedData doc in query) {
      _loadingDataTrace?.incrementCounter("team");
      // Get the team from the season.
      teamUid = doc.data[Season.TEAMUID];
      Team team;
      bool snapping = false;
      if (_teams.containsKey(teamUid)) {
        team = _teams[teamUid];
        team.uid = teamUid;
      } else {
        team = new Team();
        team.uid = teamUid;
        snapping = true;
      }
      if (toDeleteSeasons == null) {
        toDeleteSeasons.addAll(team.seasons.keys);
      }
      team.updateSeason(doc.id, doc.data);
      toDeleteSeasons.remove(doc.id);
      if (snapping) {
        String myTeamUid = teamUid;
        Team myTeamStuff = team;
        newSnaps.add(team.setupSnap().then((dynamic n) async {
          _teams[myTeamUid] = myTeamStuff;
        }));
      }
    }
    Future.wait(newSnaps).then((e) {
      _loadedTeams = true;
      if (_teams.length == 0) {
        _loadedGames = true;
        _updateLoading();
      } else {
        _updateLoading();
      }
      // Load the basic game set.
      if (_gameSubecription == null) {
        DateTime start = new DateTime.now().subtract(new Duration(days: 60));
        DateTime end = new DateTime.now().add(new Duration(days: 120));
        _basicGames = getGames(new FilterDetails(), start, end);
        _gameSubecription = _basicGames.stream.listen((Iterable<Game> it) {
          print('Loaded basic games ${it.length}');
          // Update the cache with stuff.
          if (!_loadedGames) {
            _onBasicGamesUpdated(it);
          } else {
            doCacheGames(it);
          }
          _loadedGames = true;
          _updateLoading();
          _loadingDataTrace?.incrementCounter("loadedGames");
        });
      }
      _cleanupInvites();
    });
    if (toDeleteSeasons != null) {
      for (String id in toDeleteSeasons) {
        _loadingDataTrace?.incrementCounter("deleteseason");
        _teams[teamUid].seasons.remove(id);
        persistentData.deleteElement(PersistenData.seasonTable, id);
      }
    }
    _teamController.add(UpdateReason.Update);
  }

  void _onBasicGamesUpdated(Iterable<Game> query) {
    // See if anything got deleted.
    Set<String> toDeleteGames = new Set();

    toDeleteGames = _gamesCache.keys.toSet();

    for (Game g in query) {
      _loadingDataTrace?.incrementCounter("game");
      if (_gamesCache.containsKey(g.uid)) {
        _gamesCache[g.uid].updateFrom(g);
        _gamesCache[g.uid].sharedData.updateFrom(g.sharedData);
      } else {
        _gamesCache[g.uid] = g;
      }
      toDeleteGames.remove(g.uid);
      persistentData.updateTeamElement(
          PersistenData.gameTable, g.uid, g.teamUid, g.toJSON());
      if (g.sharedDataUid.isNotEmpty) {
        persistentData.updateElement(PersistenData.sharedGameTable,
            g.sharedDataUid, g.sharedData.toJSON());
      }
    }
    print("Game cache ${gamesCache.length}");
    for (String id in toDeleteGames) {
      _loadingDataTrace?.incrementCounter("deletegame");
      _gamesCache.remove(id);
      persistentData.deleteElement(PersistenData.gameTable, id);
    }
    _loadedGames = true;
    _updateLoading();
  }

  void _onClubsUpdated(
      List<FirestoreWrappedData> newList, List<FirestoreWrappedData> removed) {
    for (FirestoreWrappedData data in newList) {
      Club club = new Club.fromJson(data.id, data.data);
      if (_clubs.containsKey(data.id)) {
        _clubs[data.id].updateFrom(club);
      } else {
        _clubs[data.id] = club;
      }
    }
    for (FirestoreWrappedData toRemove in removed) {
      _clubs.remove(toRemove.id);
    }
    _loadedClubs = true;
    _updateLoading();
    _clubController.add(UpdateReason.Update);
  }

  void doCacheGames(Iterable<Game> query) {
    for (Game g in query) {
      if (_gamesCache.containsKey(g.uid)) {
        _gamesCache[g.uid].updateFrom(g);
      } else {
        _gamesCache[g.uid] = g;
      }
    }
    print("Game cache ${gamesCache.length}");
    _loadedGames = true;
    _updateLoading();
  }

  void _cleanupInvites() {
    for (Invite invite in _invites.values) {
      // See if we should clean this up because we already accepted it.
      if (invite is InviteToPlayer) {
        InviteToPlayer playerInvite = invite;
        if (players.containsKey(invite.playerUid)) {
          // We already accepted it.
          playerInvite.firestoreDelete();
        }
      }
    }
  }

  void _onInviteUpdated(List<FirestoreWrappedData> query) {
    Map<String, Invite> newInvites = new Map<String, Invite>();

    // Completely clear the invite table.
    persistentData.clearTable(PersistenData.invitesTable);
    query.forEach((FirestoreWrappedData doc) {
      String uid = doc.id;
      Invite invite = Invite.makeInviteFromJSON(uid, doc.data);
      newInvites[uid] = invite;
      persistentData.updateElement(
          PersistenData.invitesTable, uid, invite.toJSON());
    });
    _invites = newInvites;
    _loadedInvites = true;
    _updateLoading();
    _inviteController.add(UpdateReason.Update);
    _cleanupInvites();
  }

  void onClubUpdated(FirestoreWrappedData data) {
    Club club = new Club.fromJson(data.id, data.data);
    if (_clubs.containsKey(data.id)) {
      _clubs[data.id].updateFrom(club);
    } else {
      _clubs[data.id] = club;
    }
  }

  void _setUid(
      String uid, String email, Future<FusedUserProfile> profile) async {
    print('setUid($uid)');
    // Already loaded.
    if (uid == userUid) {
      print('exiting');
      return;
    }
    profile.then((FusedUserProfile profile) => _profile = profile);
    this.userUid = uid;
    _completedLoading = false;
    TraceProxy sqlTrace = _analytics.newTrace("loadDataOnStartup");
    sqlTrace.start();
    if (_teamController == null) {
      initStuff();
    }
    // Load from SQL first.
    try {
      // Club data;
      TraceProxy clubTrace = _analytics.newTrace("clubData");
      clubTrace.start();
      DateTime start = new DateTime.now();
      Map<String, Map<String, dynamic>> data =
          await persistentData.getAllElements(PersistenData.clubsTable);
      Map<String, Club> newClubs = new Map<String, Club>();
      data.forEach((String uid, Map<String, dynamic> input) {
        sqlTrace.incrementCounter("club");
        Club club = new Club.fromJson(uid, input);
        newClubs[uid] = club;
      });
      _clubs = newClubs;
      print(
          'End clubs ${start.difference(new DateTime.now())} ${_clubs.length}');
      clubTrace.stop();

      // Loading all the team data.
      TraceProxy teamsTrace = _analytics.newTrace("teamData");
      teamsTrace.start();
      data = await persistentData.getAllElements(PersistenData.teamsTable);
      Map<String, Team> newTeams = new Map<String, Team>();
      print('Start teams ${start.difference(new DateTime.now())}');
      await Future.forEach(data.keys, (String uid) async {
        sqlTrace.incrementCounter("team");
        Map<String, dynamic> input = data[uid];
        Team team = new Team();
        team.fromJSON(uid, input);
        team.setupSnap();
        // Load opponents.
        newTeams[uid] = team;
        Map<String, Map<String, dynamic>> opponentData = await persistentData
            .getAllTeamElements(PersistenData.opponentsTable, uid);
        for (String key in opponentData.keys) {
          sqlTrace.incrementCounter("opponent");
          Map<String, dynamic> innerData = opponentData[key];
          Opponent op = new Opponent();
          op.fromJSON(key, uid, innerData);
          team.opponents[key] = op;
        }
      });
      _teams = newTeams;
      print('End teams ${start.difference(new DateTime.now())}');
      teamsTrace.stop();

      TraceProxy playerTrace = _analytics.newTrace("playerData");
      playerTrace.start();
      data = await persistentData.getAllElements(PersistenData.playersTable);
      Map<String, Player> newPlayers = new Map<String, Player>();
      data.forEach((String uid, Map<String, dynamic> input) {
        sqlTrace.incrementCounter("player");
        Player player = new Player();
        player.fromJSON(uid, input);
        newPlayers[uid] = player;
      });
      _players = newPlayers;
      print('End players ${start.difference(new DateTime.now())}');
      playerTrace.stop();

      TraceProxy gamesTrace = _analytics.newTrace("gamaData");
      gamesTrace.start();
      Map<String, Game> newGames = new Map<String, Game>();
      for (Team team in _teams.values) {
        data = await persistentData.getAllTeamElements(
            PersistenData.gameTable, team.uid);
        for (String uid in data.keys) {
          Map<String, dynamic> input = data[uid];
          sqlTrace.incrementCounter("game");
          String sharedDataUid = input[Game.SHAREDDATAUID];
          GameSharedData sharedData;
          if (sharedDataUid.isNotEmpty) {
            Map<String, dynamic> sharedDataStuff = await persistentData
                .getElement(PersistenData.sharedGameTable, sharedDataUid);
            sharedData =
                new GameSharedData.fromJSON(sharedDataUid, sharedDataStuff);
          } else {
            sharedData = new GameSharedData.fromJSON(sharedDataUid, input);
          }
          Game game = new Game.fromJSON(team.uid, uid, input, sharedData);
          newGames[uid] = game;
        }
      }
      _gamesCache = newGames;
      print(
          'End games ${start.difference(new DateTime.now())} ${_gamesCache.length}');
      gamesTrace.stop();

      TraceProxy invitesTrace = _analytics.newTrace("invitesData");
      invitesTrace.start();
      data = await persistentData.getAllElements(PersistenData.invitesTable);
      Map<String, Invite> newInvites = new Map<String, Invite>();
      data.forEach((String uid, Map<String, dynamic> input) {
        sqlTrace.incrementCounter("invites");
        Invite invite = new Invite();
        invite.fromJSON(uid, input);
        newInvites[uid] = invite;
      });
      _invites = newInvites;
      print('End invites ${start.difference(new DateTime.now())}');
      invitesTrace.stop();

      TraceProxy messagesTrace = _analytics.newTrace("messagesTrace");
      messagesTrace.start();
      data = await persistentData.getAllElements(PersistenData.messagesTable);
      Map<String, Message> newMessages = {};
      data.forEach((String uid, Map<String, dynamic> input) {
        sqlTrace.incrementCounter("message");
        Message mess = new Message.fromJSON(uid, input);
        newMessages[uid] = mess;
      });
      _messages = newMessages;
      print('End messages ${start.difference(new DateTime.now())}');
      messagesTrace.stop();

      // Setup the team stuff after loading.
      TraceProxy setupSnapTrace = _analytics.newTrace("setupSnaps");
      setupSnapTrace.start();
      for (Team team in _teams.values) {
        team.setupSnap();
      }
      print('Setup snap ${start.difference(new DateTime.now())}');
      setupSnapTrace.stop();

      TraceProxy informOfUpdatesTrace = _analytics.newTrace("updateEverything");
      informOfUpdatesTrace.start();
      unreadMessageCount = _messages.keys
          .where((String key) =>
              _messages[key].recipients[userUid].state == MessageState.Unread)
          .length;
      _playerController.add(UpdateReason.Update);
      _inviteController.add(UpdateReason.Update);
      _teamController.add(UpdateReason.Update);
      _messageController.add(UpdateReason.Update);
      print('End sql ${start.difference(new DateTime.now())}');
      informOfUpdatesTrace.stop();
    } catch (e) {
      // Any exception and we cleanup all the data to nothing.
      print('Caught exception $e');
      print(e.stackTrace.toString());
      _gamesCache.clear();
      _teams.clear();
      _invites.clear();
      _players.clear();

      // Log it through sentry.
      FusedErrorDetails detail =
          new FusedErrorDetails(exception: e, stack: StackTrace.current);
      _logging.logError(detail);
    }
    sqlTrace.stop();
    print('Finished loading from sql');
    _loadedFromSql = true;

    _loadingDataTrace = _analytics.newTrace("loadDataFromFirebase");
    _loadingDataTrace.start();

    // Load the clubs first.
    _clubInitialData = updateModel.getMainClubs(userUid);
    _clubInitialData.startData.then((List<FirestoreWrappedData> data) {
      _onClubsUpdated(data, []);
    });
    _clubSnapshot = _clubInitialData.stream.listen((FirestoreChangedData data) {
      _onClubsUpdated(data.newList, data.removed);
    });

    // The uid everything is based off.
    _playersInitialData = updateModel.getPlayers(userUid);
    _playersInitialData.startData.then((List<FirestoreWrappedData> data) {
      _loadingDataTrace?.incrementCounter("players");
      this._onPlayerUpdated(data);
    });
    _playerSnapshot =
        _playersInitialData.stream.listen((FirestoreChangedData data) {
      this._onPlayerUpdated(data.newList);
    });

    print('getting invites');
    _inviteInitialData = updateModel.getInvites(email);
    _inviteInitialData.startData.then((List<FirestoreWrappedData> data) {
      _loadingDataTrace?.incrementCounter("invite");
      this._onInviteUpdated(data);
    });
    _inviteSnapshot =
        _inviteInitialData.stream.listen((FirestoreChangedData data) {
      this._onInviteUpdated(data.newList);
    });

    _unreadMessageInitialData = updateModel.getMessages(userUid, true);
    _unreadMessageInitialData.startData.then((List<FirestoreWrappedData> data) {
      _loadingDataTrace?.incrementCounter("message");
      print("Got some messages $data");
      this._onUnreadMessagesUpdated(
          new FirestoreChangedData(newList: data, removed: []));
    });
    _messageSnapshot =
        _unreadMessageInitialData.stream.listen(this._onReadMessagesUpdated);
    _messageInitialData = updateModel.getMessages(userUid, false);
    _messageInitialData.startData.then((List<FirestoreWrappedData> data) {
      _loadingDataTrace?.incrementCounter("message");
      print("Got some messages $data");
      this._onUnreadMessagesUpdated(
          new FirestoreChangedData(newList: data, removed: []));
    });
    _readMessageSnapshot =
        _messageInitialData.stream.listen(this._onReadMessagesUpdated);
  }

  void close() {
    _completedLoading = false;
    _playerSnapshot?.cancel();
    _playerSnapshot = null;
    playerStream = null;
    _inviteSnapshot?.cancel();
    _inviteSnapshot = null;
    inviteStream = null;
    _messageSnapshot?.cancel();
    _messageSnapshot = null;
    _readMessageSnapshot?.cancel();
    _readMessageSnapshot = null;
    _teamController?.close();
    teamStream = null;
    _teamController = null;
    _playerController?.close();
    playerStream = null;
    _playerController = null;
    _inviteController?.close();
    inviteStream = null;
    _inviteController = null;
    _messageController?.close();
    _messageController = null;
    messagesStream = null;
    _gameSubecription?.cancel();
    _gameSubecription = null;
    clubStream = null;
    _clubController?.close();
    _clubController = null;
    _clubSnapshot?.cancel();
    _clubSnapshot = null;

    _teams.forEach((String key, Team value) {
      value.dispose();
    });
    _teams.clear();
    _gamesCache.forEach((String key, Game value) {
      value.close();
    });
    _gamesCache.clear();
    _players.forEach((String key, Player value) {
      value.dispose();
    });
    for (Club club in _clubs.values) {
      club.dispose();
    }
    _players.clear();
    _invites.clear();
    _clubs.clear();
    _createdMePlayer = false;
    _messageInitialData?.dispose();
    _messageInitialData = null;
    _unreadMessageInitialData?.dispose();
    _unreadMessageInitialData = null;
    _playersInitialData?.dispose();
    _playersInitialData = null;
    _inviteInitialData?.dispose();
    _inviteInitialData = null;
    _clubInitialData?.dispose();
    _clubInitialData = null;
  }

  void deletePersistentData() {
    persistentData.dropDatabase();
  }

  static void load(String uid, String email, Future<FusedUserProfile> profile) {
    instance._setUid(uid, email, profile);
  }

  static void clear() {
    if (_instance != null) {
      instance.deletePersistentData();
      instance.close();
    }
  }
}
