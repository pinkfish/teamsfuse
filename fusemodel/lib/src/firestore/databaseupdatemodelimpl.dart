import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:built_collection/built_collection.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart';

import '../../fusemodel.dart';
import 'authenticationbloc.dart';
import 'firestore.dart';

///
/// Implementation of the database model for getting data from firestone.
///
class DatabaseUpdateModelImpl implements DatabaseUpdateModel {
  static final int _maxMessages = 20;
  final FirestoreWrapper _wrapper;
  final AuthenticationBloc _authenticationBloc;
  final AnalyticsSubsystem _analytics;

  /// The user data connected to this system.
  UserData userData;

  /// Constructs the database update system implementation.
  DatabaseUpdateModelImpl(
      this._wrapper, this._authenticationBloc, this._analytics) {
    _authenticationBloc.listen((state) {
      if (state is AuthenticationLoggedIn) {
        userData = state.user;
      }
      if (state is AuthenticationLoggedOut) {
        userData = null;
      }
    });
  }

  @override
  UserData get currentUser => userData;

  // Stuff for game updates.
  @override
  Future<Game> updateFirestoreGame(Game game, bool sharedData) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection(GAMES_COLLECTION);
    var refShared = _wrapper.collection(GAMES_SHARED_COLLECTION);
    _analytics.logEvent(name: "updateGame");
    if (game.uid == null || game.uid == '') {
      var ref = _wrapper.collection(GAMES_COLLECTION).document();
      var refShared = _wrapper.collection(GAMES_SHARED_COLLECTION).document();
      var data = await _wrapper.runTransaction((tx) async {
        var gameBuilder = game.toBuilder();
        // Add the shared stuff, then the game.
        if (game.sharedData.officialResult.homeTeamLeagueUid == null) {
          gameBuilder.sharedData.officialResult.homeTeamLeagueUid =
              game.teamUid;
        }
        gameBuilder.sharedData.uid = refShared.documentID;
        tx.set(refShared, game.sharedData.toMap());
        gameBuilder.sharedDataUid = refShared.documentID;
        gameBuilder.uid = ref.documentID;
        print(
            "Writing game ${gameBuilder.sharedDataUid} ${gameBuilder.teamUid}");
        // Add the game.
        tx.set(ref, gameBuilder.build().toMap());
        return gameBuilder.build().toMap();
      });
      return Game.fromMap(data);
    } else {
      if (sharedData) {
        if (game.sharedDataUid.isEmpty) {
          var sharedDoc = await refShared.add(game.sharedData.toMap());
          game = game.rebuild((b) => b..sharedDataUid = sharedDoc.documentID);
        } else {
          refShared
              .document(game.sharedDataUid)
              .updateData(game.sharedData.toMap());
        }
      }
      // Update the game.
      ref.document(game.uid).updateData(game.toMap());
      return game;
    }
  }

  @override
  Future<void> addTrainingEvents(Game game, Iterable<DateTime> dates) async {
    var ref = List.generate(
        dates.length, (i) => _wrapper.collection(GAMES_COLLECTION).document());
    var refShared = List.generate(dates.length,
        (i) => _wrapper.collection(GAMES_SHARED_COLLECTION).document());
    var mainRef = _wrapper.collection(GAMES_COLLECTION).document();
    var mainShared = _wrapper.collection(GAMES_SHARED_COLLECTION).document();

    await _wrapper.runTransaction((tx) async {
      var gameBuilder = game.toBuilder();
      gameBuilder.uid = mainRef.documentID;
      // Add the shared stuff, then the game.
      if (game.sharedData.officialResult.homeTeamLeagueUid == null) {
        gameBuilder.sharedData.officialResult.homeTeamLeagueUid = game.teamUid;
      }
      var s = game.sharedData.rebuild((b) => b..uid = mainShared.documentID);
      tx.set(mainShared, s.toMap());
      gameBuilder.sharedDataUid = mainShared.documentID;
      // Add the game.
      tx.set(mainRef, gameBuilder.build().toMap());
      for (var i = 0; i < dates.length; i++) {
        var time = dates.elementAt(i);
        if (game.sharedData.time != time.millisecondsSinceEpoch) {
          tx.set(refShared[i], game.sharedData.toMap());
          gameBuilder.sharedDataUid = refShared[i].documentID;
          // Add the game.
          tx.set(ref[i], gameBuilder.build().toMap());
          _analytics.logEvent(name: "addTrainingEvent");
        }
      }
      return s.toMap();
    });
    return;
  }

  @override
  Future<String> updateFirestoreSharedGame(GameSharedData game) async {
    // Add or update this record into the database.
    var refShared = _wrapper.collection(GAMES_SHARED_COLLECTION);
    _analytics.logEvent(name: "updateSharedGame");
    if (game.uid == null || game.uid == '') {
      // Add the shared stuff, then the game.
      var sharedDoc = await refShared.add(game.toMap());
      // Add the game.
      return sharedDoc.documentID;
    } else {
      await refShared.document(game.uid).updateData(game.toMap());

      // Update the game.
      return game.uid;
    }
  }

  @override
  Future<void> deleteFirestoreGame(Game game) async {
    // delete from the database.
    var ref = _wrapper.collection(GAMES_COLLECTION).document(game.uid);
    _analytics.logEvent(name: "deleteGame");
    return ref.delete();
  }

  @override
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(game.uid);

    var data = <String, dynamic>{};
    data["${Game.ATTENDANCE}.$playerUid"] = attend.toString();
    _analytics.logEvent(name: "updateGameAttendance");

    return ref.updateData(data).then((a) => print('Done stuff'));
  }

  @override
  Future<void> updateFirestoreGameResult(
      String gameUid, GameResultDetails result) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);

    var data = <String, dynamic>{};
    data[Game.RESULT] = result.toMap();
    _analytics.logEvent(name: "updateGameResult");
    return ref.updateData(data);
  }

  Future<void> updateFirestoreOfficalGameResult(
      String sharedGameUid, GameOfficialResults result) {
    var ref =
        _wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);

    var data = <String, dynamic>{};
    data[GameSharedData.OFFICIALRESULT] = result.toMap();
    _analytics.logEvent(name: "updateOfficalGameResult");

    return ref.updateData(data);
  }

  // Invite firestore updates
  @override
  Future<void> firestoreInviteDelete(String inviteUid) {
    _analytics.logEvent(name: "inviteDelete");
    return _wrapper.collection(INVITE_COLLECTION).document(inviteUid).delete();
  }

  // Message Recipients
  @override
  Future<void> updateMessageRecipientState(
      MessageRecipient rec, MessageReadState state) {
    var doc =
        _wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document(rec.uid);
    _analytics.logEvent(name: "updateMessageRecipientState");

    return doc.updateData({MessageRecipient.STATE: state.toString()});
  }

  @override
  Future<void> deleteRecipient(MessageRecipient rec) {
    var doc =
        _wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document(rec.uid);
    return doc.delete();
  }

  @override
  Stream<Iterable<GameLog>> readGameLogs(Game game) async* {
    var coll = _wrapper
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    var snap = await coll.getDocuments();
    yield snap.documents.map((doc) => GameLog.fromMap(doc.data));

    await for (var snap in coll.snapshots()) {
      yield snap.documents.map((doc) => GameLog.fromMap(doc.data));
    }
  }

  @override
  Future<String> addFirestoreGameLog(Game game, GameLog log) {
    var coll = _wrapper
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    var ref = coll.document();

    log = log.rebuild((b) => b
      ..eventTimeInternal = TZDateTime.now(local).millisecondsSinceEpoch
      ..uid = ref.documentID);
    return ref.setData(log.toMap()).then((v) {
      return ref.documentID;
    }).catchError((e) {
      print("Got error $e");
      return null;
    });
  }

  // Message for firestore.
  @override
  Future<Message> updateFirestoreMessage(MessageBuilder mess) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection("Messages");
    _analytics.logEvent(name: "updateMessage");
    if (mess.uid == '' || mess.uid == null) {
      // Add the message.
      mess.timeSent = DateTime.now().toUtc();
      var newDoc = ref.document();
      mess.uid = newDoc.documentID;
      Message messageStuff = mess.build();
      var messData = messageStuff.toMap();
      messData[Message.TIMESENT] = _wrapper.fieldValueServerTimestamp;
      await newDoc.setData(messageStuff.toMap());

      // Add in the recipients collection.
      for (var str in messageStuff.recipients.keys) {
        var docRef =
            _wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document();
        var rec = mess.recipients[str].rebuild((b) => b
          ..messageId = mess.uid
          ..sentAt = mess.timeSent
          ..uid = docRef.documentID);
        var data = rec.toMap();
        data[MessageRecipient.SENTAT] = _wrapper.fieldValueServerTimestamp;
        await docRef.setData(data);
        mess.recipients[str] = rec;
      }
      return mess.build();
    } else {
      // Update the message.
      Message myMess = mess.build();
      await ref.document(mess.uid).updateData(mess.build().toMap());
      return myMess;
    }
  }

  @override
  Future<Message> addMessage(Message mess, String body) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection("Messages");
    _analytics.logEvent(name: "updateMessage");
    var newDoc = ref.document();
    mess = mess.rebuild((b) => b
      ..timeSent = DateTime.now().toUtc()
      ..uid = newDoc.documentID);
    var bodyRef = _wrapper
        .collection(MESSAGES_COLLECTION)
        .document(newDoc.documentID)
        .collection(MESSAGES_COLLECTION)
        .document(newDoc.documentID);
    await _wrapper.runTransaction((t) async {
      // Add the message.
      var data = mess.toMap();
      data[Message.TIMESENT] = _wrapper.fieldValueServerTimestamp;
      await t.set(newDoc, data);

      // Add the body.
      var messageData = <String, dynamic>{};
      messageData[Message.BODY] = body;
      await t.set(bodyRef, messageData);

      // Add in the recipients collection.
      var recipients = mess.recipients.toBuilder();
      var sentTo = Set<String>();
      for (var str in mess.recipients.keys) {
        if (!sentTo.contains(mess.recipients[str].userId)) {
          var docRef =
              _wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document();
          var rec = mess.recipients[str].rebuild((b) => b
            ..messageId = mess.uid
            ..sentAt = mess.timeSent
            ..uid = docRef.documentID);
          var recipientData = mess.toMap();
          recipientData[MessageRecipient.SENTAT] =
              _wrapper.fieldValueServerTimestamp;
          await t.set(docRef, recipientData);
          recipients[str] = rec;
          sentTo.add(mess.recipients[str].userId);
        }
      }
      mess = mess.rebuild((b) => b..recipients = recipients);
      return mess.toMap();
    });
    return mess;
  }

  @override
  Stream<String> loadMessageBody(String messageUid) async* {
    var ref = _wrapper
        .collection(MESSAGES_COLLECTION)
        .document(messageUid)
        .collection(MESSAGES_COLLECTION)
        .document(messageUid);
    var snap = await ref.get();
    print("Message body $messageUid");
    if (snap.exists) {
      print(snap.data);
      yield snap.data[Message.BODY] as String;
    } else {
      yield null;
    }
    await for (DocumentSnapshotWrapper snapper in ref.snapshots()) {
      if (snapper.exists) {
        yield snapper.data[Message.BODY];
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<Message> getMessage(String messageId) async* {
    var ref =
        await _wrapper.collection(MESSAGES_COLLECTION).document(messageId);
    var snap = await ref.get();
    if (snap.exists) {
      yield Message.fromMap(snap.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Message.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  // Opponent update
  @override
  Future<String> updateFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    var ref = _wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION);
    // Update the game.
    await ref.document(opponent.uid).updateData(opponent.toMap());
    _analytics.logEvent(name: "updateOpponent");
    return opponent.uid;
  }

  @override
  Future<Opponent> addFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    var ref = _wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION);
    var docRef = ref.document();
    opponent = opponent.rebuild((b) => b..uid = docRef.documentID);
    // Add the game.
    await docRef.setData(opponent.toMap());
    _analytics.logEvent(name: "addOpponent");

    return opponent;
  }

  @override
  Future<void> deleteFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    _analytics.logEvent(name: "deleteOpponent");
    return _wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION)
        .document(opponent.uid)
        .delete();
  }

  Game _getWholeGame(DocumentSnapshotWrapper snap, String teamUid) {
    return Game.fromMap(snap.data);
  }

  @override
  Stream<Iterable<Game>> getOpponentGames(Opponent opponent) async* {
    var ref = _wrapper.collection(GAMES_COLLECTION);
    // See if the games for the season.
    var snap = ref
        .where(Game.TEAMUID, isEqualTo: opponent.teamUid)
        .where(Game.OPPONENTUID, isEqualTo: opponent.uid);
    var query = await snap.getDocuments();
    var g = <Game>[];
    for (var doc in query.documents) {
      g.add(_getWholeGame(doc, opponent.teamUid));
    }
    yield g;
    await for (var query in snap.snapshots()) {
      var g = <Game>[];
      for (var doc in query.documents) {
        g.add(_getWholeGame(doc, opponent.teamUid));
      }
      yield g;
    }
  }

  @override
  Stream<Iterable<Opponent>> getTeamOpponents(String teamUid) async* {
    var opCollection = _wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .collection(OPPONENT_COLLECTION);
    var queryOpponentSnap = await opCollection.getDocuments();

    yield queryOpponentSnap.documents.map((doc) => Opponent.fromMap(doc.data));
    await for (var query in opCollection.snapshots()) {
      yield query.documents.map((doc) => Opponent.fromMap(doc.data));
    }
  }

  @override
  Stream<Opponent> getFirestoreOpponent(
      {String teamUid, String opponentUid}) async* {
    var opCollection = _wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .collection(OPPONENT_COLLECTION)
        .document(opponentUid);
    var queryOpponentSnap = await opCollection.get();

    if (queryOpponentSnap.exists) {
      yield Opponent.fromMap(queryOpponentSnap.data);
    } else {
      yield null;
    }
    await for (var snap in opCollection.snapshots()) {
      if (snap.exists) {
        yield Opponent.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Future<void> updateFirestoreTeam(Team team) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection(TEAMS_COLLECTION).document(team.uid);

    // Update the game.
    await ref.updateData(team.toMap());
    _analytics.logEvent(name: "updateTeam");
    return team.uid;
  }

  @override
  Future<String> addFirestoreTeam(Team team, DocumentReferenceWrapper pregen,
      Season season, Uint8List imageFile) async {
    // Add or update this record into the database.
    if (pregen == null) {
      pregen = _wrapper.collection(TEAMS_COLLECTION).document();
    }
    var pregenSeason = _wrapper.collection(SEASONS_COLLECTION).document();
    var admins = team.adminsData.toBuilder();

    // Make sure we are admin in the team.
    admins[currentUser.uid] = true;
    await _wrapper.runTransaction((tx) async {
      await tx.set(
          pregen,
          team
              .rebuild((b) => b
                ..uid = pregen.documentID
                ..adminsData = admins
                ..currentSeason = pregenSeason.documentID)
              .toMap());
      await tx.set(
          pregenSeason,
          season
              .rebuild((b) => b
                ..uid = pregenSeason.documentID
                ..teamUid = pregen.documentID)
              .toMap(includePlayers: true));
      return {};
    });
    if (imageFile != null && imageFile.isNotEmpty) {
      updateTeamImage(pregen.documentID, imageFile);
    }
    _analytics.logEvent(name: "addTeam");

    return pregen.documentID;
  }

  @override
  DocumentReferenceWrapper precreateTeamUid() {
    var ref = _wrapper.collection(TEAMS_COLLECTION);
    return ref.document();
  }

  @override
  DocumentReferenceWrapper precreateClubUid() {
    var ref = _wrapper.collection(CLUB_COLLECTION);
    return ref.document();
  }

  @override
  Future<Uri> updateTeamImage(String teamUid, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child("team_$teamUid.img");
    var task = ref.putFile(imgFile);
    var snapshot = await task.future;
    var photoUrl = snapshot.downloadUrl;
    await _wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .updateData({PHOTOURL: photoUrl.toString()});
    _analytics.logEvent(name: "updateTeamImage");
    return photoUrl;
  }

  @override
  Future<void> deleteAdmin(Team team, String uid) {
    var ref = _wrapper.collection(TEAMS_COLLECTION).document(team.uid);
    _analytics.logEvent(name: "deleteAdmin");
    return ref.updateData(<String, dynamic>{"${Team.ADMINS}.$uid": false});
  }

  @override
  Future<String> addAdmin(String teamUid, String uid) async {
    var ref = _wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    await ref.updateData(<String, dynamic>{"${Team.ADMINS}.$uid": true});
    _analytics.logEvent(name: "addAdmin");
    return ref.documentID;
  }

  @override
  Stream<Iterable<InviteAsAdmin>> getInviteForTeamStream(Team team) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: team.uid);
    var wrap = await snap.getDocuments();
    yield wrap.documents.map((wrap) => InviteAsAdmin.fromMap(wrap.data));

    await for (var wrap in snap.snapshots()) {
      yield wrap.documents.map((wrap) => InviteAsAdmin.fromMap(wrap.data));
    }
  }

  @override
  Stream<Iterable<InviteAsAdmin>> getInvitesForTeam(String teamUid) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: teamUid);

    var queryData = await query.getDocuments();
    var ret = <InviteAsAdmin>[];
    for (var doc in queryData.documents) {
      var invite = InviteAsAdmin.fromMap(doc.data);
      ret.add(invite);
    }
    yield ret;
    await for (var data in query.snapshots()) {
      var ret = <InviteAsAdmin>[];

      for (var doc in data.documents) {
        var invite = InviteAsAdmin.fromMap(doc.data);
        ret.add(invite);
      }
      yield ret;
    }
  }

  @override
  Stream<Team> getPublicTeamDetails({@required String teamUid}) async* {
    var ref = _wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    var snap = await ref.get();
    if (snap.exists) {
      var team = Team.fromMap(userData?.uid ?? "", snap.data)
        ..rebuild((b) => b..publicOnly = true);
      yield team;
    } else {
      yield null;
    }
    await for (var doc in ref.snapshots()) {
      if (doc != null && doc.exists) {
        yield Team.fromMap(userData?.uid ?? "", snap.data)
          ..rebuild((b) => b..publicOnly = true);
        ;
      } else {
        yield Team((b) => b..uid = teamUid);
      }
    }
  }

  @override
  Stream<Team> getTeamDetails({@required String teamUid}) async* {
    print("Building $teamUid");
    var referenceWrapper =
        _wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    var snap = await referenceWrapper.get();
    if (snap != null && snap.exists) {
      yield Team.fromMap(userData?.uid ?? "", snap.data);
    } else {
      yield Team((b) => b..uid = teamUid);
    }
    await for (var doc in referenceWrapper.snapshots()) {
      if (doc != null && doc.exists) {
        yield Team.fromMap(userData?.uid ?? "", doc.data);
      } else {
        yield Team((b) => b..uid = teamUid);
      }
    }
  }

  ///
  /// Returns the basic set of games for this specific team.
  ///
  Stream<GameSnapshotEvent> getBasicGames(
      {DateTime start, DateTime end, String teamUid, String seasonUid}) async* {
    Stream<GameSnapshotEvent> mainGameStream;
    var str = StreamGroup<GameSnapshotEvent>();
    try {
      var gameQuery = _wrapper
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
      var queryGameSnap = await gameQuery.getDocuments();

      var data = Set<Game>();
      for (var snap in queryGameSnap.documents) {
        var sharedGameUid = snap.data[Game.SHAREDDATAUID];
        if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
          //print(snap.data[Game.GAMESHAREDDATA]);
          //snap.data[Game.GAMESHAREDDATA]['uid'] = sharedGameUid;
          // Not setup, load from the shared collection.
          if (snap.data[Game.GAMESHAREDDATA] == null) {
            // Need to read it ourselves right now.
            var tempData = await _wrapper
                .collection(GAMES_SHARED_COLLECTION)
                .document(sharedGameUid)
                .get();
            snap.data[Game.GAMESHAREDDATA] = tempData.data;
            // sharedData = GameSharedData.fromMap(tempData.data);
            // Fix the doc too.
            await _wrapper
                .collection(GAMES_COLLECTION)
                .document(snap.documentID)
                .updateData({
              Game.GAMESHAREDDATA: tempData.data,
            });
          }
        } else {
          // Missing shared data uid.
          snap.data[Game.GAMESHAREDDATA] = snap.data;
        }
        var g = Game.fromMap(snap.data);
        data.add(g);
      }
      yield GameSnapshotEvent(
          teamUid: teamUid, newGames: data, deletedGames: []);

      // Merge the streams.
      mainGameStream = gameQuery.snapshots().asyncMap((queryGameSnap) async {
        var data = Set<Game>();
        for (var snap in queryGameSnap.documents) {
          String sharedGameUid;
          sharedGameUid = snap.data[Game.SHAREDDATAUID] as String;
          if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
          } else {
            snap.data[Game.GAMESHAREDDATA] = snap.data;
          }

          var newGame = Game.fromMap(snap.data);
          data.add(newGame);
        }
        var toDelete = queryGameSnap.documentChanges
            .where((wrap) => wrap.type == DocumentChangeTypeWrapper.removed)
            .map<String>((wrap) => wrap.document.documentID);
        return GameSnapshotEvent(
            teamUid: teamUid, newGames: data, deletedGames: toDelete);
      });

      str.add(mainGameStream);
      await for (GameSnapshotEvent queryGameSnap in str.stream) {
        yield queryGameSnap;
      }
    } finally {
      str.close();
    }
  }

  // Games!
  @override
  Stream<GameSharedData> getSharedGame(String sharedGameUid) async* {
    var ref =
        _wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);
    var wrap = await ref.get();
    yield GameSharedData.fromMap(wrap.data);
    await for (var wrap in ref.snapshots()) {
      yield GameSharedData.fromMap(wrap.data);
    }
  }

  @override
  Stream<Game> getGame(String gameUid) async* {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    var snap = await ref.get();
    if (!snap.exists) {
      yield null;
    } else {
      yield Game.fromMap(snap.data);
    }

    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Game.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  // Player stuff
  @override
  Future<void> updateFirestorePlayer(Player player, bool includeUsers) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection(PLAYERS_COLLECTION);
    // Update the game.
    await ref
        .document(player.uid)
        .updateData(player.toMap(includeUsers: includeUsers));
    _analytics.logEvent(name: "updatePlayer");
  }

  // Player stuff
  @override
  Future<String> addFirestorePlayer(Player player) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection(PLAYERS_COLLECTION);
    var docRef = ref.document();
    // Add the game.
    var p = player.rebuild((b) => b..uid = docRef.documentID);
    await docRef.setData(p.toMap(includeUsers: true));
    _analytics.logEvent(name: "addPlayer");
    return docRef.documentID;
  }

  @override
  Future<Uri> updatePlayerImage(String playerUid, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child("player_$playerUid.img");
    var task = ref.putFile(imgFile);
    var snapshot = (await task.future);
    var photoUrl = snapshot.downloadUrl.toString();
    var data = <String, String>{};
    data[PHOTOURL] = photoUrl;
    await _wrapper
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .updateData(data);
    _analytics.logEvent(name: "updatePlayerImage");
    return snapshot.downloadUrl;
  }

  @override
  Stream<Iterable<Season>> getPlayerSeasons(String playerUid) async* {
    var ref = _wrapper
        .collection(SEASONS_COLLECTION)
        .where("${Season.PLAYERS}.$playerUid.$ADDED", isEqualTo: true)
        .where("${Season.USER}.${userData.uid}.$ADDED", isEqualTo: true);
    var wrap = await ref.getDocuments();
    yield wrap.documents.map((snap) => Season.fromMap(snap.data));
    await for (var doc in ref.snapshots()) {
      yield doc.documents.map((snap) => Season.fromMap(snap.data));
    }
  }

  @override
  Future<bool> addUserToPlayer(String playerUid, PlayerUser player) async {
    var doc =
        await _wrapper.collection(PLAYERS_COLLECTION).document(playerUid).get();
    if (doc.exists) {
      // Yay!  We have a player.
      var playerInternal = PlayerUserInternal((b) => b
        ..added = true
        ..relationship = player.relationship);
      var data = <String, dynamic>{};
      data["${Player.USERS}.${player.userUid}"] = playerInternal.toMap();
      doc.reference.updateData(data);
      _analytics.logEvent(name: "addUserToPlayer");
      return true;
    }
    return false;
  }

  @override
  Future<String> createPlayer(Player player) async {
    var ref = _wrapper.collection(PLAYERS_COLLECTION);
    var doc = await ref.add(player.toMap(includeUsers: true));
    _analytics.logEvent(name: "createPlayer");
    return doc.documentID;
  }

  @override
  Future<void> deletePlayer(String playerUid) {
    _analytics.logEvent(name: "deletePlayer");
    return _wrapper
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .delete()
        .then((val) {});
  }

  /// Send an invite to a user for this season and team.
  @override
  Future<String> inviteUserToPlayer(
      {@required String playerUid,
      @required String playerName,
      @required String email,
      @required myUid}) async {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: playerUid)
        .getDocuments();
    if (snapshot.documents.isEmpty) {
      var invite = InviteToPlayer((b) => b
        ..playerUid = playerUid
        ..email = email
        ..playerName = playerName
        ..sentByUid = myUid);

      var doc = await ref.add(invite.toMap());
      return doc.documentID;
    }
    _analytics.logEvent(name: "inviteUserToPlayer");
    return snapshot.documents[0].documentID;
  }

  @override
  Future<String> inviteAdminToTeam(
      {@required String myUid,
      @required String teamUid,
      @required String teamName,
      @required String email}) async {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: teamUid)
        .getDocuments();
    if (snapshot.documents.isEmpty) {
      var invite = InviteAsAdmin((b) => b
        ..teamUid = teamUid
        ..email = email
        ..teamName = teamName
        ..sentByUid = myUid);

      var doc = await ref.add(invite.toMap());
      return doc.documentID;
    }
    _analytics.logEvent(name: "inviteAdminToTeam");
    return snapshot.documents[0].documentID;
  }

  @override
  Stream<Iterable<InviteToPlayer>> getInviteForPlayerStream(
      {String playerUid}) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: playerUid);
    var wrap = await query.getDocuments();
    yield wrap.documents.map((snap) => InviteToPlayer.fromMap(snap.data));
    await for (var wrap in query.snapshots()) {
      yield wrap.documents.map((snap) => InviteToPlayer.fromMap(snap.data));
    }
  }

  @override
  Future<void> removeUserFromPlayer(Player player, String userId) {
    var doc = _wrapper.collection(PLAYERS_COLLECTION).document(player.uid);
    _analytics.logEvent(name: "removeUserFromPlayer");
    return doc.updateData(<String, dynamic>{Player.USERS + userId: null});
  }

  // Season updates
  @override
  Future<void> updateFirestoreSeason(Season season, bool includePlayers) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection(SEASONS_COLLECTION);

    // Update the game.
    await ref
        .document(season.uid)
        .updateData(season.toMap(includePlayers: includePlayers));
    _analytics.logEvent(name: "updateFirestoreSeason");
  }

  Future<Season> addFirestoreSeason(
      Season season, DocumentReferenceWrapper pregenDoc) async {
    var ref = _wrapper.collection(SEASONS_COLLECTION);
    // Add the game.
    DocumentReferenceWrapper doc;
    if (pregenDoc != null) {
      await pregenDoc.setData(season.toMap(includePlayers: true));
    } else {
      doc = await ref.add(season.toMap(includePlayers: true));
    }
    _analytics.logEvent(name: "addFirestoreSeason");
    return season.rebuild((b) => b..uid = doc.documentID);
  }

  @override
  DocumentReferenceWrapper precreateUidSeason() {
    return _wrapper.collection(SEASONS_COLLECTION).document();
  }

  @override
  Future<void> removePlayerFromSeason(
      String seasonUid, String playerUid) async {
    var doc = _wrapper.collection(SEASONS_COLLECTION).document(seasonUid);
    var data = <String, dynamic>{};
    data["${Season.PLAYERS}.$playerUid"] = null;
    await doc.updateData(data);
    _analytics.logEvent(name: "removePlayerFromSeason");
  }

  @override
  Future<void> updateRoleInTeamForSeason(
      String seasonUid, SeasonPlayer player, RoleInTeam role) async {
    var data = <String, dynamic>{};

    data["${Season.PLAYERS}.${player.playerUid}.${SeasonPlayer.ROLE}"] =
        role.toString();
    _wrapper
        .collection(SEASONS_COLLECTION)
        .document(seasonUid)
        .updateData(data);
    _analytics.logEvent(name: "updateRoleInTeamForSeason");
  }

  @override
  Future<bool> playerExists(String uid) async {
    // Add ourselves to the player.
    var doc = await _wrapper.collection(PLAYERS_COLLECTION).document(uid).get();
    return doc.exists;
  }

  @override
  Stream<Player> getPlayerDetails(String uid) async* {
    final doc = await _wrapper.collection(PLAYERS_COLLECTION).document(uid);
    final initial = await doc.get();
    if (initial.exists) {
      yield Player.fromMap(initial.data);
    } else {
      yield null;
    }
    await for (var data in doc.snapshots()) {
      if (data.exists) {
        yield Player.fromMap(data.data);
      } else {
        yield null;
      }
    }
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
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: seasonUid)
        .where(InviteToTeam.TEAMUID, isEqualTo: teamUid)
        .getDocuments();
    _analytics.logEvent(name: "inviteUserToSeason");
    if (snapshot.documents.isNotEmpty) {
      var invite = InviteFactory.makeInviteFromJSON(
              snapshot.documents[0].documentID, snapshot.documents[0].data)
          as InviteToTeam;

      var newList = invite.playerName.toBuilder();
      newList.add(playername);
      var updatedInvite = InviteToTeam((b) => b
        ..email = invite.email
        ..teamUid = invite.teamUid
        ..seasonUid = invite.uid
        ..playerName = newList
        ..sentByUid = invite.sentByUid
        ..teamName = teamName
        ..seasonName = seasonName
        ..role = role);
      snapshot.documents[0].reference.updateData(updatedInvite.toMap());
      return snapshot.documents[0].documentID;
    } else {
      var invite = InviteToTeam((b) => b
        ..email = email
        ..teamUid = teamUid
        ..seasonUid = seasonUid
        ..playerName = ListBuilder([playername])
        ..sentByUid = userId
        ..teamName = teamName
        ..seasonName = seasonName
        ..role = role);

      var doc = await ref.add(invite.toMap());
      return doc.documentID;
    }
  }

  @override
  Stream<Iterable<InviteToTeam>> getInviteForSeasonStream(
      {@required String seasonUid, @required String teamUid}) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: seasonUid)
        .where(InviteToTeam.TEAMUID, isEqualTo: teamUid);

    var wrap = await query.getDocuments();
    yield wrap.documents.map((doc) => InviteToTeam.fromMap(doc.data));

    await for (var wrap in query.snapshots()) {
      yield wrap.documents.map((doc) => InviteToTeam.fromMap(doc.data));
    }
  }

  @override
  Stream<GameSnapshotEvent> getSeasonGames(Season season) {
    return getBasicGames(teamUid: season.teamUid, seasonUid: season.uid);
  }

  @override
  Stream<Season> getSingleSeason(String seasonUid) async* {
    var doc = _wrapper.collection(SEASONS_COLLECTION).document(seasonUid);
    var snap = await doc.get();
    if (snap.exists) {
      yield Season.fromMap(snap.data);
    } else {
      yield null;
    }
    await for (var snap in doc.snapshots()) {
      if (snap.exists) {
        yield Season.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<BuiltList<Season>> getSeasons() async* {
    var query = _wrapper
        .collection(SEASONS_COLLECTION)
        .where("${Season.USER}.${userData.uid}.$ADDED", isEqualTo: true);
    var snap = await query.getDocuments();
    yield BuiltList(snap.documents.map((d) => Season.fromMap(d.data)));

    await for (var snap in query.snapshots()) {
      yield BuiltList(snap.documents.map((d) => Season.fromMap(d.data)));
    }
  }

  @override
  Future<void> addPlayerToSeason(
      String seasonUid, SeasonPlayer seasonPlayer) async {
    var doc = _wrapper.collection(SEASONS_COLLECTION).document(seasonUid);
    var data = <String, dynamic>{};
    data["${Season.PLAYERS}.${seasonPlayer.playerUid}"] = seasonPlayer.toMap();
    doc.updateData(data);
    _analytics.logEvent(name: "addPlayerToSeason");
    return;
  }

  Future<Team> _loadTeamFromClub(
      DocumentSnapshotWrapper snap, Club club) async {
    return Team.fromMap(userData?.uid ?? "", snap.data);
  }

  // Loads the seasons for the team.  This is only used for
  // admin teams and club teams.
  Stream<BuiltList<Season>> getSeasonsForTeam(String teamUid) async* {
    // Find the seasons for the team.
    var query = _wrapper
        .collection(SEASONS_COLLECTION)
        .where(Season.TEAMUID, isEqualTo: teamUid)
        .where("${Season.USER}.${userData.uid}.$ADDED", isEqualTo: true);
    var snap = await query.getDocuments();
    yield BuiltList(snap.documents.map((d) => Season.fromMap(d.data)));
    await for (var snap in query.snapshots()) {
      yield BuiltList(snap.documents.map((d) => Season.fromMap(d.data)));
    }
  }

  // clubs!
  @override
  Stream<BuiltList<Team>> getClubTeams(Club club, bool isPublic) async* {
    var query = _wrapper
        .collection(TEAMS_COLLECTION)
        .where(Team.CLUBUID, isEqualTo: club.uid);
    if (isPublic) {
      query = query.where(Team.ISPUBLIC, isEqualTo: true);
    } else {
      // Only get teams we can see.
      query =
          query.where("${Team.USER}.${userData.uid}.$ADDED", isEqualTo: true);
    }
    var wrap = await query.getDocuments();
    var teams = <Team>[];
    for (var snap in wrap.documents) {
      var t = await _loadTeamFromClub(snap, club);
      teams.add(t);
    }

    yield BuiltList(teams);
    await for (var wrap in query.snapshots()) {
      var teams = <Team>[];
      for (var snap in wrap.documents) {
        var t = await _loadTeamFromClub(snap, club);
        teams.add(t);
      }
      yield BuiltList(teams);
    }
  }

  @override
  Future<void> addUserToClub(String clubUid, String newUserUid, bool admin) {
    _analytics.logEvent(name: "addUserToClub");
    return _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .updateData(<String, dynamic>{
      "${Club.MEMBERS}.$newUserUid": <String, dynamic>{
        ADDED: true,
        Club.ADMIN: admin
      }
    });
  }

  @override
  Future<String> inviteUserToClub(
      {String clubName, String clubUid, String email, bool admin}) async {
    var invite = InviteToClub((b) => b
      ..admin = admin
      ..clubUid = clubUid
      ..clubName = clubName
      ..email = email);
    var ref = await _wrapper.collection(INVITE_COLLECTION).add(invite.toMap());
    _analytics.logEvent(name: "inviteUserToClub");
    return ref.documentID;
  }

  @override
  Future<String> addClub(DocumentReferenceWrapper ref, Club club) async {
    var data = club.toMap(includeMembers: true);
    if (ref != null) {
      ref = await _wrapper.collection(CLUB_COLLECTION).add(data);
    } else {
      await ref.updateData(data);
    }
    _analytics.logEvent(name: "addClub");
    return ref.documentID;
  }

  @override
  Future<String> updateClub(Club club, {bool includeMembers = false}) async {
    var data = club.toMap(includeMembers: includeMembers);
    await _wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData(data);

    _analytics.logEvent(name: "updateClub");
    return club.uid;
  }

  @override
  Future<Uri> updateClubImage(Club club, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child("club_${club.uid}.img");
    var task = ref.putFile(imgFile);
    var snapshot = (await task.future);
    var photoUrl = snapshot.downloadUrl.toString();
    await _wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData({PHOTOURL: photoUrl});

    _analytics.logEvent(name: "updateClubImage");
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteClubMember(Club club, String memberUid) {
    _analytics.logEvent(name: "deleteClubMember");
    return _wrapper.collection(CLUB_COLLECTION).document(club.uid).updateData(
        <String, dynamic>{"${Club.MEMBERS}.$memberUid.$ADDED": false});
  }

  @override
  Stream<Club> getClubData({String clubUid}) async* {
    print("Loading Club $clubUid");
    var ref = _wrapper.collection(CLUB_COLLECTION).document(clubUid);
    var snap = await ref.get();
    if (snap.exists) {
      yield Club.fromMap(userData?.uid, snap.data);
    } else {
      yield null;
    }
    await for (var wrap in ref.snapshots()) {
      if (wrap.exists) {
        yield Club.fromMap(userData?.uid, wrap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<BuiltList<Coach>> getClubCoaches(String clubUid) async* {
    print("Getting coaches");
    var query = _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .collection(COACH_COLLECTION);
    var wrap = await query.getDocuments();

    print("Got docs");
    var coaches = ListBuilder<Coach>();
    for (var snap in wrap.documents) {
      coaches.add(Coach.fromMap(snap.data));
    }
    yield coaches.build();

    await for (var wrap in query.snapshots()) {
      var coaches = ListBuilder<Coach>();
      for (var snap in wrap.documents) {
        coaches.add(Coach.fromMap(snap.data));
      }
      yield coaches.build();
    }
  }

  @override
  Future<Coach> addClubCoach(Coach coach, Uint8List imageData) async {
    var imageRef =
        _wrapper.storageRef().child("coach_${coach.clubUid}_${coach.uid}.img");
    if (imageData != null) {
      var task = imageRef.putFile(imageData);
      await task.future;
      var downloadUrl = await imageRef.getDownloadURL();
      coach = coach.rebuild((b) => b..photoUrl = downloadUrl);
    }

    try {
      var ref = _wrapper
          .collection(CLUB_COLLECTION)
          .document(coach.clubUid)
          .collection(COACH_COLLECTION)
          .document();
      coach = coach.rebuild((b) => b..uid = ref.documentID);
      await ref.setData(coach.toMap());
    } on Exception catch (_) {
      // Delete the image if the create failed.
      if (imageData != null) {
        imageRef.delete();
      }
      rethrow;
    }
    return coach;
  }

  @override
  Future<Coach> updateClubCoach(Coach coach, Uint8List imageData) async {
    if (imageData != null) {
      var imageRef = _wrapper
          .storageRef()
          .child("coach_${coach.clubUid}_${coach.uid}.img");
      var task = imageRef.putFile(imageData);
      await task.future;
      String downloadUrl = await imageRef.getDownloadURL();
      coach = coach.rebuild((b) => b..photoUrl = downloadUrl);
    }
    var ref = _wrapper
        .collection(CLUB_COLLECTION)
        .document(coach.clubUid)
        .collection(COACH_COLLECTION)
        .document(coach.uid);
    await ref.updateData(coach.toMap());
    return coach;
  }

  @override
  Future<void> deleteClubCoach(Coach coach) async {
    var ref = _wrapper
        .collection(CLUB_COLLECTION)
        .document(coach.clubUid)
        .collection(COACH_COLLECTION)
        .document(coach.uid);
    await ref.delete();
  }

  @override
  Stream<Coach> getSingleClubCoach(String clubUid, String coachUid) async* {
    var ref = _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .collection(COACH_COLLECTION)
        .document(coachUid);
    var snap = await ref.get();
    if (snap.exists) {
      yield Coach.fromMap(snap.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield Coach.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<BuiltList<NewsItem>> getClubNews(String clubUid) async* {
    print("Getting newses");
    var query = _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .collection(NEWS_COLLECTION);
    var wrap = await query.getDocuments();

    print("Got docs");
    var newses = ListBuilder<NewsItem>();
    for (var snap in wrap.documents) {
      newses.add(NewsItem.fromMap(snap.data));
    }
    yield newses.build();

    await for (var wrap in query.snapshots()) {
      var newses = ListBuilder<NewsItem>();
      for (var snap in wrap.documents) {
        newses.add(NewsItem.fromMap(snap.data));
      }
      yield newses.build();
    }
  }

  @override
  Future<NewsItem> addClubNews(NewsItem news) async {
      var ref = _wrapper
          .collection(CLUB_COLLECTION)
          .document(news.clubUid)
          .collection(NEWS_COLLECTION)
          .document();
      news = news.rebuild((b) => b..uid = ref.documentID);
      await ref.setData(news.toMap());
    return news;
  }

  @override
  Future<NewsItem> updateClubNews(NewsItem news) async {
    var ref = _wrapper
        .collection(CLUB_COLLECTION)
        .document(news.clubUid)
        .collection(NEWS_COLLECTION)
        .document(news.uid);
    await ref.updateData(news.toMap());
    return news;
  }

  @override
  Future<void> deleteClubNews(NewsItem news) async {
    var ref = _wrapper
        .collection(CLUB_COLLECTION)
        .document(news.clubUid)
        .collection(NEWS_COLLECTION)
        .document(news.uid);
    await ref.delete();
  }

  @override
  Stream<NewsItem> getSingleClubNews(String clubUid, String newsUid) async* {
    var ref = _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .collection(NEWS_COLLECTION)
        .document(newsUid);
    var snap = await ref.get();
    if (snap.exists) {
      yield NewsItem.fromMap(snap.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield NewsItem.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }


  // leagues!
  @override
  Stream<BuiltList<LeagueOrTournamentTeam>> getLeagueDivisionTeams(
      String leagueDivisonUid) async* {
    var query = _wrapper.collection(LEAGUE_TEAM_COLLECTION).where(
        LeagueOrTournamentTeam.LEAGUEORTOURNMENTDIVISONUID,
        isEqualTo: leagueDivisonUid);
    // Snapshot and the main query.
    var wrap = await query.getDocuments();
    // Quick fix.
    var divison = await _wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(leagueDivisonUid)
        .get();
    for (var doc in wrap.documents) {
      if (!doc.data.containsKey('divisonUid')) {
        doc.reference.updateData({'divisonUid': leagueDivisonUid});
      }
      if (!doc.data.containsKey('seasonUid') || doc.data['seasonUid'] == null) {
        doc.reference.updateData({'seasonUid': divison.data['seasonUid']});
      }
      if (!doc.data.containsKey('leagueUid')) {
        doc.reference.updateData({'leagueUid': divison.data['leagueUid']});
      }
    }
    yield BuiltList(wrap.documents
        .map((snap) => LeagueOrTournamentTeam.fromMap(snap.data)));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield BuiltList(wrap.documents
          .map((snap) => LeagueOrTournamentTeam.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<GameSharedData>> getLeagueGamesForDivison(
      String leagueDivisonUid) async* {
    var query = _wrapper
        .collection(GAMES_SHARED_COLLECTION)
        .where(GameSharedData.LEAGUEDIVISIONUID, isEqualTo: leagueDivisonUid);

    // Snapshot and the main query.
    var wrap = await query.getDocuments();
    yield BuiltList(
        wrap.documents.map((snap) => GameSharedData.fromMap(snap.data)));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield BuiltList(
          wrap.documents.map((snap) => GameSharedData.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<GameSharedData>> getLeagueGamesForTeam(
      String leagueTeamUid) async* {
    var queryHome = _wrapper.collection(GAMES_SHARED_COLLECTION).where(
        "${GameSharedData.OFFICIALRESULT}.${GameOfficialResults.HOMETEAMUID}",
        isEqualTo: leagueTeamUid);
    var queryAway = _wrapper.collection(GAMES_SHARED_COLLECTION).where(
        "${GameSharedData.OFFICIALRESULT}.${GameOfficialResults.AWAYTEAMUID}",
        isEqualTo: leagueTeamUid);

    // Snapshot and the main query.
    var games = <String, GameSharedData>{};
    var wrapHome = await queryHome.getDocuments();
    for (var wrap in wrapHome.documents) {
      games[wrap.documentID] = GameSharedData.fromMap(wrap.data);
    }
    var wrapAway = await queryAway.getDocuments();
    for (var wrap in wrapAway.documents) {
         games[wrap.documentID] = GameSharedData.fromMap(wrap.data);
    }
    yield BuiltList(games.values);

    var str = StreamGroup<QuerySnapshotWrapper>();
    str.add(queryHome.snapshots());
    str.add(queryAway.snapshots());

    await for (var snap in str.stream) {
      for (var change in snap.documentChanges) {
        if (change.type == DocumentChangeTypeWrapper.removed) {
          games.remove(change.document.documentID);
        } else {
          games[change.document.documentID] =
              GameSharedData.fromMap(change.document.data);
        }
      }

      yield BuiltList(games.values);
    }
    str.close();
  }

  @override
  Future<void> addUserToLeague(String leagueUid, bool admin) {
    _analytics.logEvent(name: "addUserToLeague");
    return _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      "${LeagueOrTournament.MEMBERS}.${userData.uid}": <String, dynamic>{
        ADDED: true,
        LeagueOrTournament.ADMIN: admin
      }
    });
  }

  @override
  Future<void> addUserToLeagueSeason(String leagueUid, bool admin) {
    _analytics.logEvent(name: "addUserToLeagueSeason");
    return _wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      "${LeagueOrTournamentSeason.MEMBERS}.${userData.uid}":
          AddedOrAdmin((b) => b
            ..added = true
            ..admin = admin).toMap()
    });
  }

  @override
  Future<void> addUserToLeagueDivison(String leagueUid, bool admin) {
    _analytics.logEvent(name: "addUserToLeagueDivison");
    return _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      "${LeagueOrTournamentDivison.MEMBERS}.${userData.uid}":
          AddedOrAdmin((b) => b
            ..added = true
            ..admin = admin)
    });
  }

  @override
  Future<String> inviteUserToLeague(InviteToLeagueAsAdmin invite) async {
    var ref = await _wrapper.collection(INVITE_COLLECTION).add(invite.toMap());
    _analytics.logEvent(name: "inviteUserToLeague");
    return ref.documentID;
  }

  Future<String> inviteUserToLeagueTeam(
      {String leagueSeasonUid,
      LeagueOrTournamentTeam leagueTeam,
      String email}) async {
    var season = await getLeagueSeasonData(leagueSeasonUid).single;
    var str = getLeagueData(leagueUid: season.leagueOrTournmentUid);
    var leagueOrTournament = await str.single;

    var teamInvite = InviteToLeagueTeam((b) => b
      ..email = email
      ..leagueName = leagueOrTournament.name
      ..sentByUid = userData.uid
      ..leagueDivisonUid = leagueTeam.leagueOrTournamentDivisonUid
      ..leagueTeamName = leagueTeam.name
      ..leagueUid = leagueOrTournament.uid
      ..leagueSeasonName = season.name
      ..leagueTeamUid = leagueTeam.uid);
    // Write it out to firestore.  Yay.
    var doc =
        await _wrapper.collection(INVITE_COLLECTION).add(teamInvite.toMap());
    _analytics.logEvent(name: "inviteUserToLeagueTeam");
    return doc.documentID;
  }

  @override
  Stream<BuiltList<InviteToLeagueTeam>> getLeagueOrTournmentTeamInvitesStream(
      String leagueTeamUid) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var query = ref
        .where(Invite.TYPE, isEqualTo: InviteType.LeagueTeam.toString())
        .where(InviteToLeagueTeam.LEAGUETEAMUID, isEqualTo: leagueTeamUid);
    var wrap = await query.getDocuments();
    yield BuiltList(
        wrap.documents.map((snap) => InviteToLeagueTeam.fromMap(snap.data)));

    await for (var wrap in query.snapshots()) {
      yield BuiltList(
          wrap.documents.map((snap) => InviteToLeagueTeam.fromMap(snap.data)));
    }
  }

  @override
  Future<String> updateLeague(LeagueOrTournament league,
      {bool includeMembers = false}) async {
    var data = league.toMap(includeMembers: includeMembers);
    if (league.uid == null) {
      var ref = await _wrapper.collection(LEAGUE_COLLECTON).add(data);
      return ref.documentID;
    } else {
      await _wrapper
          .collection(LEAGUE_COLLECTON)
          .document(league.uid)
          .updateData(data);
    }
    _analytics.logEvent(name: "updateLeague");

    return league.uid;
  }

  @override
  Future<Uri> updateLeagueImage(
      LeagueOrTournament league, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child("league_${league.uid}.jpg");
    var task = ref.putFile(imgFile);
    var snapshot = (await task.future);
    var photoUrl = snapshot.downloadUrl.toString();
    // Update the reference in the class.
    await _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData({PHOTOURL: photoUrl});
    _analytics.logEvent(name: "updateLeagueImage");
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteLeagueMember(LeagueOrTournament league, String memberUid) {
    _analytics.logEvent(name: "deleteLeagueMember");
    return _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData(<String, dynamic>{
      "${LeagueOrTournament.MEMBERS}.$memberUid.$ADDED": false
    });
  }

  @override
  Stream<LeagueOrTournament> getLeagueData({String leagueUid}) async* {
    var ref = _wrapper.collection(LEAGUE_COLLECTON).document(leagueUid);
    var data = await ref.get();
    if (data.exists) {
      yield LeagueOrTournament.fromMap(userData.uid, data.data);
    } else {
      yield null;
    }
    await for (var data in ref.snapshots()) {
      if (data.exists) {
        yield LeagueOrTournament.fromMap(userData.uid, data.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<BuiltList<LeagueOrTournamentSeason>> getLeagueSeasons(
      {String leagueUid}) async* {
    var query = _wrapper.collection(LEAGUE_SEASON_COLLECTION).where(
        LeagueOrTournamentSeason.LEAGUEORTOURNMENTUID,
        isEqualTo: leagueUid);
    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents
        .map((snap) => LeagueOrTournamentSeason.fromMap(snap.data)));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield BuiltList(wrap.documents
          .map((snap) => LeagueOrTournamentSeason.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<LeagueOrTournamentDivison>> getLeagueDivisonsForSeason(
      {String leagueSeasonUid, String memberUid}) async* {
    var query = _wrapper.collection(LEAGUE_DIVISION_COLLECTION).where(
        LeagueOrTournamentDivison.LEAGUEORTOURNMENTSEASONUID,
        isEqualTo: leagueSeasonUid);
    print("Divisons $leagueSeasonUid");
    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents
        .map((snap) => LeagueOrTournamentDivison.fromMap(snap.data)));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield BuiltList(wrap.documents
          .map((snap) => LeagueOrTournamentDivison.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<LeagueOrTournamentTeam>> getLeagueTeamsForTeamSeason(
      String teamSeasonUid) async* {
    var query = _wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .where(LeagueOrTournamentTeam.TEAMSEASONUID, isEqualTo: teamSeasonUid);
    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents
        .map((snap) => LeagueOrTournamentTeam.fromMap(snap.data)));
    await for (var wrap in query.snapshots()) {
      yield BuiltList(wrap.documents
          .map((snap) => LeagueOrTournamentTeam.fromMap(snap.data)));
    }
  }

  @override
  Stream<LeagueOrTournamentDivison> getLeagueDivisionData(
      {String leagueDivisionUid}) async* {
    var doc = _wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(leagueDivisionUid);
    var wrap = await doc.get();
    if (wrap.exists) {
      yield LeagueOrTournamentDivison.fromMap(wrap.data);
    } else {
      yield null;
    }
    await for (var wrap in doc.snapshots()) {
      if (wrap.exists) {
        yield LeagueOrTournamentDivison.fromMap(wrap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<LeagueOrTournamentSeason> getLeagueSeasonData(
      String leagueSeasonUid) async* {
    var ref =
        _wrapper.collection(LEAGUE_SEASON_COLLECTION).document(leagueSeasonUid);

    var doc = await ref.get();
    if (doc.exists) {
      yield LeagueOrTournamentSeason.fromMap(doc.data);
    } else {
      yield null;
    }
    await for (var doc in ref.snapshots()) {
      yield LeagueOrTournamentSeason.fromMap(doc.data);
    }
  }

  @override
  Future<String> updateLeagueDivison(LeagueOrTournamentDivison division) async {
    if (division.uid == null) {
      var doc = await _wrapper
          .collection(LEAGUE_DIVISION_COLLECTION)
          .add(division.toMap());
      return doc.documentID;
    }
    await _wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(division.uid)
        .updateData(division.toMap());
    _analytics.logEvent(name: "updateLeagueDivison");
    return division.uid;
  }

  @override
  Future<String> updateLeagueSeason(LeagueOrTournamentSeason season) async {
    if (season.uid == null) {
      var doc = await _wrapper
          .collection(LEAGUE_SEASON_COLLECTION)
          .add(season.toMap());
      return doc.documentID;
    }
    await _wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(season.uid)
        .updateData(season.toMap());
    _analytics.logEvent(name: "updateLeagueSeason");
    return season.uid;
  }

  @override
  Future<String> updateLeagueTeam(LeagueOrTournamentTeam team) async {
    if (team.uid == null) {
      var doc =
          await _wrapper.collection(LEAGUE_TEAM_COLLECTION).add(team.toMap());
      return doc.documentID;
    }
    await _wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(team.uid)
        .updateData(team.toMap());
    return team.uid;
  }

  @override
  Future<void> updateLeagueTeamRecord(
      LeagueOrTournamentTeam team, String divison, WinRecord record) async {
    var doc = _wrapper.collection(LEAGUE_TEAM_COLLECTION).document(team.uid);
    var data = <String, dynamic>{};
    data["${LeagueOrTournamentTeam.WINRECORD}.$divison"] = record.toMap();
    doc.updateData(data);
    _analytics.logEvent(name: "updateLeagueTeam");
  }

  @override
  Stream<LeagueOrTournamentTeam> getLeagueTeamData(String teamUid) async* {
    var ref = _wrapper.collection(LEAGUE_TEAM_COLLECTION).document(teamUid);
    var snap = await ref.get();
    yield LeagueOrTournamentTeam.fromMap(snap.data);
    await for (var snap in ref.snapshots()) {
      yield LeagueOrTournamentTeam.fromMap(snap.data);
    }
  }

  Future<bool> connectLeagueTeamToSeason(
      String leagueTeamUid, Season season) async {
    var doc = await _wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(leagueTeamUid)
        .get();
    // If it is already connected to a season, abort!
    if (!doc.exists) {
      return false;
    }
    var team = LeagueOrTournamentTeam.fromMap(doc.data);
    if (team.teamSeasonUid != null) {
      return false;
    }
    // Connect it and save it.
    var data = <String, String>{};
    data[LeagueOrTournamentTeam.TEAMSEASONUID] = season.uid;
    data[LeagueOrTournamentTeam.TEAMUID] = season.teamUid;
    await _wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(leagueTeamUid)
        .updateData(data);
    return true;
  }

  // Initial data
  @override
  Stream<BuiltList<Club>> getMainClubs() async* {
    var query = _wrapper
        .collection(CLUB_COLLECTION)
        .where("${Club.MEMBERS}.${userData.uid}.$ADDED", isEqualTo: true);
    print("Get main clubs ${Club.MEMBERS}.${userData.uid}.$ADDED");
    var wrap = await query.getDocuments();
    yield BuiltList(
        wrap.documents.map((snap) => Club.fromMap(userData.uid, snap.data)));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield BuiltList(
          wrap.documents.map((snap) => Club.fromMap(userData.uid, snap.data)));
    }
  }

  @override
  Stream<BuiltList<LeagueOrTournament>> getMainLeagueOrTournaments() async* {
    var query = _wrapper.collection(LEAGUE_COLLECTON).where(
        "${LeagueOrTournament.MEMBERS}.${userData.uid}.$ADDED",
        isEqualTo: true);
    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents
        .map((snap) => LeagueOrTournament.fromMap(userData.uid, snap.data)));
    await for (QuerySnapshotWrapper wrap in query.snapshots()) {
      yield BuiltList(wrap.documents
          .map((snap) => LeagueOrTournament.fromMap(userData.uid, snap.data)));
    }
  }

  @override
  Stream<BuiltList<Player>> getPlayers() async* {
    var query = _wrapper
        .collection(PLAYERS_COLLECTION)
        .where("${Player.USERS}.${userData.uid}.$ADDED", isEqualTo: true);
    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents.map((snap) => Player.fromMap(snap.data)));
    await for (var wrap in query.snapshots()) {
      yield BuiltList(wrap.documents.map((snap) => Player.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<MessageRecipient>> getMessages(bool unread) async* {
    QueryWrapper query;
    if (unread) {
      query = _wrapper
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.USERID, isEqualTo: userData.uid)
          .where(MessageRecipient.STATE,
              isEqualTo: MessageReadState.Unread.toString());
    } else {
      query = _wrapper
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.USERID, isEqualTo: userData.uid)
          .orderBy(MessageRecipient.SENTAT)
          .limit(_maxMessages);
    }
    var wrap = await query.getDocuments();
    yield BuiltList(
        wrap.documents.map((snap) => MessageRecipient.fromMap(snap.data)));
    await for (var wrap in query.snapshots()) {
      yield BuiltList(
          wrap.documents.map((snap) => MessageRecipient.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<Invite>> getInvites() async* {
    var query = _wrapper
        .collection(INVITE_COLLECTION)
        .where(Invite.EMAIL, isEqualTo: normalizeEmail(userData.email));

    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents.map((snap) =>
        InviteFactory.makeInviteFromJSON(snap.documentID, snap.data)));
    await for (var wrap in query.snapshots()) {
      yield BuiltList(wrap.documents.map((snap) =>
          InviteFactory.makeInviteFromJSON(snap.documentID, snap.data)));
    }
  }

  @override
  Stream<Invite> getSingleInvite(String inviteUid) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION).document(inviteUid);

    var doc = await ref.get();
    if (doc.exists) {
      yield InviteFactory.makeInviteFromJSON(doc.documentID, doc.data);
    } else {
      yield null;
    }
    await for (DocumentSnapshotWrapper wrap in ref.snapshots()) {
      if (wrap.exists) {
        yield InviteFactory.makeInviteFromJSON(wrap.documentID, wrap.data);
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<BuiltList<Team>> getTeamAdmins() async* {
    var teamCollection = _wrapper
        .collection(TEAMS_COLLECTION)
        .where("${Team.ADMINS}.${userData.uid}", isEqualTo: true);

    var wrap = await teamCollection.getDocuments();
    yield BuiltList(
        wrap.documents.map((snap) => Team.fromMap(userData.uid, snap.data)));
    await for (var wrap in teamCollection.snapshots()) {
      yield BuiltList(
          wrap.documents.map((snap) => Team.fromMap(userData.uid, snap.data)));
    }
  }

  @override
  Stream<Iterable<Team>> getTeams() async* {
    var teamCollection = _wrapper
        .collection(TEAMS_COLLECTION)
        .where("${Team.USER}.${userData.uid}.$ADDED", isEqualTo: true);

    var wrap = await teamCollection.getDocuments();
    yield wrap.documents.map((snap) => Team.fromMap(userData.uid, snap.data));
    await for (var wrap in teamCollection.snapshots()) {
      yield wrap.documents.map((snap) => Team.fromMap(userData.uid, snap.data));
    }
  }

  @override
  Stream<BuiltList<InviteToClub>> getInviteToClubStream(String clubUid) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snapshot = ref
        .where(InviteToClub.CLUBUID, isEqualTo: clubUid)
        .where(Invite.TYPE, isEqualTo: InviteType.Club.toString());

    var wrap = await snapshot.getDocuments();
    yield BuiltList(
        wrap.documents.map((doc) => InviteToClub.fromMap(doc.data)));
    await for (var wrap in snapshot.snapshots()) {
      yield BuiltList(
          wrap.documents.map((doc) => InviteToClub.fromMap(doc.data)));
    }
  }

  // Game Events
  @override
  Future<String> getGameEventId({GameEvent event}) async {
    var ref = _wrapper.collection(GAME_EVENT_COLLECTION).document();
    _analytics.logEvent(name: "AddGameEvent", parameters: {
      "type": event.type.toString(),
      "points": event.points.toString()
    });
    return ref.documentID;
  }

  @override
  Future<void> setGameEvent({GameEvent event}) async {
    if (event.uid == null || event.uid.isEmpty) {
      throw ArgumentError("uid must not be empty");
    }
    print("Saving game event $event");
    _analytics.logEvent(name: "UpdateGameEvent");
    return _wrapper
        .collection(GAME_EVENT_COLLECTION)
        .document(event.uid)
        .setData(event.toMap());
  }

  @override
  Future<void> deleteGameEvent({String gameEventUid}) {
    print("Deleting event $gameEventUid");
    _analytics.logEvent(name: "DeleteGameEvent");
    return _wrapper
        .collection(GAME_EVENT_COLLECTION)
        .document(gameEventUid)
        .delete();
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    var q = _wrapper
        .collection(GAME_EVENT_COLLECTION)
        .where("gameUid", isEqualTo: gameUid)
        .orderBy("timestamp");
    var snap = await q.getDocuments();
    yield BuiltList.of(snap.documents.map((snap) =>
        GameEvent.fromMap(_addUid(snap.documentID, snap.data))
            .rebuild((b) => b..uid = snap.documentID)));
    await for (snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map((snap) =>
          GameEvent.fromMap(_addUid(snap.documentID, snap.data))
              .rebuild((b) => b..uid = snap.documentID)));
    }
  }

  Map<String, dynamic> _addUid(String uid, Map<String, dynamic> data) {
    data.putIfAbsent("uid", () => uid);
    return data;
  }

  @override
  Future<String> addMedia({MediaInfo media}) async {
    var ref = _wrapper.collection(MEDIA_COLLECTION).document();
    var p = media.rebuild((b) => b..uid = ref.documentID);
    var data = p.toMap();
    data["uploadTime"] = _wrapper.fieldValueServerTimestamp;
    await ref.setData(data);
    _analytics.logEvent(name: "AddMedia");
    return ref.documentID;
  }

  Future<void> deleteMedia({String mediaInfoUid}) {
    _analytics.logEvent(name: "DeleteMedia");
    return _wrapper
        .collection(MEDIA_COLLECTION)
        .document(mediaInfoUid)
        .delete();
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForGame({String gameUid}) async* {
    var q = _wrapper
        .collection(MEDIA_COLLECTION)
        .where("gameUid", isEqualTo: gameUid);
    var snap = await q.getDocuments();
    yield BuiltList.of(snap.documents
        .map((snap) => MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    await for (var snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map(
          (snap) => MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Stream<MediaInfo> getMediaInfo({String mediaInfoUid}) async* {
    var ref = _wrapper.collection(MEDIA_COLLECTION).document(mediaInfoUid);
    var doc = await ref.get();
    if (doc.exists) {
      yield MediaInfo.fromMap(doc.data);
    } else {
      yield null;
    }
    await for (var snap in ref.snapshots()) {
      if (snap.exists) {
        yield MediaInfo.fromMap(snap.data);
      } else {
        yield null;
      }
    }
  }

  Future<void> updateMediaInfoThumbnail(
      {MediaInfo mediaInfo, String thumbnailUrl}) async {
    var ref = _wrapper.collection(MEDIA_COLLECTION).document(mediaInfo.uid);
    await ref.updateData({thumbnailUrl: thumbnailUrl});
  }

  @override
  Future<void> addGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    _analytics.logEvent(name: "AddGamePlayer");
    return ref.updateData(
        {"${(opponent ? "opponents." : "players.")}$playerUid.player": true});
  }

  @override
  Future<void> deleteGamePlayer(
      {String gameUid, String playerUid, bool opponent}) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    _analytics.logEvent(name: "DeleteGamePlayer");
    return ref.updateData({
      (opponent ? "opponents." : "players.") + playerUid:
          _wrapper.fieldValueDelete
    });
  }

  @override
  Future<void> updateGamePlayerData(
      {String gameUid,
      String playerUid,
      GamePlayerSummary summary,
      bool opponent}) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    _analytics.logEvent(name: "UpdateGamePlayer");
    return ref.updateData({"players.$playerUid": summary.toMap()});
  }
}
