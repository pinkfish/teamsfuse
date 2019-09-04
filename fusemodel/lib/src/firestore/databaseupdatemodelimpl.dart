import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:built_collection/built_collection.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart';

import 'firestore.dart';

class DatabaseUpdateModelImpl implements DatabaseUpdateModel {
  static const int maxMessages = 20;
  FirestoreWrapper wrapper;
  PersistenData persistenData;

  DatabaseUpdateModelImpl(this.wrapper, this.persistenData);

  // Stuff for game updates.
  @override
  Future<Game> updateFirestoreGame(Game game, bool sharedData) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(GAMES_COLLECTION);
    CollectionReferenceWrapper refShared =
        wrapper.collection(GAMES_SHARED_COLLECTION);
    if (game.uid == null || game.uid == '') {
      DocumentReferenceWrapper ref =
          wrapper.collection(GAMES_COLLECTION).document();
      DocumentReferenceWrapper refShared =
          wrapper.collection(GAMES_SHARED_COLLECTION).document();
      wrapper.runTransaction((TransactionWrapper tx) async {
        GameBuilder gameBuilder = game.toBuilder();
        // Add the shared stuff, then the game.
        if (game.sharedData.officialResults.homeTeamLeagueUid == null) {
          gameBuilder.sharedData.officialResults.homeTeamLeagueUid =
              game.teamUid;
        }
        gameBuilder.sharedData.uid = refShared.documentID;
        tx.set(refShared, game.sharedData.toJSON());
        gameBuilder.sharedDataUid = refShared.documentID;
        gameBuilder.uid = ref.documentID;
        // Add the game.
        tx.set(ref, gameBuilder.build().toJSON());
        return gameBuilder.build();
      });
    } else {
      if (sharedData) {
        if (game.sharedDataUid.isEmpty) {
          DocumentReferenceWrapper sharedDoc =
              await refShared.add(game.sharedData.toJSON());
          game = game.rebuild((b) => b..sharedDataUid = sharedDoc.documentID);
        } else {
          refShared
              .document(game.sharedDataUid)
              .updateData(game.sharedData.toJSON());
        }
      }
      // Update the game.
      ref.document(game.uid).updateData(game.toJSON());
      return game;
    }
  }

  @override
  Future<void> addTrainingEvents(Game game, Iterable<DateTime> dates) {
    List<DocumentReferenceWrapper> ref = List.generate(dates.length,
        (int i) => wrapper.collection(GAMES_COLLECTION).document());
    List<DocumentReferenceWrapper> refShared = List.generate(dates.length,
        (int i) => wrapper.collection(GAMES_SHARED_COLLECTION).document());
    DocumentReferenceWrapper mainRef =
        wrapper.collection(GAMES_COLLECTION).document();
    DocumentReferenceWrapper mainShared =
        wrapper.collection(GAMES_SHARED_COLLECTION).document();

    wrapper.runTransaction((TransactionWrapper tx) async {
      GameBuilder gameBuilder = game.toBuilder();
      // Add the shared stuff, then the game.
      if (game.sharedData.officialResults.homeTeamLeagueUid == null) {
        gameBuilder.sharedData.officialResults.homeTeamLeagueUid = game.teamUid;
      }
      tx.set(mainShared, game.sharedData.toJSON());
      gameBuilder.sharedDataUid = mainShared.documentID;
      // Add the game.
      tx.set(mainRef, gameBuilder.build().toJSON());
      for (int i = 0; i < dates.length; i++) {
        DateTime time = dates.elementAt(i);
        if (game.sharedData.time != time.millisecondsSinceEpoch) {
          Game newGame = game.rebuild((b) => b
            ..uid = null
            ..sharedData.time = time.millisecondsSinceEpoch);
          tx.set(refShared[i], game.sharedData.toJSON());
          gameBuilder.sharedDataUid = refShared[i].documentID;
          // Add the game.
          tx.set(ref[i], gameBuilder.build().toJSON());
        }
      }
    });
  }

  @override
  Future<String> updateFirestoreSharedGame(GameSharedData game) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper refShared =
        wrapper.collection(GAMES_SHARED_COLLECTION);
    if (game.uid == null || game.uid == '') {
      // Add the shared stuff, then the game.
      DocumentReferenceWrapper sharedDoc = await refShared.add(game.toJSON());
      // Add the game.
      return sharedDoc.documentID;
    } else {
      await refShared.document(game.uid).updateData(game.toJSON());

      // Update the game.
      return game.uid;
    }
  }

  @override
  Future<void> deleteFirestoreGame(Game game) async {
    // delete from the database.
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_COLLECTION).document(game.uid);
    return ref.delete();
  }

  @override
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend) {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_COLLECTION).document(game.uid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[Game.ATTENDANCE + "." + playerUid + "." + Game.ATTENDANCEVALUE] =
        attend.toString();

    return ref.updateData(data).then((void a) => print('Done stuff'));
  }

  @override
  Future<void> updateFirestoreGameResult(
      String gameUid, GameResultDetails result) {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_COLLECTION).document(gameUid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[Game.RESULT] = result.toJSON();
    return ref.updateData(data);
  }

  Future<void> updateFirestoreOfficalGameResult(
      String sharedGameUid, GameOfficialResults result) {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[GameSharedData.OFFICIALRESULT] = result.toJSON();
    return ref.updateData(data);
  }

  // Invite firestore updates
  @override
  Future<void> firestoreInviteDelete(String inviteUid) {
    return wrapper.collection(INVITE_COLLECTION).document(inviteUid).delete();
  }

  // Message Recipients
  @override
  Future<void> updateMessageRecipientState(
      MessageRecipient rec, MessageState state) {
    DocumentReferenceWrapper doc =
        wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document(rec.uid);
    return doc
        .updateData(<String, String>{MessageRecipient.STATE: state.toString()});
  }

  @override
  Future<void> deleteRecipient(MessageRecipient rec) {
    DocumentReferenceWrapper doc =
        wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document(rec.uid);
    return doc.delete();
  }

  @override
  Stream<Iterable<GameLog>> readGameLogs(Game game) async* {
    CollectionReferenceWrapper coll = wrapper
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    QuerySnapshotWrapper snap = await coll.getDocuments();
    yield snap.documents.map((DocumentSnapshotWrapper doc) =>
        GameLog.fromJson(doc.documentID, doc.data).build());

    await for (QuerySnapshotWrapper snap in coll.snapshots()) {
      yield snap.documents.map((DocumentSnapshotWrapper doc) =>
          GameLog.fromJson(doc.documentID, doc.data).build());
    }
  }

  @override
  Future<String> addFirestoreGameLog(Game game, GameLog log) {
    CollectionReferenceWrapper coll = wrapper
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    log = log.rebuild((b) =>
        b..eventTimeInternal = TZDateTime.now(local).millisecondsSinceEpoch);
    return coll.add(log.toJSON()).then((DocumentReferenceWrapper ref) {
      return ref.documentID;
    }).catchError((Error e) {
      print("Got error $e");
      return null;
    });
  }

  // Message for firestore.
  @override
  Future<Message> updateFirestoreMessage(MessageBuilder mess) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection("Messages");
    if (mess.uid == '' || mess.uid == null) {
      // Add the game.
      mess.timeSent = new DateTime.now().millisecondsSinceEpoch;
      Message messageStuff = mess.build();
      DocumentReferenceWrapper doc = await ref.add(messageStuff.toJSON());
      mess.uid = doc.documentID;

      // Add in the recipients collection.
      for (String str in messageStuff.recipients.keys) {
        MessageRecipient rec = mess.recipients[str].rebuild((b) => b
          ..messageId = mess.uid
          ..sentAt = mess.timeSent);
        DocumentReferenceWrapper recRef = await wrapper
            .collection(MESSAGE_RECIPIENTS_COLLECTION)
            .add(rec.toJSON());
        mess.recipients[str] = rec.rebuild((b) => b..uid = recRef.documentID);
      }
    } else {
      // Update the message.
      Message myMess = mess.build();
      await ref.document(mess.uid).updateData(mess.build().toJSON());
      return myMess;
    }
  }

  Future<void> updateFirestoreMessageBody(
      {String messageUid, String body}) async {
    // Add the message body.
    DocumentReferenceWrapper messageRef = wrapper
        .collection(MESSAGES_COLLECTION)
        .document(messageUid)
        .collection(MESSAGES_COLLECTION)
        .document(messageUid);
    Map<String, dynamic> messageData = <String, dynamic>{};
    messageData[Message.BODY] = body;
    await messageRef.updateData(messageData);
  }

  @override
  Stream<String> loadMessageBody(String messageUid) async* {
    DocumentReferenceWrapper ref = wrapper
        .collection("Messages")
        .document(messageUid)
        .collection(Message.BODY)
        .document(messageUid);
    DocumentSnapshotWrapper snap = await ref.get();
    if (snap.exists) {
      yield snap.data[Message.BODY] as String;
      await for (DocumentSnapshotWrapper snapper in ref.snapshots()) {
        yield snapper.data[Message.BODY];
      }
    }
    yield null;
  }

  @override
  Future<Message> getMessage(String messageId) async {
    DocumentSnapshotWrapper ref =
        await wrapper.collection(MESSAGES_COLLECTION).document(messageId).get();
    if (ref.exists) {
      return Message.fromJSON(ref.documentID, ref.data).build();
    }
    return null;
  }

  // Opponent update
  @override
  Future<String> updateFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION);
    // Update the game.
    await ref.document(opponent.uid).updateData(opponent.toJSON());
    return opponent.uid;
  }

  @override
  Future<Opponent> addFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION);
    // Add the game.
    DocumentReferenceWrapper doc = await ref.add(opponent.toJSON());
    return opponent.rebuild((b) => b..uid = doc.documentID);
  }

  @override
  Future<void> deleteFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    return wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION)
        .document(opponent.uid)
        .delete();
  }

  Future<Game> _getWholeGame(
      DocumentSnapshotWrapper doc, String teamUid) async {
    String sharedGameUid = doc.data[Game.SHAREDDATAUID];
    GameSharedDataBuilder sharedData;
    if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
      // Load the shared stuff too.
      DocumentSnapshotWrapper doc = await wrapper
          .collection(GAMES_SHARED_COLLECTION)
          .document(sharedGameUid)
          .get();
      sharedData = GameSharedData.fromJSON(doc.documentID, doc.data);
    } else {
      sharedData = GameSharedData.fromJSON(sharedGameUid, doc.data);
    }
    GameBuilder game =
        Game.fromJSON(teamUid, doc.documentID, doc.data, sharedData.build());
    return game.build();
  }

  @override
  Stream<Iterable<Game>> getOpponentGames(Opponent opponent) async* {
    CollectionReferenceWrapper ref = wrapper.collection(GAMES_COLLECTION);
    // See if the games for the season.
    CollectionReferenceWrapper snap = await ref
        .where(Game.TEAMUID, isEqualTo: opponent.teamUid)
        .where(Game.OPPONENTUID, isEqualTo: opponent.uid);
    QuerySnapshotWrapper query = await snap.getDocuments();
    List<Game> g = [];
    for (DocumentSnapshotWrapper doc in query.documents) {
      g.add(await _getWholeGame(doc, opponent.teamUid));
    }
    yield g;
    await for (QuerySnapshotWrapper doc in snap.snapshots()) {
      List<Game> g = [];
      for (DocumentSnapshotWrapper doc in query.documents) {
        g.add(await _getWholeGame(doc, opponent.teamUid));
      }
      yield g;
    }
  }

  @override
  Stream<Iterable<Opponent>> getTeamOpponents(String teamUid) async* {
    CollectionReferenceWrapper opCollection = wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .collection(OPPONENT_COLLECTION);
    QuerySnapshotWrapper queryOpponentSnap = await opCollection.getDocuments();

    yield queryOpponentSnap.documents.map((DocumentSnapshotWrapper doc) =>
        Opponent.fromJSON(doc.documentID, teamUid, doc.data).build());
    await for (QuerySnapshotWrapper query in opCollection.snapshots()) {
      yield query.documents.map((DocumentSnapshotWrapper doc) =>
          Opponent.fromJSON(doc.documentID, teamUid, doc.data).build());
    }
  }

  @override
  Future<void> updateFirestoreTeam(Team team) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(TEAMS_COLLECTION);

    // Update the game.
    await ref.document(team.uid).updateData(team.toJSON());
    return team.uid;
  }

  @override
  Future<String> addFirestoreTeam(Team team, DocumentReferenceWrapper pregen,
      Season season, File imageFile) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(TEAMS_COLLECTION);
    if (pregen == null) {
      pregen = wrapper.collection(TEAMS_COLLECTION).document();
    }
    DocumentReferenceWrapper pregenSeason =
        wrapper.collection(SEASONS_COLLECTION).document();
    wrapper.runTransaction((TransactionWrapper tx) async {
      await tx.set(pregen, team.toJSON());
      await tx.set(
          pregenSeason,
          season
              .rebuild((b) => b..uid = pregen.documentID)
              .toJSON(includePlayers: true));
      if (imageFile != null) {}
    });
    if (imageFile != null) {
      updateTeamImage(pregen.documentID, imageFile);
    }

    return pregen.documentID;
  }

  @override
  DocumentReferenceWrapper precreateTeamUid() {
    CollectionReferenceWrapper ref = wrapper.collection(TEAMS_COLLECTION);
    return ref.document();
  }

  @override
  DocumentReferenceWrapper precreateClubUid() {
    CollectionReferenceWrapper ref = wrapper.collection(CLUB_COLLECTION);
    return ref.document();
  }

  @override
  Future<Uri> updateTeamImage(String teamUid, File imgFile) async {
    final StorageReferenceWrapper ref =
        wrapper.storageRef().child("team_" + teamUid + ".img");
    final StorageUploadTaskWrapper task = ref.putFile(imgFile);
    final UploadTaskSnapshotWrapper snapshot = await task.future;
    Uri photoUrl = snapshot.downloadUrl;
    await wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .updateData({PHOTOURL: photoUrl.toString()});
    return photoUrl;
  }

  @override
  Future<void> deleteAdmin(Team team, String uid) {
    final DocumentReferenceWrapper ref =
        wrapper.collection(TEAMS_COLLECTION).document(team.uid);
    return ref.updateData(<String, dynamic>{Team.ADMINS + "." + uid: false});
  }

  @override
  Future<String> addAdmin(String teamUid, String uid) async {
    final DocumentReferenceWrapper ref =
        wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    await ref.updateData(<String, dynamic>{Team.ADMINS + "." + uid: true});
    return ref.documentID;
  }

  @override
  Stream<Iterable<InviteAsAdmin>> getInviteForTeamStream(Team team) async* {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QueryWrapper snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: team.uid);
    QuerySnapshotWrapper wrap = await snap.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper wrap) =>
        InviteAsAdmin.fromJSON(wrap.documentID, wrap.data).build());

    await for (QuerySnapshotWrapper wrap in snap.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper wrap) =>
          InviteAsAdmin.fromJSON(wrap.documentID, wrap.data).build());
    }
  }

  @override
  Stream<Iterable<InviteAsAdmin>> getInvitesForTeam(String teamUid) async* {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QueryWrapper query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: teamUid);

    QuerySnapshotWrapper queryData = await query.getDocuments();
    List<InviteAsAdmin> ret = <InviteAsAdmin>[];
    for (DocumentSnapshotWrapper doc in queryData.documents) {
      InviteAsAdmin invite =
          InviteAsAdmin.fromJSON(doc.documentID, doc.data).build();
      ret.add(invite);
    }
    yield ret;
    await for (QuerySnapshotWrapper data in query.snapshots()) {
      List<InviteAsAdmin> ret = <InviteAsAdmin>[];

      for (DocumentSnapshotWrapper doc in data.documents) {
        InviteAsAdmin invite =
            InviteAsAdmin.fromJSON(doc.documentID, doc.data).build();
        ret.add(invite);
      }
      yield ret;
    }
  }

  @override
  Stream<Iterable<Season>> getAllSeasons(String teamUid) async* {
    var where = wrapper
        .collection(SEASONS_COLLECTION)
        .where(Season.TEAMUID, isEqualTo: teamUid);
    var docs = await where.getDocuments();
    yield docs.documents.map((DocumentSnapshotWrapper doc) =>
        Season.fromJSON(doc.documentID, doc.data).build());

    await for (QuerySnapshotWrapper query in where.snapshots()) {
      yield query.documents.map((DocumentSnapshotWrapper doc) =>
          Season.fromJSON(doc.documentID, doc.data).build());
    }
  }

  @override
  Future<Team> getPublicTeamDetails(
      {@required String userUid, @required String teamUid}) async {
    DocumentSnapshotWrapper snap =
        await wrapper.collection(TEAMS_COLLECTION).document(teamUid).get();
    if (snap.exists) {
      Team team =
          Team.fromJSON(userUid, snap.documentID, snap.data, publicOnly: true)
              .build();
      return team;
    }
    return null;
  }

  @override
  Stream<TeamBuilder> getTeamDetails(
      {@required String userUid, @required String teamUid}) async* {
    DocumentReferenceWrapper referenceWrapper =
        wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    DocumentSnapshotWrapper snap = await referenceWrapper.get();
    if (snap.exists) {
      yield Team.fromJSON(userUid, snap.documentID, snap.data);
    } else {
      yield TeamBuilder()..uid = teamUid;
    }
    await for (DocumentSnapshotWrapper doc in referenceWrapper.snapshots()) {
      yield Team.fromJSON(userUid, doc.documentID, doc.data);
    }
  }

  ///
  /// Returns the basic set of games for this specific team.
  ///
  Stream<GameSnapshotEvent> getBasicGames(
      {DateTime start, DateTime end, String teamUid, String seasonUid}) async* {
    Map<String, Stream<GameSnapshotEvent>> sharedDocStream = {};
    Stream<GameSnapshotEvent> mainGameStream;
    StreamGroup<GameSnapshotEvent> str = StreamGroup<GameSnapshotEvent>();

    QueryWrapper gameQuery = wrapper
        .collection(GAMES_COLLECTION)
        .where(Game.TEAMUID, isEqualTo: teamUid);
    if (start != null) {
      gameQuery = gameQuery
          .where(ARRIVALTIME, isGreaterThan: start.millisecondsSinceEpoch)
          .where(ARRIVALTIME, isLessThan: end.millisecondsSinceEpoch);
    }
    if (seasonUid != null) {
      gameQuery = gameQuery.where(Game.SEASONUID, isEqualTo: seasonUid);
    }
    QuerySnapshotWrapper queryGameSnap = await gameQuery.getDocuments();

    Set<Game> data = new Set<Game>();
    for (DocumentSnapshotWrapper snap in queryGameSnap.documents) {
      String sharedGameUid = snap.data[Game.SHAREDDATAUID];
      GameSharedData sharedData;
      if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
        DocumentReferenceWrapper sharedRef =
            wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);
        DocumentSnapshotWrapper snapShared = await sharedRef.get();
        sharedData =
            GameSharedData.fromJSON(snapShared.documentID, snapShared.data)
                .build();
        // Add in a subscription to this shared game stuff and listen to it.
        if (!sharedDocStream.containsKey(sharedGameUid)) {
          sharedDocStream[sharedGameUid] = sharedRef.snapshots().map(
              (DocumentSnapshotWrapper snapUpdate) => GameSnapshotEvent(
                  type: GameSnapshotEventType.SharedGameUpdate,
                  teamUid: teamUid,
                  gameUid: snap.documentID,
                  sharedGame: GameSharedData.fromJSON(
                          snapUpdate.documentID, snapUpdate.data)
                      .build()));
          str.add(sharedDocStream[sharedGameUid]);
        }
      } else {
        // Missing shared data uid.
        sharedData = GameSharedData.fromJSON("", snap.data).build();
      }
      Game g = Game.fromJSON(teamUid, snap.documentID, snap.data, sharedData)
          .build();
      data.add(g);
    }
    yield GameSnapshotEvent(
        type: GameSnapshotEventType.GameList,
        teamUid: teamUid,
        newGames: data,
        deletedGames: []);

    // Merge the streams.
    mainGameStream = gameQuery
        .snapshots()
        .asyncMap((QuerySnapshotWrapper queryGameSnap) async {
      Set<Game> data = new Set<Game>();
      Set<String> sharedGamesToRemove = Set.from(sharedDocStream.keys);
      for (DocumentSnapshotWrapper snap in queryGameSnap.documents) {
        String sharedGameUid;
        GameSharedData sharedData;
        sharedGameUid = snap.data[Game.SHAREDDATAUID] as String;
        if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
          DocumentReferenceWrapper sharedRef = wrapper
              .collection(GAMES_SHARED_COLLECTION)
              .document(sharedGameUid);
          DocumentSnapshotWrapper snapShared = await sharedRef.get();
          sharedData =
              GameSharedData.fromJSON(snapShared.documentID, snapShared.data)
                  .build();
          String gameId = snap.documentID;
          // Listen to changes too.
          sharedGamesToRemove.remove(snapShared.documentID);
          if (!sharedDocStream.containsKey(sharedGameUid)) {
            sharedDocStream[sharedGameUid] = sharedRef.snapshots().map(
                (DocumentSnapshotWrapper snapUpdate) => GameSnapshotEvent(
                    type: GameSnapshotEventType.SharedGameUpdate,
                    teamUid: teamUid,
                    gameUid: snap.documentID,
                    sharedGame: GameSharedData.fromJSON(
                            snapUpdate.documentID, snapUpdate.data)
                        .build()));
            str.add(sharedDocStream[sharedGameUid]);
          }
        } else {
          sharedData = GameSharedData.fromJSON("", snap.data).build();
        }

        Game newGame =
            Game.fromJSON(teamUid, snap.documentID, snap.data, sharedData)
                .build();
        data.add(newGame);
      }
      // Remove any old shared games that we are waiting for.
      for (String rem in sharedGamesToRemove) {
        str.remove(sharedDocStream[rem]);
        sharedDocStream.remove(rem);
      }
      Iterable<String> toDelete = queryGameSnap.documentChanges
          .where((DocumentChangeWrapper wrap) =>
              wrap.type == DocumentChangeTypeWrapper.removed)
          .map((DocumentChangeWrapper wrap) => wrap.document.documentID);
      return GameSnapshotEvent(
          type: GameSnapshotEventType.GameList,
          teamUid: teamUid,
          newGames: data,
          deletedGames: toDelete);
    });

    str.add(mainGameStream);

    await for (GameSnapshotEvent queryGameSnap in str.stream) {
      yield queryGameSnap;
    }
  }

  // Games!
  Future<GameSharedData> _getSharedGameInternal(String sharedGameUid) async {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);

    DocumentSnapshotWrapper doc = await ref.get();
    if (doc.exists) {
      GameSharedData gameSharedData =
          GameSharedData.fromJSON(doc.documentID, doc.data).build();

      return gameSharedData;
    }
    return null;
  }

  @override
  Stream<GameSharedData> getSharedGame(String sharedGameUid) async* {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);
    DocumentSnapshotWrapper wrap = await ref.get();
    yield GameSharedData.fromJSON(wrap.documentID, wrap.data).build();
    await for (DocumentSnapshotWrapper wrap in ref.snapshots()) {
      yield GameSharedData.fromJSON(wrap.documentID, wrap.data).build();
    }
  }

  @override
  Stream<Game> getGame(String gameUid) async* {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_COLLECTION).document(gameUid);
    DocumentSnapshotWrapper snap = await ref.get();
    if (!snap.exists) {
      yield null;
    } else {
      String sharedGameUid = snap.data[Game.SHAREDDATAUID];
      GameSharedData shared;
      if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
        shared = await _getSharedGameInternal(sharedGameUid);
      } else {
        shared = GameSharedData.fromJSON("", snap.data).build();
      }
      Game game =
          Game.fromJSON(snap.data[Game.TEAMUID], gameUid, snap.data, shared)
              .build();
      yield game;

      await for (DocumentSnapshotWrapper snap in ref.snapshots()) {
        String sharedGameUid = snap.data[Game.SHAREDDATAUID];
        GameSharedData shared;
        if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
          shared = await _getSharedGameInternal(sharedGameUid);
        } else {
          shared = GameSharedData.fromJSON("", snap.data).build();
        }
        Game game =
            Game.fromJSON(snap.data[Game.TEAMUID], gameUid, snap.data, shared)
                .build();
        yield game;
      }
    }
  }

  // Player stuff
  @override
  Future<void> updateFirestorePlayer(Player player, bool includeUsers) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(PLAYERS_COLLECTION);
    // Update the game.
    await ref
        .document(player.uid)
        .updateData(player.toJSON(includeUsers: includeUsers));
  }

  // Player stuff
  @override
  Future<String> addFirestorePlayer(Player player) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(PLAYERS_COLLECTION);
    // Add the game.
    DocumentReferenceWrapper doc =
        await ref.add(player.toJSON(includeUsers: true));
    return doc.documentID;
  }

  @override
  Future<Uri> updatePlayerImage(String playerUid, File imgFile) async {
    final StorageReferenceWrapper ref =
        wrapper.storageRef().child("player_" + playerUid + ".img");
    final StorageUploadTaskWrapper task = ref.putFile(imgFile);
    final UploadTaskSnapshotWrapper snapshot = (await task.future);
    String photoUrl = snapshot.downloadUrl.toString();
    print('photurl $playerUid');
    Map<String, String> data = <String, String>{};
    data[PHOTOURL] = photoUrl;
    await wrapper
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .updateData(data);
    return snapshot.downloadUrl;
  }

  @override
  Stream<Iterable<Season>> getPlayerSeasons(String playerUid) async* {
    QueryWrapper ref = wrapper
        .collection(SEASONS_COLLECTION)
        .where(Season.PLAYERS + "." + playerUid + "." + ADDED, isEqualTo: true);
    QuerySnapshotWrapper wrap = await ref.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        Season.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper doc in ref.snapshots()) {
      yield doc.documents.map((DocumentSnapshotWrapper snap) =>
          Season.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Future<bool> addUserToPlayer(String playerUid, PlayerUser player) async {
    DocumentSnapshotWrapper doc =
        await wrapper.collection(PLAYERS_COLLECTION).document(playerUid).get();
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
    CollectionReferenceWrapper ref = wrapper.collection(PLAYERS_COLLECTION);
    DocumentReferenceWrapper doc =
        await ref.add(player.toJSON(includeUsers: true));
    return doc.documentID;
  }

  @override
  Future<void> deletePlayer(String playerUid) {
    return wrapper
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .delete()
        .then((void val) {});
  }

  // Send an invite to a user for this season and team.
  @override
  Future<String> inviteUserToPlayer(
      {@required String playerUid,
      @required String playerName,
      @required String email,
      @required myUid}) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshotWrapper snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: playerUid)
        .getDocuments();
    if (snapshot.documents.length == 0) {
      InviteToPlayer invite = new InviteToPlayer((b) => b
        ..playerUid = playerUid
        ..email = email
        ..playerName = playerName
        ..sentByUid = myUid);

      var doc = await ref.add(invite.toJSON());
      return doc.documentID;
    }
    return snapshot.documents[0].documentID;
  }

  @override
  Future<String> inviteAdminToTeam(
      {@required String myUid,
      @required String teamUid,
      @required String teamName,
      @required String email}) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshotWrapper snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: teamUid)
        .getDocuments();
    if (snapshot.documents.length == 0) {
      InviteAsAdmin invite = new InviteAsAdmin((b) => b
        ..teamUid = teamUid
        ..email = email
        ..teamName = teamName
        ..sentByUid = myUid);

      var doc = await ref.add(invite.toJSON());
      return doc.documentID;
    }
    return snapshot.documents[0].documentID;
  }

  @override
  Stream<Iterable<InviteToPlayer>> getInviteForPlayerStream(
      {String playerUid}) async* {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QueryWrapper query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: playerUid);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        InviteToPlayer.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          InviteToPlayer.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Future<void> removeUserFromPlayer(Player player, String userId) {
    DocumentReferenceWrapper doc =
        wrapper.collection(PLAYERS_COLLECTION).document(player.uid);
    return doc.updateData(<String, dynamic>{Player.USERS + userId: null});
  }

  // Season updates
  @override
  Future<void> updateFirestoreSeason(Season season, bool includePlayers) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(SEASONS_COLLECTION);

    // Update the game.
    await ref
        .document(season.uid)
        .updateData(season.toJSON(includePlayers: includePlayers));
    persistenData.updateElement(PersistenData.seasonTable, season.uid,
        season.toJSON(includePlayers: true));
  }

  Future<Season> addFirestoreSeason(
      Season season, DocumentReferenceWrapper pregenDoc) async {
    CollectionReferenceWrapper ref = wrapper.collection(SEASONS_COLLECTION);
    // Add the game.
    DocumentReferenceWrapper doc;
    if (pregenDoc != null) {
      await pregenDoc.setData(season.toJSON(includePlayers: true));
    } else {
      doc = await ref.add(season.toJSON(includePlayers: true));
    }
    persistenData.updateElement(PersistenData.seasonTable, season.uid,
        season.toJSON(includePlayers: true));
    return season.rebuild((b) => b..uid = doc.documentID);
  }

  @override
  DocumentReferenceWrapper precreateUidSeason() {
    CollectionReferenceWrapper ref = wrapper.collection(SEASONS_COLLECTION);
    return ref.document();
  }

  @override
  Future<void> removePlayerFromSeason(
      String seasonUid, String playerUid) async {
    DocumentReferenceWrapper doc =
        wrapper.collection(SEASONS_COLLECTION).document(seasonUid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[Season.PLAYERS + "." + playerUid] = null;
    await doc.updateData(data);
  }

  @override
  Future<void> updateRoleInTeamForSeason(
      Season season, SeasonPlayer player, RoleInTeam role) async {
    Map<String, dynamic> data = <String, dynamic>{};

    data[Season.PLAYERS + "." + player.playerUid + "." + SeasonPlayer.ROLE] =
        role.toString();
    wrapper
        .collection(SEASONS_COLLECTION)
        .document(season.uid)
        .updateData(data);
  }

  @override
  Future<bool> playerExists(String uid) async {
    // Add ourselves to the player.
    DocumentSnapshotWrapper doc =
        await wrapper.collection(PLAYERS_COLLECTION).document(uid).get();
    return doc.exists;
  }

  @override
  Future<Player> getPlayerDetails(String uid) async {
    DocumentSnapshotWrapper doc =
        await wrapper.collection(PLAYERS_COLLECTION).document(uid).get();
    if (doc.exists) {
      Player player = Player.fromJSON(uid, doc.data).build();
      return player;
    }
    return null;
  }

  // Send an invite to a user for this season and team.
  @override
  Future<String> inviteUserToSeason(
      {@required String seasonUid,
      @required String seasonName,
      @required String teamUid,
      @required String teamName,
      @required String userId,
      @required String playername,
      @required String email,
      @required RoleInTeam role}) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshotWrapper snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: seasonUid)
        .where(InviteToTeam.TEAMUID, isEqualTo: teamUid)
        .getDocuments();
    if (snapshot.documents.length > 0) {
      InviteToTeam invite = InviteFactory.makeInviteFromJSON(
          snapshot.documents[0].documentID, snapshot.documents[0].data);

      var newList = invite.playerName.toBuilder();
      newList.add(playername);
      InviteToTeam updatedInvite = new InviteToTeam((b) => b
        ..email = invite.email
        ..teamUid = invite.teamUid
        ..seasonUid = invite.uid
        ..playerName = newList
        ..sentByUid = invite.sentByUid
        ..teamName = teamName
        ..seasonName = seasonName
        ..role = role);
      snapshot.documents[0].reference.updateData(updatedInvite.toJSON());
      return snapshot.documents[0].documentID;
    } else {
      InviteToTeam invite = new InviteToTeam((b) => b
        ..email = email
        ..teamUid = teamUid
        ..seasonUid = seasonUid
        ..playerName = ListBuilder([playername])
        ..sentByUid = userId
        ..teamName = teamName
        ..seasonName = seasonName
        ..role = role);

      var doc = await ref.add(invite.toJSON());
      return doc.documentID;
    }
  }

  @override
  Stream<Iterable<InviteToTeam>> getInviteForSeasonStream(
      {@required String userUid,
      @required String seasonUid,
      @required String teamUid}) async* {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QueryWrapper query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: seasonUid)
        .where(InviteToTeam.TEAMUID, isEqualTo: teamUid);

    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper doc) =>
        InviteToTeam.fromJSON(doc.documentID, doc.data).build());

    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper doc) =>
          InviteToTeam.fromJSON(doc.documentID, doc.data).build());
    }
  }

  @override
  Stream<GameSnapshotEvent> getSeasonGames(Season season) {
    return getBasicGames(teamUid: season.teamUid, seasonUid: season.uid);
  }

  @override
  Future<Season> getSeason(String seasonUid) async {
    DocumentSnapshotWrapper doc =
        await wrapper.collection(SEASONS_COLLECTION).document(seasonUid).get();
    if (doc.exists) {
      return Season.fromJSON(doc.documentID, doc.data).build();
    }
    return null;
  }

  @override
  Future<void> addPlayerToSeason(
      String seasonUid, SeasonPlayer seasonPlayer) async {
    DocumentReferenceWrapper doc =
        await wrapper.collection(SEASONS_COLLECTION).document(seasonUid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[Season.PLAYERS + "." + seasonPlayer.playerUid] = seasonPlayer.toJSON();
    doc.updateData(data);
    return;
  }

  Future<Team> _loadTeamFromClub(
      String userUid, DocumentSnapshotWrapper snap, Club club) async {
    final TeamBuilder team = Team.fromJSON(userUid, snap.documentID, snap.data,
        publicOnly: !club.isAdmin());

    return team.build();
  }

  // Loads the seasons for the team.  This is only used for
  // admin teams and club teams.
  Stream<Iterable<Season>> getSeasonsForTeam(String teamUid) async* {
    // Find the seasons for the team.
    QueryWrapper query = wrapper
        .collection(SEASONS_COLLECTION)
        .where(Season.TEAMUID, isEqualTo: teamUid);
    List<Season> seasons = [];
    var snap = await query.getDocuments();
    for (DocumentSnapshotWrapper doc in snap.documents) {
      Season season = Season.fromJSON(doc.documentID, doc.data).build();
      persistenData.updateElement(
          PersistenData.seasonTable, season.uid, doc.data);
      seasons.add(season);
    }
    yield seasons;
    await for (QuerySnapshotWrapper snap in query.snapshots()) {
      List<Season> seasons = [];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        Season season = Season.fromJSON(doc.documentID, doc.data).build();
        persistenData.updateElement(
            PersistenData.seasonTable, season.uid, doc.data);
        seasons.add(season);
      }
      yield seasons;
    }
  }

  // clubs!
  @override
  Stream<Iterable<Team>> getClubTeams(String userUid, Club club) async* {
    QueryWrapper query = wrapper
        .collection(TEAMS_COLLECTION)
        .where(Team.CLUBUID, isEqualTo: club.uid);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    List<Team> teams = [];
    for (DocumentSnapshotWrapper snap in wrap.documents) {
      Team t = await _loadTeamFromClub(userUid, snap, club);
      teams.add(t);
    }
    yield teams;
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      List<Team> teams = [];
      for (DocumentSnapshotWrapper snap in wrap.documents) {
        Team t = await _loadTeamFromClub(userUid, snap, club);
        teams.add(t);
      }
      yield teams;
    }
  }

  @override
  Future<void> addUserToClub(String clubUid, String userUid, bool admin) {
    return wrapper
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
  Future<String> inviteUserToClub(
      {String clubName, String clubUid, String email, bool admin}) async {
    InviteToClub invite = InviteToClub((b) => b
      ..admin = admin
      ..clubUid = clubUid
      ..clubName = clubName
      ..email = email);
    DocumentReferenceWrapper ref =
        await wrapper.collection(INVITE_COLLECTION).add(invite.toJSON());
    return ref.documentID;
  }

  @override
  Future<String> addClub(DocumentReferenceWrapper ref, Club club) async {
    Map<String, dynamic> data = club.toJson(includeMembers: true);
    if (ref != null) {
      ref = await wrapper.collection(CLUB_COLLECTION).add(data);
    } else {
      await ref.updateData(data);
    }
    return ref.documentID;
  }

  @override
  Future<String> updateClub(Club club, {bool includeMembers = false}) async {
    Map<String, dynamic> data = club.toJson(includeMembers: includeMembers);
    await wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData(data);
    persistenData.updateElement(
        PersistenData.clubsTable, club.uid, club.toJson(includeMembers: true));

    return club.uid;
  }

  @override
  Future<Uri> updateClubImage(Club club, File imgFile) async {
    final StorageReferenceWrapper ref =
        wrapper.storageRef().child("club_" + club.uid + ".img");
    final StorageUploadTaskWrapper task = ref.putFile(imgFile);
    final UploadTaskSnapshotWrapper snapshot = (await task.future);
    String photoUrl = snapshot.downloadUrl.toString();
    await wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData({PHOTOURL: photoUrl});

    print('photurl ${club.photoUrl}');
    persistenData.updateElement(
        PersistenData.clubsTable, club.uid, club.toJson(includeMembers: true));
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteClubMember(Club club, String memberUid) {
    return wrapper.collection(CLUB_COLLECTION).document(club.uid).updateData(
        <String, dynamic>{Club.MEMBERS + "." + memberUid + "." + ADDED: false});
  }

  @override
  Future<Club> getClubData({String userUid, String clubUid}) async {
    DocumentSnapshotWrapper snap =
        await wrapper.collection(CLUB_COLLECTION).document(clubUid).get();
    if (snap.exists) {
      persistenData.updateElement(
          PersistenData.clubsTable, snap.documentID, snap.data);

      return Club.fromJSON(userUid, snap.documentID, snap.data).build();
    }
    return null;
  }

  // leagues!
  @override
  Stream<Iterable<LeagueOrTournamentTeam>> getLeagueDivisionTeams(
      String leagueDivisonUid) async* {
    QueryWrapper query = wrapper.collection(LEAGUE_TEAM_COLLECTION).where(
        LeagueOrTournamentTeam.LEAGUEORTOURNMENTDIVISONUID,
        isEqualTo: leagueDivisonUid);
    // Snapshot and the main query.
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        LeagueOrTournamentTeam.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          LeagueOrTournamentTeam.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<Iterable<GameSharedData>> getLeagueGamesForDivison(
      String leagueDivisonUid) async* {
    QueryWrapper query = wrapper
        .collection(GAMES_SHARED_COLLECTION)
        .where(GameSharedData.LEAGUEDIVISIONUID, isEqualTo: leagueDivisonUid);

    // Snapshot and the main query.
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        GameSharedData.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          GameSharedData.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<Iterable<GameSharedData>> getLeagueGamesForTeam(
      String leagueTeamUid) async* {
    QueryWrapper queryHome = wrapper.collection(GAMES_SHARED_COLLECTION).where(
        GameSharedData.OFFICIALRESULT + "." + GameOfficialResults.HOMETEAMUID,
        isEqualTo: leagueTeamUid);
    QueryWrapper queryAway = wrapper.collection(GAMES_SHARED_COLLECTION).where(
        GameSharedData.OFFICIALRESULT + "." + GameOfficialResults.AWAYTEAMUID,
        isEqualTo: leagueTeamUid);

    // Snapshot and the main query.
    Map<String, GameSharedData> games = {};
    QuerySnapshotWrapper wrapHome = await queryHome.getDocuments();
    wrapHome.documents.forEach((DocumentSnapshotWrapper wrap) =>
        games[wrap.documentID] =
            GameSharedData.fromJSON(wrap.documentID, wrap.data).build());
    QuerySnapshotWrapper wrapAway = await queryAway.getDocuments();
    wrapAway.documents.forEach((DocumentSnapshotWrapper wrap) =>
        games[wrap.documentID] =
            GameSharedData.fromJSON(wrap.documentID, wrap.data).build());
    yield games.values;

    StreamGroup<QuerySnapshotWrapper> str = StreamGroup<QuerySnapshotWrapper>();
    str.add(queryHome.snapshots());
    str.add(queryAway.snapshots());

    await for (QuerySnapshotWrapper snap in str.stream) {
      snap.documentChanges.forEach((DocumentChangeWrapper change) {
        if (change.type == DocumentChangeTypeWrapper.removed) {
          games.remove(change.document.documentID);
        } else {
          games[change.document.documentID] = GameSharedData.fromJSON(
                  change.document.documentID, change.document.data)
              .build();
        }
      });

      yield games.values;
    }
  }

  @override
  Future<void> addUserToLeague(String leagueUid, String userUid, bool admin) {
    return wrapper
        .collection(LEAGUE_COLLECTON)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      LeagueOrTournament.MEMBERS + "." + userUid: <String, dynamic>{
        ADDED: true,
        LeagueOrTournament.ADMIN: admin
      }
    });
  }

  @override
  Future<void> addUserToLeagueSeason(
      String leagueUid, String userUid, bool admin) {
    return wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      LeagueOrTournamentSeason.MEMBERS + "." + userUid: <String, dynamic>{
        ADDED: true,
        LeagueOrTournamentSeason.ADMIN: admin
      }
    });
  }

  @override
  Future<void> addUserToLeagueDivison(
      String leagueUid, String userUid, bool admin) {
    return wrapper
        .collection(LEAGUE_COLLECTON)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      LeagueOrTournamentDivison.MEMBERS + "." + userUid: <String, dynamic>{
        ADDED: true,
        LeagueOrTournamentDivison.ADMIN: admin
      }
    });
  }

  @override
  Future<String> inviteUserToLeague(InviteToLeagueAsAdmin invite) async {
    DocumentReferenceWrapper ref =
        await wrapper.collection(INVITE_COLLECTION).add(invite.toJSON());
    return ref.documentID;
  }

  Future<String> inviteUserToLeagueTeam(
      {String userUid,
      String leagueSeasonUid,
      LeagueOrTournamentTeam leagueTeam,
      String email}) async {
    LeagueOrTournamentSeason season =
        await getLeagueSeasonData(leagueSeasonUid);
    LeagueOrTournament leagueOrTournament = await getLeagueData(
        userUid: userUid, leagueUid: season.leagueOrTournmentUid);

    InviteToLeagueTeam teamInvite = new InviteToLeagueTeam((b) => b
      ..email = email
      ..leagueName = leagueOrTournament.name
      ..sentByUid = userUid
      ..leagueDivisonUid = leagueTeam.leagueOrTournamentDivisonUid
      ..leagueTeamName = leagueTeam.name
      ..leagueUid = leagueOrTournament.uid
      ..leagueSeasonName = season.name
      ..leagueTeamUid = leagueTeam.uid);
    // Write it out to firestore.  Yay.
    var doc =
        await wrapper.collection(INVITE_COLLECTION).add(teamInvite.toJSON());
    return doc.documentID;
  }

  @override
  Stream<Iterable<InviteToLeagueTeam>> getLeagueOrTournmentTeamInvitesStream(
      String leagueTeamUid) async* {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QueryWrapper query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.LeagueTeam.toString())
        .where(InviteToLeagueTeam.LEAGUETEAMUID, isEqualTo: leagueTeamUid);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        InviteToLeagueTeam.fromJSON(snap.documentID, snap.data).build());

    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          InviteToLeagueTeam.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Future<String> updateLeague(LeagueOrTournament league,
      {bool includeMembers = false}) async {
    Map<String, dynamic> data = league.toJson(includeMembers: includeMembers);
    if (league.uid == null) {
      DocumentReferenceWrapper ref =
          await wrapper.collection(LEAGUE_COLLECTON).add(data);
      return ref.documentID;
    } else {
      await wrapper
          .collection(LEAGUE_COLLECTON)
          .document(league.uid)
          .updateData(data);
    }
    persistenData.updateElement(PersistenData.leagueOrTournamentTable,
        league.uid, league.toJson(includeMembers: true));

    return league.uid;
  }

  @override
  Future<Uri> updateLeagueImage(LeagueOrTournament league, File imgFile) async {
    final StorageReferenceWrapper ref =
        wrapper.storageRef().child("league_" + league.uid + ".jpg");
    final StorageUploadTaskWrapper task = ref.putFile(imgFile);
    final UploadTaskSnapshotWrapper snapshot = (await task.future);
    final String photoUrl = snapshot.downloadUrl.toString();
    // Update the reference in the class.
    await wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData({PHOTOURL: photoUrl});
    print('photurl ${league.photoUrl}');
    persistenData.updateElement(PersistenData.leagueOrTournamentTable,
        league.uid, league.toJson(includeMembers: true));
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteLeagueMember(LeagueOrTournament league, String memberUid) {
    return wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData(<String, dynamic>{
      LeagueOrTournament.MEMBERS + "." + memberUid + "." + ADDED: false
    });
  }

  @override
  Future<LeagueOrTournament> getLeagueData(
      {String userUid, String leagueUid}) async {
    DocumentSnapshotWrapper snap =
        await wrapper.collection(LEAGUE_COLLECTON).document(leagueUid).get();
    if (snap.exists) {
      persistenData.updateElement(
          PersistenData.leagueOrTournamentTable, snap.documentID, snap.data);
      return LeagueOrTournament.fromJSON(
              userUid: userUid, myUid: snap.documentID, data: snap.data)
          .build();
    }
    return null;
  }

  @override
  Stream<Iterable<LeagueOrTournamentSeason>> getLeagueSeasons(
      {String userUid, String leagueUid}) async* {
    QueryWrapper query = wrapper.collection(LEAGUE_SEASON_COLLECTION).where(
        LeagueOrTournamentSeason.LEAGUEORTOURNMENTUID,
        isEqualTo: leagueUid);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        LeagueOrTournamentSeason.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          LeagueOrTournamentSeason.fromJSON(snap.documentID, snap.data)
              .build());
    }
  }

  @override
  Stream<Iterable<LeagueOrTournamentDivison>> getLeagueDivisonsForSeason(
      {String leagueSeasonUid, String memberUid}) async* {
    QueryWrapper query = wrapper.collection(LEAGUE_DIVISION_COLLECTION).where(
        LeagueOrTournamentDivison.LEAGUEORTOURNMENTSEASONUID,
        isEqualTo: leagueSeasonUid);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        LeagueOrTournamentDivison.fromJSON(
                snap.documentID, memberUid, snap.data)
            .build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          LeagueOrTournamentDivison.fromJSON(
                  snap.documentID, memberUid, snap.data)
              .build());
    }
  }

  @override
  Stream<Iterable<LeagueOrTournamentTeam>> getLeagueTeamsForTeamSeason(
      String teamSeasonUid) async* {
    QueryWrapper query = wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .where(LeagueOrTournamentTeam.SEASONUID, isEqualTo: teamSeasonUid);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        LeagueOrTournamentTeam.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          LeagueOrTournamentTeam.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<LeagueOrTournamentDivison> getLeagueDivisionData(
      {String leagueDivisionUid, String memberUid}) async* {
    DocumentReferenceWrapper doc = await wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(leagueDivisionUid);
    DocumentSnapshotWrapper wrap = await doc.get();
    if (wrap.exists) {
      yield LeagueOrTournamentDivison.fromJSON(
              wrap.documentID, memberUid, wrap.data)
          .build();
    } else {
      yield null;
    }
    await for (DocumentSnapshotWrapper wrap in doc.snapshots()) {
      yield LeagueOrTournamentDivison.fromJSON(
              wrap.documentID, memberUid, wrap.data)
          .build();
    }
  }

  @override
  Future<LeagueOrTournamentSeason> getLeagueSeasonData(
      String leagueSeasonUid) async {
    DocumentSnapshotWrapper doc = await wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(leagueSeasonUid)
        .get();
    if (doc.exists) {
      return LeagueOrTournamentSeason.fromJSON(doc.documentID, doc.data)
          .build();
    }
    return null;
  }

  @override
  Future<String> updateLeagueDivison(LeagueOrTournamentDivison division) async {
    if (division.uid == null) {
      DocumentReferenceWrapper doc = await wrapper
          .collection(LEAGUE_DIVISION_COLLECTION)
          .add(division.toJSON());
      return doc.documentID;
    }
    await wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(division.uid)
        .updateData(division.toJSON());
    return division.uid;
  }

  @override
  Future<String> updateLeagueSeason(LeagueOrTournamentSeason season) async {
    if (season.uid == null) {
      DocumentReferenceWrapper doc = await wrapper
          .collection(LEAGUE_SEASON_COLLECTION)
          .add(season.toJSON());
      return doc.documentID;
    }
    await wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(season.uid)
        .updateData(season.toJSON());
    return season.uid;
  }

  @override
  Future<String> updateLeagueTeam(LeagueOrTournamentTeam team) async {
    if (team.uid == null) {
      DocumentReferenceWrapper doc =
          await wrapper.collection(LEAGUE_TEAM_COLLECTION).add(team.toJSON());
      return doc.documentID;
    }
    await wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(team.uid)
        .updateData(team.toJSON());
    return team.uid;
  }

  @override
  Future<void> updateLeagueTeamRecord(
      LeagueOrTournamentTeam team, String divison, WinRecord record) async {
    DocumentReferenceWrapper doc =
        await wrapper.collection(LEAGUE_TEAM_COLLECTION).document(team.uid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[LeagueOrTournamentTeam.WINRECORD + "." + divison] = record.toJSON();
    doc.updateData(data);
  }

  @override
  Stream<LeagueOrTournamentTeam> getLeagueTeamData(String teamUid) async* {
    DocumentReferenceWrapper ref =
        wrapper.collection(LEAGUE_TEAM_COLLECTION).document(teamUid);
    DocumentSnapshotWrapper snap = await ref.get();
    yield LeagueOrTournamentTeam.fromJSON(snap.documentID, snap.data).build();
    await for (DocumentSnapshotWrapper snap in ref.snapshots()) {
      yield LeagueOrTournamentTeam.fromJSON(snap.documentID, snap.data).build();
    }
  }

  Future<bool> connectLeagueTeamToSeason(
      String leagueTeamUid, String userUid, Season season) async {
    DocumentSnapshotWrapper doc = await wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(leagueTeamUid)
        .get();
    // If it is already connected to a season, abort!
    if (!doc.exists) {
      return false;
    }
    LeagueOrTournamentTeam team =
        LeagueOrTournamentTeam.fromJSON(doc.documentID, doc.data).build();
    if (team.seasonUid != null) {
      return false;
    }
    // Connect it and save it.
    Map<String, String> data = <String, String>{};
    data[LeagueOrTournamentTeam.SEASONUID] = season.uid;
    data[LeagueOrTournamentTeam.TEAMUID] = season.teamUid;
    await wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(leagueTeamUid)
        .updateData(data);
    return true;
  }

  // Initial data
  @override
  Stream<Iterable<Club>> getMainClubs(String userUid) async* {
    QueryWrapper query = wrapper
        .collection(CLUB_COLLECTION)
        .where(Club.MEMBERS + "." + userUid + "." + ADDED, isEqualTo: true);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        Club.fromJSON(userUid, snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          Club.fromJSON(userUid, snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<Iterable<LeagueOrTournament>> getMainLeagueOrTournaments(
      String userUid) async* {
    QueryWrapper query = wrapper.collection(LEAGUE_COLLECTON).where(
        LeagueOrTournament.MEMBERS + "." + userUid + "." + ADDED,
        isEqualTo: true);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        LeagueOrTournament.fromJSON(
                myUid: snap.documentID, data: snap.data, userUid: userUid)
            .build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          LeagueOrTournament.fromJSON(
                  myUid: snap.documentID, data: snap.data, userUid: userUid)
              .build());
    }
  }

  @override
  Stream<Iterable<Player>> getPlayers(String userUid) async* {
    QueryWrapper query = wrapper
        .collection(PLAYERS_COLLECTION)
        .where(Player.USERS + "." + userUid + "." + ADDED, isEqualTo: true);
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        Player.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          Player.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<Iterable<MessageRecipient>> getMessages(
      String userUid, bool unread) async* {
    QueryWrapper query;
    if (unread) {
      query = wrapper
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.USERID, isEqualTo: userUid)
          .where(MessageRecipient.STATE,
              isEqualTo: MessageState.Unread.toString());
    } else {
      query = wrapper
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.USERID, isEqualTo: userUid)
          .orderBy(MessageRecipient.SENTAT)
          .limit(maxMessages);
    }
    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        MessageRecipient.fromJSON(snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          MessageRecipient.fromJSON(snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<Iterable<Invite>> getInvites(String email) async* {
    QueryWrapper query = wrapper
        .collection(INVITE_COLLECTION)
        .where(Invite.EMAIL, isEqualTo: normalizeEmail(email));

    QuerySnapshotWrapper wrap = await query.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        InviteFactory.makeInviteFromJSON(snap.documentID, snap.data));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          InviteFactory.makeInviteFromJSON(snap.documentID, snap.data));
    }
  }

  @override
  Stream<Iterable<Team>> getTeamAdmins(String userUid) async* {
    QueryWrapper teamCollection = wrapper
        .collection(TEAMS_COLLECTION)
        .where(Team.ADMINS + "." + userUid, isEqualTo: true);

    QuerySnapshotWrapper wrap = await teamCollection.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
        Team.fromJSON(userUid, snap.documentID, snap.data).build());
    await for (QuerySnapshotWrapper wrap in teamCollection.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper snap) =>
          Team.fromJSON(userUid, snap.documentID, snap.data).build());
    }
  }

  @override
  Stream<Iterable<InviteToClub>> getInviteToClubStream(String clubUid) async* {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QueryWrapper snapshot = await ref
        .where(InviteToClub.CLUBUID, isEqualTo: clubUid)
        .where(Invite.TYPE, isEqualTo: InviteType.Club.toString());

    QuerySnapshotWrapper wrap = await snapshot.getDocuments();
    yield wrap.documents.map((DocumentSnapshotWrapper doc) =>
        InviteToClub.fromJSON(doc.documentID, doc.data).build());
    await for (QuerySnapshotWrapper wrap in snapshot.snapshots()) {
      yield wrap.documents.map((DocumentSnapshotWrapper doc) =>
          InviteToClub.fromJSON(doc.documentID, doc.data).build());
    }
  }
}
