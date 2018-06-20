import 'package:fusemodel/fusemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'dart:async';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timezone/timezone.dart';
import 'dart:io';

class DatabaseUpdateModelImpl implements DatabaseUpdateModel {
  static const int maxMessages = 20;

  // Stuff for game updates.
  @override
  Future<void> updateFirestoreGame(Game game) async {
    print(game);
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(GAMES_COLLECTION);
    print(game.uid);
    if (game.uid == null || game.uid == '') {
      print(game.toJSON());
      // Add the game.
      DocumentReference doc = await ref.add(game.toJSON());
      print(doc);
      game.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(game.uid).updateData(game.toJSON());
    }
  }

  @override
  Future<void> deleteFirestoreGame(Game game) async {
    // delete from the database.
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(game.uid);
    return ref.delete();
  }

  @override
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend) async {
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(game.uid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[Game.ATTENDANCE + "." + playerUid + "." + Game.ATTENDANCEVALUE] =
        attend.toString();
    await ref.updateData(data);
  }

  @override
  Future<void> updateFirestoreGameResult(
      Game game, GameResultDetails result) async {
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(game.uid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[Game.RESULT] = result.toJSON();
    await ref.updateData(data);
  }

  // Invite firestore updates
  @override
  Future<void> firestoreInviteDelete(Invite invite) {
    return Firestore.instance
        .collection(INVITE_COLLECTION)
        .document(invite.uid)
        .delete();
  }

  // Message Recipients
  @override
  void updateMessageRecipientState(
      MessageRecipient rec, MessageState state) async {
    DocumentReference doc = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .document(rec.uid);
    await doc
        .updateData(<String, String>{MessageRecipient.STATE: state.toString()});
  }

  @override
  void deleteRecipient(MessageRecipient rec) async {
    DocumentReference doc = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .document(rec.uid);
    await doc.delete();
  }

  Future<List<GameLog>> _getGameLogs(
      Game game, Future<QuerySnapshot> query) async {
    List<GameLog> logs = <GameLog>[];
    QuerySnapshot acutalData = await query;
    acutalData.documents.forEach((DocumentSnapshot doc) {
      GameLog log = new GameLog.fromJson(doc.documentID, doc.data);
      logs.add(log);
    });
    return logs;
  }

  @override
  GameLogReturnData readGameLogs(Game game) {
    GameLogReturnData ret = new GameLogReturnData();
    CollectionReference coll = Firestore.instance
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    Future<QuerySnapshot> query = coll.getDocuments();
    ret.logs = _getGameLogs(game, query);

    ret.myLogStream = coll.snapshots().listen((QuerySnapshot snap) async {
      game.updateLogs(await _getGameLogs(game, query));
    });
    return ret;
  }

  @override
  Future<String> addFirestoreGameLog(Game game, GameLog log) {
    CollectionReference coll = Firestore.instance
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    log.eventTime = new TZDateTime.now(local);
    print('Writing game log');
    return coll.add(log.toJSON()).then((DocumentReference ref) {
      log.uid = ref.documentID;
      print("Wrote log ${ref.documentID} to ${ref.path}");
      return ref.documentID;
    }).catchError((Error e) {
      print("Got error $e");
      return null;
    });
  }

  // Message for firestore.
  @override
  Future<void> updateFirestoreMessage(Message mess) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection("Messages");
    if (mess.uid == '' || mess.uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(mess.toJSON(includeMessage: true));
      mess.timeSent = new DateTime.now().millisecondsSinceEpoch;
      mess.uid = doc.documentID;
      // Add the message body.
      DocumentReference messageRef = Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(mess.uid)
          .collection(MESSAGES_COLLECTION)
          .document(mess.uid);
      // Add in the recipients collection.
      await Future.forEach(mess.recipients.keys, (String str) async {
        MessageRecipient rec = mess.recipients[str];
        rec.messageId = mess.uid;
        rec.sentAt = new DateTime.now().millisecondsSinceEpoch;
        DocumentReference recRef = await Firestore.instance
            .collection(MESSAGE_RECIPIENTS_COLLECTION)
            .add(rec.toJSON());
        rec.uid = recRef.documentID;
        return rec.uid;
      });
      Map<String, dynamic> messageData = <String, dynamic>{};
      messageData[Message.BODY] = mess.message;
      await messageRef.updateData(messageData);
    } else {
      // Update the message.
      await ref
          .document(mess.uid)
          .updateData(mess.toJSON(includeMessage: false));
    }
  }

  @override
  Future<String> loadMessage(Message mess) async {
    DocumentReference ref = Firestore.instance
        .collection("Messages")
        .document(mess.uid)
        .collection(Message.BODY)
        .document(mess.uid);
    DocumentSnapshot snap = await ref.get();
    if (snap.exists) {
      mess.message = snap.data[Message.BODY] as String;
      mess.messagesLoaded = true;
      return mess.message;
    }
    return null;
  }

  @override
  Future<Message> getMessage(String messageId) async {
    DocumentSnapshot ref = await Firestore.instance
        .collection(MESSAGES_COLLECTION)
        .document(messageId)
        .get();
    if (ref.exists) {
      return new Message.fromJSON(ref.documentID, ref.data);
    }
    return null;
  }

  // Opponent update
  @override
  Future<String> updateFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION);
    if (opponent.uid == '' || opponent.uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(opponent.toJSON());
      opponent.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(opponent.uid).updateData(opponent.toJSON());
    }
    return opponent.uid;
  }

  @override
  Future<void> deleteFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    return Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION)
        .document(opponent.uid)
        .delete();
  }

  @override
  Future<Iterable<Game>> getOpponentGames(Opponent opponent) async {
    CollectionReference ref = Firestore.instance.collection(GAMES_COLLECTION);
    // See if the games for the season.
    QuerySnapshot snap = await ref
        .where(Game.TEAMUID, isEqualTo: opponent.teamUid)
        .where(Game.OPPONENTUID, isEqualTo: opponent.uid)
        .getDocuments();
    return snap.documents.map((DocumentSnapshot doc) {
      Game game = new Game.fromJSON(doc.documentID, doc.data);
      return game;
    });
  }

  // Team stuff
  void _onTeamUpdated(Team team, DocumentSnapshot snap) {
    team.fromJSON(snap.documentID, snap.data);
    print('team ' + team.uid);
    SqlData.instance
        .updateElement(PersistenData.teamsTable, team.uid, team.toJSON());
  }

  @override
  Future<List<StreamSubscription<dynamic>>> setupSnapForTeam(Team team) async {
    List<StreamSubscription<dynamic>> ret = <StreamSubscription<dynamic>>[];
    ret.add(Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .snapshots()
        .listen((DocumentSnapshot snap) => _onTeamUpdated(team, snap)));

    CollectionReference opCollection = Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .collection(OPPONENT_COLLECTION);
    QuerySnapshot queryOpponentSnap = await opCollection.getDocuments();

    // If there is a club for this team, load that too.
    if (team.clubUid != null) {
      DocumentReference ref =
          Firestore.instance.collection(CLUB_COLLECTION).document(team.clubUid);

      DocumentSnapshot query = await ref.get();
      UserDatabaseData.instance.onClubUpdated(new FirestoreWrappedData(
          id: query.documentID, data: query.data, exists: query.exists));
      ret.add(ref.snapshots().listen((DocumentSnapshot snap) {
        UserDatabaseData.instance.onClubUpdated(new FirestoreWrappedData(
            id: query.documentID, data: query.data, exists: query.exists));
      }));
    }
    team.onOpponentUpdated(_firestoreData(queryOpponentSnap.documents));
    ret.add(opCollection.snapshots().listen((QuerySnapshot snap) =>
        team.onOpponentUpdated(_firestoreData(snap.documents))));

    return ret;
  }

  @override
  Future<void> loadOpponents(Team team) async {
    Map<String, Map<String, dynamic>> opps = await SqlData.instance
        .getAllTeamElements(PersistenData.opponentsTable, team.uid);

    Map<String, Opponent> ops = <String, Opponent>{};
    opps.forEach((String opUid, Map<String, dynamic> data) {
      Opponent op = new Opponent();
      op.fromJSON(opUid, team.uid, data);
      ops[opUid] = op;
    });
    team.opponents = ops;
  }

  @override
  Future<void> updateFirestoreTeam(Team team, PregenUidRet pregen) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(TEAMS_COLLECTION);
    if (team.uid == '' || team.uid == null) {
      // Add the game.
      DocumentReference doc;
      if (pregen != null) {
        doc = pregen.extra as DocumentReference;
        await doc.setData(team.toJSON());
      } else {
        doc = await ref.add(team.toJSON());
      }
      team.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(team.uid).updateData(team.toJSON());
    }
  }

  @override
  PregenUidRet precreateUid(Team team) {
    PregenUidRet ret = new PregenUidRet();
    CollectionReference ref = Firestore.instance.collection(TEAMS_COLLECTION);
    DocumentReference docRef = ref.document();
    ret.uid = docRef.documentID;
    ret.extra = docRef;
    return ret;
  }

  @override
  Future<Uri> updateTeamImage(Team team, File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("team_" + team.uid + ".img");
    final StorageUploadTask task = ref.putFile(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    team.photoUrl = snapshot.downloadUrl.toString();
    print('photurl ${team.photoUrl}');
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteAdmin(Team team, String uid) {
    final DocumentReference ref =
        Firestore.instance.collection(TEAMS_COLLECTION).document(team.uid);
    return ref.updateData(<String, dynamic>{Team.ADMINS + "." + uid: false});
  }

  @override
  Future<String> addAdmin(String teamUid, String uid) async {
    final DocumentReference ref =
        Firestore.instance.collection(TEAMS_COLLECTION).document(teamUid);
    await ref.updateData(<String, dynamic>{Team.ADMINS + "." + uid: true});
    return ref.documentID;
  }

  @override
  Future<String> inviteAdminToTeam(Team team, String email) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshot snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .getDocuments();
    if (snapshot.documents.length == 0) {
      InviteAsAdmin invite = new InviteAsAdmin(
          email: email,
          teamName: team.name,
          teamUid: team.uid,
          sentByUid: UserDatabaseData.instance.userUid);

      print('Adding invite');
      DocumentReference doc = await ref.add(invite.toJSON());
      return doc.documentID;
    }
    return snapshot.documents[0].documentID;
  }

  @override
  StreamSubscription<dynamic> getInviteForTeamStream(Team team) {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshot> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: team.uid)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<InviteAsAdmin> ret = <InviteAsAdmin>[];

      for (DocumentSnapshot doc in query.documents) {
        InviteAsAdmin invite = new InviteAsAdmin();
        invite.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      }
      team.setInvites(ret);
    });
    return snap;
  }

  GameSubscription _getGamesInternal(Iterable<Game> cachedGames,
      Set<String> teams, String seasonUid, DateTime start, DateTime end) {
    GameSubscription sub = new GameSubscription(cachedGames);
    Map<String, List<Game>> maps = <String, List<Game>>{};
    for (String teamUid in teams) {
      Query gameQuery = Firestore.instance
          .collection(GAMES_COLLECTION)
          .where(Game.TEAMUID, isEqualTo: teamUid);
      if (start != null) {
        gameQuery = gameQuery
            .where(Game.TIME, isGreaterThan: start.millisecondsSinceEpoch)
            .where(Game.TIME, isLessThan: end.millisecondsSinceEpoch);
      }
      if (seasonUid != null) {
        gameQuery = gameQuery.where(Game.SEASONUID, isEqualTo: seasonUid);
      }
      gameQuery.getDocuments().then((QuerySnapshot queryGameSnap) {
        List<Game> data = <Game>[];
        for (DocumentSnapshot snap in queryGameSnap.documents) {
          data.add(new Game.fromJSON(snap.documentID, snap.data));
        }
        maps[teamUid] = data;
        if (maps.length == teams.length) {
          List<Game> newData = <Game>[];

          for (List<Game> it in maps.values) {
            newData.addAll(it);
          }
          sub.addUpdate(newData);
        }
      });

      sub.subscriptions
          .add(gameQuery.snapshots().listen((QuerySnapshot queryGameSnap) {
        List<Game> data = <Game>[];
        for (DocumentSnapshot snap in queryGameSnap.documents) {
          data.add(new Game.fromJSON(snap.documentID, snap.data));
        }
        maps[teamUid] = data;
        List<Game> newData = <Game>[];

        for (List<Game> it in maps.values) {
          newData.addAll(it);
        }
        // Update the cache so we can find these games when the
        // app is open.
        UserDatabaseData.instance.doCacheGames(newData);
        sub.addUpdate(newData);
      }));
    }
    return sub;
  }

  // Games!
  @override
  GameSubscription getGames(Iterable<Game> cachedGames, Set<String> teams,
      DateTime start, DateTime end) {
    return _getGamesInternal(cachedGames, teams, null, start, end);
  }

  // UserPlayer stuff
  @override
  Future<FusedUserProfile> getUserProfile(PlayerUser player) async {
    player.profile = await UserAuth.instance.getProfile(player.userUid);
    return player.profile;
  }

  // Player stuff
  @override
  Future<void> updateFirestorePlayer(Player player, bool includeUsers) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(PLAYERS_COLLECTION);
    if (player.uid == '' || player.uid == null) {
      // Add the game.
      DocumentReference doc =
          await ref.add(player.toJSON(includeUsers: includeUsers));
      player.uid = doc.documentID;
    } else {
      // Update the game.
      await ref
          .document(player.uid)
          .updateData(player.toJSON(includeUsers: includeUsers));
    }
  }

  @override
  Future<Uri> updatePlayerImage(Player player, File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("player_" + player.uid + ".img");
    final StorageUploadTask task = ref.putFile(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    player.photoUrl = snapshot.downloadUrl.toString();
    print('photurl $player.photoUrl');
    Map<String, String> data = <String, String>{};
    data[PHOTOURL] = player.photoUrl;
    await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(player.uid)
        .updateData(data);
    return snapshot.downloadUrl;
  }

  @override
  List<StreamSubscription<dynamic>> setupPlayerSnap(Player player) {
    List<StreamSubscription<dynamic>> ret = <StreamSubscription<dynamic>>[];
    // Teams.
    Query ref = Firestore.instance.collection(SEASONS_COLLECTION).where(
        Season.PLAYERS + "." + player.uid + "." + ADDED,
        isEqualTo: true);
    ret.add(ref.snapshots().listen((QuerySnapshot query) {
      UserDatabaseData.instance
          .onSeasonUpdated(_firestoreData(query.documents));
    }));
    return ret;
  }

  @override
  Future<bool> addUserToPlayer(String playerUid, PlayerUser player) async {
    DocumentSnapshot doc = await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .get();
    if (doc.exists) {
      // Yay!  We have a player.
      Map<String, dynamic> data = <String, dynamic>{};
      data[Player.USERS + "." + player.userUid] = player.toJSON();
      doc.reference.updateData(data);
      return true;
    }
    return false;
  }

  @override
  Future<String> createPlayer(Player player) async {
    CollectionReference ref = Firestore.instance.collection(PLAYERS_COLLECTION);
    DocumentReference doc = await ref.add(player.toJSON(includeUsers: true));
    player.uid = doc.documentID;
    return doc.documentID;
  }

  @override
  Future<void> deletePlayer(String playerUid) {
    return Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .delete()
        .then((void val) {});
  }

  // Send an invite to a user for this season and team.
  @override
  Future<void> inviteUserToPlayer(Player player, {String email}) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshot snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: player.uid)
        .getDocuments();
    if (snapshot.documents.length == 0) {
      InviteToPlayer invite = new InviteToPlayer(
          playerUid: player.uid,
          email: email,
          playerName: player.name,
          sentByUid: UserDatabaseData.instance.userUid);

      print('Adding invite');
      return ref.add(invite.toJSON());
    }
  }

  @override
  Future<StreamSubscription<dynamic>> getInviteForPlayerStream(
      Player player) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshot> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: player.uid)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<InviteToPlayer> ret = <InviteToPlayer>[];

      for (DocumentSnapshot doc in query.documents) {
        InviteToPlayer invite = new InviteToPlayer();
        invite.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      }
      player.setInvites(ret);
    });
    return snap;
  }

  @override
  Future<void> removeUserFromPlayer(Player player, String userId) {
    DocumentReference doc =
        Firestore.instance.collection(PLAYERS_COLLECTION).document(player.uid);
    return doc.updateData(<String, dynamic>{Player.USERS + userId: null});
  }

  // Season updates
  @override
  Future<void> updateFirestoreSeason(Season season, bool includePlayers) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(SEASONS_COLLECTION);
    if (season.uid == '' || season.uid == null) {
      // Add the game.
      DocumentReference doc =
          await ref.add(season.toJSON(includePlayers: includePlayers));
      season.uid = doc.documentID;
    } else {
      // Update the game.
      await ref
          .document(season.uid)
          .updateData(season.toJSON(includePlayers: includePlayers));
    }
  }

  @override
  Future<void> removePlayerFromSeason(
      Season season, SeasonPlayer player) async {
    DocumentReference doc =
        Firestore.instance.collection(SEASONS_COLLECTION).document(season.uid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[Season.PLAYERS + "." + player.playerUid] = null;
    await doc.updateData(data);
  }

  @override
  Future<void> updateRoleInTeamForSeason(
      Season season, SeasonPlayer player, RoleInTeam role) async {
    Map<String, dynamic> data = <String, dynamic>{};

    data[Season.PLAYERS + "." + player.playerUid + "." + SeasonPlayer.ROLE] =
        role.toString();
    Firestore.instance
        .collection(SEASONS_COLLECTION)
        .document(season.uid)
        .updateData(data);
  }

  @override
  Future<bool> playerExists(String uid) async {
    // Add ourselves to the player.
    DocumentSnapshot doc = await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(uid)
        .get();
    return doc.exists;
  }

  @override
  Future<Player> getPlayerDetails(String uid) async {
    DocumentSnapshot doc = await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(uid)
        .get();
    if (doc.exists) {
      Player player = new Player();
      player.fromJSON(uid, doc.data);
      return player;
    }
    return null;
  }

  // Send an invite to a user for this season and team.
  @override
  Future<void> inviteUserToSeason(Season season,
      {String userId, String playername, String email, RoleInTeam role}) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshot snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: season.uid)
        .where(InviteToTeam.TEAMUID, isEqualTo: season.teamUid)
        .getDocuments();
    Team team = UserDatabaseData.instance.teams[season.teamUid];
    if (snapshot.documents.length > 0) {
      InviteToTeam invite = Invite.makeInviteFromJSON(
          snapshot.documents[0].documentID, snapshot.documents[0].data);

      invite.playerName.add(playername);
      invite.seasonName = season.name;
      invite.teamName = team.name;
      invite.role = role;
      snapshot.documents[0].reference.updateData(invite.toJSON());
      print('Updating invite');
    } else {
      InviteToTeam invite = new InviteToTeam();
      invite.email = email;
      invite.teamUid = season.teamUid;
      invite.seasonUid = season.uid;
      invite.playerName = <String>[playername];
      invite.sentByUid = userId;
      invite.teamName = team.name;
      invite.seasonName = season.name;
      invite.role = role;
      invite.sentByUid = UserDatabaseData.instance.userUid;

      print('Adding invite');
      return ref.add(invite.toJSON());
    }
  }

  @override
  Future<StreamSubscription<dynamic>> getInviteForSeasonStream(
      Season season) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshot> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: season.uid)
        .where(InviteToTeam.TEAMUID, isEqualTo: season.teamUid)
        .snapshots()
        .listen((QuerySnapshot query) {
      List<InviteToTeam> ret = <InviteToTeam>[];

      for (DocumentSnapshot doc in query.documents) {
        InviteToTeam invite = new InviteToTeam();
        invite.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      }
      season.setInvites(ret);
    });
    return snap;
  }

  @override
  GameSubscription getSeasonGames(Iterable<Game> games, Season season) {
    Set<String> teams = new Set<String>();
    teams.add(season.teamUid);
    return _getGamesInternal(games, teams, season.uid, null, null);
  }

  @override
  Future<Season> getSeason(String seasonUid) async {
    DocumentSnapshot doc = await Firestore.instance
        .collection(SEASONS_COLLECTION)
        .document(seasonUid)
        .get();
    if (doc.exists) {
      Season season = new Season();
      season.fromJSON(doc.documentID, doc.data);
      return season;
    }
    return null;
  }

  @override
  Future<void> addPlayerToSeason(
      String seasonUid, SeasonPlayer seasonPlayer) async {
    DocumentReference doc = await Firestore.instance
        .collection(SEASONS_COLLECTION)
        .document(seasonUid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[Season.PLAYERS + "." + seasonPlayer.playerUid] = seasonPlayer.toJSON();
    doc.updateData(data);
    return;
  }

  List<FirestoreWrappedData> _firestoreData(List<DocumentSnapshot> documents) {
    List<FirestoreWrappedData> data = <FirestoreWrappedData>[];
    for (DocumentSnapshot snap in documents) {
      data.add(new FirestoreWrappedData(id: snap.documentID, data: snap.data));
    }
    return data;
  }

  List<FirestoreWrappedData> _firestoreRemovedData(
      List<DocumentChange> documents) {
    List<FirestoreWrappedData> data = <FirestoreWrappedData>[];
    for (DocumentChange snap in documents) {
      if (snap.type == DocumentChangeType.removed) {
        data.add(new FirestoreWrappedData(
            id: snap.document.documentID, data: snap.document.data));
      }
    }
    return data;
  }

  // clubs!
  @override
  TeamSubscription getTeams(String uid) {
    TeamSubscription sub = new TeamSubscription();
    Query query = Firestore.instance
        .collection(TEAMS_COLLECTION)
        .where(Team.CLUBUID, isEqualTo: uid);
    query.getDocuments().then((QuerySnapshot snap) {
      List<Team> teams = <Team>[];
      for (DocumentSnapshot snap in snap.documents) {
        Team team = new Team();
        team.fromJSON(snap.documentID, snap.data);
        teams.add(team);
      }
      sub.addUpdate(teams);
    });
    sub.subscriptions.add(query.snapshots().listen((QuerySnapshot snap) {
      List<Team> teams = <Team>[];
      for (DocumentSnapshot snap in snap.documents) {
        Team team = new Team();
        team.fromJSON(snap.documentID, snap.data);
        teams.add(team);
      }
      sub.addUpdate(teams);
    }));
    return sub;
  }

  @override
  Future<void> addUserToClub(String clubUid, String userUid, bool admin) {
    return Firestore.instance
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .updateData(<String, dynamic>{
      Club.MEMBERS + "." + userUid: <String, dynamic>{
        ADDED: true,
        Club.ADMIN: admin
      }
    });
  }

  @override
  Future<String> inviteUserToClub(InviteToClub invite) async {
    DocumentReference ref = await Firestore.instance
        .collection(INVITE_COLLECTION)
        .add(invite.toJSON());
    return ref.documentID;
  }

  @override
  Future<String> updateClub(Club club, {bool includeMembers}) async {
    Map<String, dynamic> data = club.toJson(includeMembers: includeMembers);
    if (club.uid == null) {
      DocumentReference ref =
          await Firestore.instance.collection(CLUB_COLLECTION).add(data);
      club.uid = ref.documentID;
    } else {
      await Firestore.instance
          .collection(CLUB_COLLECTION)
          .document(club.uid)
          .updateData(data);
    }
    return club.uid;
  }

  @override
  Future<Uri> updateClubImage(Club club, File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("club_" + club.uid + ".img");
    final StorageUploadTask task = ref.putFile(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    club.photoUrl = snapshot.downloadUrl.toString();
    print('photurl ${club.photoUrl}');
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteClubMember(Club club, String memberUid) {
    return Firestore.instance
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData(<String, dynamic>{
      Club.MEMBERS + "." + memberUid + "." + ADDED: false
    });
  }

  // Initial data
  @override
  InitialSubscription getMainClubs(String userUid) {
    Query collection = Firestore.instance
        .collection(CLUB_COLLECTION)
        .where(Club.MEMBERS + "." + userUid + "." + ADDED, isEqualTo: true);
    InitialSubscription sub = new InitialSubscription(
        startData: collection
            .getDocuments()
            .then((QuerySnapshot query) => _firestoreData(query.documents)));
    collection.snapshots().listen((QuerySnapshot snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getPlayers(String userUid) {
    Query collection = Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .where(Player.USERS + "." + userUid + "." + ADDED, isEqualTo: true);
    InitialSubscription sub = new InitialSubscription(
        startData: collection
            .getDocuments()
            .then((QuerySnapshot query) => _firestoreData(query.documents)));
    collection.snapshots().listen((QuerySnapshot snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getMessages(String userUid, bool unread) {
    Query query;
    if (unread) {
      query = Firestore.instance
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.USERID, isEqualTo: userUid)
          .where(MessageRecipient.STATE,
              isEqualTo: MessageState.Unread.toString());
    } else {
      query = Firestore.instance
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.USERID, isEqualTo: userUid)
          .orderBy(MessageRecipient.SENTAT)
          .limit(maxMessages);
    }
    InitialSubscription sub = new InitialSubscription(
        startData: query
            .getDocuments()
            .then((QuerySnapshot query) => _firestoreData(query.documents)));
    query.snapshots().listen((QuerySnapshot snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getInvites(String email) {
    Query inviteCollection = Firestore.instance
        .collection(INVITE_COLLECTION)
        .where(Invite.EMAIL, isEqualTo: normalizeEmail(email));

    InitialSubscription sub = new InitialSubscription(
        startData: inviteCollection
            .getDocuments()
            .then((QuerySnapshot query) => _firestoreData(query.documents)));
    inviteCollection.snapshots().listen((QuerySnapshot snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }
}
