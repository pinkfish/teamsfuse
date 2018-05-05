import 'package:fusemodel/fusemodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'dart:async';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DatabaseUpdateModelImpl implements DatabaseUpdateModel {
  // Stuff for game updates.
  Future<void> updateFirestoreGame(Game game) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(GAMES_COLLECTION);
    if (game.uid == '' || game.uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(game.toJSON());
      game.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(game.uid).updateData(game.toJSON());
    }
  }

  Future<void> deleteFirestoreGame(Game game) async {
    // delete from the database.
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(game.uid);
    return ref.delete();
  }

  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend) async {
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(game.uid);

    Map<String, dynamic> data = new Map<String, dynamic>();
    data[Game.ATTENDANCE + "." + playerUid + "." + Game.ATTENDANCEVALUE] =
        attend.toString();
    await ref.updateData(data);
  }

  Future<void> updateFirestoreGameResult(
      Game game, GameResultDetails result) async {
    DocumentReference ref =
        Firestore.instance.collection(GAMES_COLLECTION).document(game.uid);

    Map<String, dynamic> data = new Map<String, dynamic>();
    data[Game.RESULT] = result.toJSON();
    await ref.updateData(data);
  }

// Invite firestore updates
  Future<void> firestoreInviteToTeamDelete(InviteToTeam invite) {
    return Firestore.instance
        .collection(INVITE_COLLECTION)
        .document(invite.uid)
        .delete();
  }

  Future<void> firestoreInviteToPlayerDelete(InviteToPlayer invite) {
    return Firestore.instance
        .collection(INVITE_COLLECTION)
        .document(invite.uid)
        .delete();
  }

// Message Recipients
  void updateMessageRecipientState(
      MessageRecipient rec, MessageState state) async {
    DocumentReference doc = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .document(rec.uid);
    await doc.updateData({MessageRecipient.STATE: state.toString()});
  }

  void deleteRecipient(MessageRecipient rec) async {
    DocumentReference doc = Firestore.instance
        .collection(MESSAGE_RECIPIENTS_COLLECTION)
        .document(rec.uid);
    await doc.delete();
  }

  Future<List<GameLog>> _getGameLogs(
      Game game, Future<QuerySnapshot> query) async {
    List<GameLog> logs = [];
    QuerySnapshot acutalData = await query;
    acutalData.documents.forEach((DocumentSnapshot doc) {
      GameLog log = new GameLog();
      log.fromJSON(doc.documentID, doc.data);
      logs.add(log);
    });
    return logs;
  }

  GameLogReturnData readGameLogs(Game game) {
    GameLogReturnData ret = new GameLogReturnData();
    CollectionReference coll = Firestore.instance
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    Future<QuerySnapshot> query = coll.getDocuments();
    ret.logs = _getGameLogs(game, query);

    ret.myLogStream = coll.snapshots.listen((QuerySnapshot snap) async {
      game.updateLogs(await _getGameLogs(game, query));
    });
    return ret;
  }

// Message for firestore.
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
      Map<String, dynamic> messageData = {};
      messageData[Message.BODY] = mess.message;
      await messageRef.updateData(messageData);
    } else {
      // Update the message.
      await ref
          .document(mess.uid)
          .updateData(mess.toJSON(includeMessage: false));
    }
  }

  Future<String> loadMessage(Message mess) async {
    DocumentReference ref = Firestore.instance
        .collection("Messages")
        .document(mess.uid)
        .collection(Message.BODY)
        .document(mess.uid);
    DocumentSnapshot snap = await ref.get();
    if (snap.exists) {
      mess.message = snap.data[Message.BODY];
      mess.messagesLoaded = true;
      return mess.message;
    }
    return null;
  }

// Opponent update
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

// Team stuff
  void _onOpponentUpdated(Team team, QuerySnapshot query) {
    Set<String> toDeleteOpponents = new Set<String>();
    SqlData sql = SqlData.instance;

    toDeleteOpponents.addAll(team.opponents.keys);
    query.documents.forEach((doc) {
      Opponent opponent;
      if (team.opponents.containsKey(doc.documentID)) {
        opponent = team.opponents[doc.documentID];
      } else {
        opponent = new Opponent();
      }
      opponent.fromJSON(doc.documentID, team.uid, doc.data);
      team.opponents[doc.documentID] = opponent;
      toDeleteOpponents.remove(doc.documentID);
      sql.updateTeamElement(
          SqlData.OPPONENTS_TABLE, doc.documentID, team.uid, team.toJSON());
    });
    toDeleteOpponents.forEach((String id) {
      sql.deleteElement(SqlData.OPPONENTS_TABLE, id);
      team.opponents.remove(id);
    });
    team.updateTeam();
  }

  void _onTeamUpdated(Team team, DocumentSnapshot snap) {
    team.fromJSON(snap.documentID, snap.data);
    print('team ' + team.uid);
    SqlData.instance
        .updateElement(SqlData.TEAMS_TABLE, team.uid, team.toJSON());
  }

  void updateSeason(Team team, DocumentSnapshot doc) {
    Season season;
    if (team.seasons.containsKey(doc.documentID)) {
      season = team.seasons[doc.documentID];
      season.fromJSON(doc.documentID, doc.data);
    } else {
      season = new Season();
      season.fromJSON(doc.documentID, doc.data);
      team.seasons[doc.documentID] = season;
    }
    SqlData.instance.updateElement(SqlData.SEASON_TABLE, doc.documentID,
        season.toJSON(includePlayers: true));
    team.updateTeam();
  }

  Future<List<StreamSubscription<dynamic>>> setupSnapForTeam(Team team) async {
    List<StreamSubscription<dynamic>> ret = [];
    ret.add(Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .snapshots
        .listen((DocumentSnapshot snap) => this._onTeamUpdated(team, snap)));

    CollectionReference opCollection = Firestore.instance
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .collection(OPPONENT_COLLECTION);
    QuerySnapshot queryOpponentSnap = await opCollection.getDocuments();

    this._onOpponentUpdated(team, queryOpponentSnap);
    ret.add(opCollection.snapshots
        .listen((QuerySnapshot snap) => this._onOpponentUpdated(team, snap)));

    Query gameQuery = Firestore.instance
        .collection(GAMES_COLLECTION)
        .where(Game.TEAMUID, isEqualTo: team.uid);
    QuerySnapshot queryGameSnap = await gameQuery.getDocuments();
    UserDatabaseData.instance.onGameUpdated(team.uid, queryGameSnap);
    ret.add(gameQuery.snapshots.listen((value) {
      UserDatabaseData.instance.onGameUpdated(team.uid, value);
    }));
    return ret;
  }

  Future<void> loadOpponents(Team team) async {
    Map<String, Map<String, dynamic>> opps = await SqlData.instance
        .getAllTeamElements(SqlData.OPPONENTS_TABLE, team.uid);

    Map<String, Opponent> ops = new Map<String, Opponent>();
    opps.forEach((String opUid, Map<String, dynamic> data) {
      Opponent op = new Opponent();
      op.fromJSON(opUid, team.uid, data);
      ops[opUid] = op;
    });
    team.opponents = ops;
  }

  Future<void> updateFirestoreTeam(Team team, PregenUidRet pregen) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(TEAMS_COLLECTION);
    if (team.uid == '' || team.uid == null) {
      // Add the game.
      DocumentReference doc;
      if (pregen != null) {
        doc = pregen.extra;
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

  PregenUidRet precreateUid(Team team) {
    PregenUidRet ret = new PregenUidRet();
    CollectionReference ref = Firestore.instance.collection(TEAMS_COLLECTION);
    DocumentReference docRef = ref.document();
    ret.uid = docRef.documentID;
    ret.extra = docRef;
    return ret;
  }

  Future<Uri> updateTeamImage(Team team, File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("team_" + team.uid + ".img");
    final StorageUploadTask task = ref.put(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    team.photoUrl = snapshot.downloadUrl.toString();
    print('photurl ${team.photoUrl}');
    return snapshot.downloadUrl;
  }

  // UserPlayer stuff
  Future<FusedUserProfile> getUserProfile(PlayerUser player) async {
    player.profile = await UserAuth.instance.getProfile(player.userUid);
    return player.profile;
  }

  // P{layer stuff
  Future<void> updateFirestorePlayer(Player player, bool includeUsers) async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(PLAYERS_COLLECTION);
    if (player.uid == '' || player.uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(player.toJSON(includeUsers: includeUsers));
      player.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(player.uid).updateData(player.toJSON(includeUsers: includeUsers));
    }
  }

  Future<Uri> updatePlayerImage(Player player, File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("player_" + player.uid + ".img");
    final StorageUploadTask task = ref.put(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    player.photoUrl = snapshot.downloadUrl.toString();
    print('photurl $player.photoUrl');
    Map<String, String> data = new Map<String, String>();
    data[PHOTOURL] = player.photoUrl;
    await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(player.uid)
        .updateData(data);
    return snapshot.downloadUrl;
  }

  List<StreamSubscription<dynamic>> setupPlayerSnap(Player player) {
    List<StreamSubscription<dynamic>> ret = [];
    // Teams.
    Query ref = Firestore.instance.collection(SEASONS_COLLECTION).where(
        Season.PLAYERS + "." + player.uid + "." + ADDED,
        isEqualTo: true);
    ret.add(ref.snapshots.listen(UserDatabaseData.instance.onSeasonUpdated));
    return ret;
  }

  // Send an invite to a user for this season and team.
  Future<void> inviteUserToPlayer(Player player,
      {String email}) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshot snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: player.uid)
        .getDocuments();
    if (snapshot.documents.length == 0) {
      InviteToPlayer invite = new InviteToPlayer(
          playerUid: player.uid, email: email, playerName: player.name);

      print('Adding invite');
      return ref.add(invite.toJSON());
    }
  }

  Future<StreamSubscription<dynamic>> getInviteForPlayerStream(
      Player player) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: player.uid)
        .snapshots
        .listen((QuerySnapshot query) {
      List<InviteToPlayer> ret = [];

      query.documents.forEach((DocumentSnapshot doc) {
        InviteToPlayer invite = new InviteToPlayer();
        invite.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      });
      player.setInvites(ret);
    });
    return snap;
  }

  Future<void> removeUserFromPlayer(Player player, String userId) {
    DocumentReference doc =
        Firestore.instance.collection(PLAYERS_COLLECTION).document(player.uid);
    return doc.updateData({Player.USERS + userId: null});

  }

  // Season updates
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

  Future<void> removePlayerFromSeason(
      Season season, SeasonPlayer player) async {
    DocumentReference doc =
        Firestore.instance.collection(SEASONS_COLLECTION).document(season.uid);
    Map<String, dynamic> data = new Map<String, dynamic>();
    data[Season.PLAYERS + "." + player.playerUid] = null;
    await doc.updateData(data);
  }

  Future<void> updateRoleInTeamForSeason(
      Season season, SeasonPlayer player, RoleInTeam role) async {
    Map<String, dynamic> data = new Map<String, dynamic>();

    data[Season.PLAYERS + "." + player.playerUid + "." + SeasonPlayer.ROLE] =
        role.toString();
    Firestore.instance
        .collection(SEASONS_COLLECTION)
        .document(season.uid)
        .updateData(data);
  }

  // Send an invite to a user for this season and team.
  Future<void> inviteUserToSeason(Season season,
      {String userId, String playername, String email}) async {
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
      snapshot.documents[0].reference.updateData(invite.toJSON());
      print('Updating invite');
    } else {
      InviteToTeam invite = new InviteToTeam();
      invite.email = email;
      invite.teamUid = season.teamUid;
      invite.seasonUid = season.uid;
      invite.playerName = [playername];
      invite.sentByUid = userId;
      invite.teamName = team.name;
      invite.seasonName = season.name;

      print('Adding invite');
      return ref.add(invite.toJSON());
    }
  }

  Future<StreamSubscription<dynamic>> getInviteForSeasonStream(
      Season season) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: season.uid)
        .where(InviteToTeam.TEAMUID, isEqualTo: season.teamUid)
        .snapshots
        .listen((QuerySnapshot query) {
      List<InviteToTeam> ret = [];

      query.documents.forEach((DocumentSnapshot doc) {
        InviteToTeam invite = new InviteToTeam();
        invite.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      });
      season.setInvites(ret);
    });
    return snap;
  }

  Future<Iterable<Game>> getSeasonGames(Season season) async {
    CollectionReference ref = Firestore.instance.collection(GAMES_COLLECTION);
    // See if the games for the season.
    var snap = await ref
        .where(Game.TEAMUID, isEqualTo: season.teamUid)
        .where(Game.SEASONUID, isEqualTo: season.uid)
        .getDocuments();
    return snap.documents.map((DocumentSnapshot doc) {
      Game game = new Game();
      game.fromJSON(doc.documentID, doc.data);
      return game;
    });
  }
}
