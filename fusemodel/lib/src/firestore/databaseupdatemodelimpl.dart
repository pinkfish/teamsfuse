import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:built_collection/built_collection.dart';
import 'package:clock/clock.dart';
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
    _authenticationBloc?.stream?.listen((state) {
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
    _analytics.logEvent(name: 'updateGame');
    if (game.uid == null || game.uid == '') {
      var ref = _wrapper.collection(GAMES_COLLECTION).document();
      var refShared = _wrapper.collection(GAMES_SHARED_COLLECTION).document();
      var gameBuilder = game.toBuilder();
      await _wrapper.runTransaction((tx) async {
        // Add the shared stuff, then the game.
        if (game.sharedData.officialResult.homeTeamLeagueUid == null) {
          gameBuilder.sharedData.officialResult.homeTeamLeagueUid =
              game.teamUid;
        }
        gameBuilder.sharedData.uid = refShared.documentID;
        await tx.set(refShared, game.sharedData.toMap());
        gameBuilder.sharedDataUid = refShared.documentID;
        gameBuilder.uid = ref.documentID;
        print(
            'Writing game ${gameBuilder.sharedDataUid} ${gameBuilder.teamUid}');
        // Add the game.
        await tx.set(ref, gameBuilder.build().toMap());
        return gameBuilder.build().toMap();
      });
      return gameBuilder.build();
    } else {
      if (sharedData) {
        if (game.sharedDataUid.isEmpty) {
          var sharedDoc = await refShared.add(game.sharedData.toMap());
          game = game.rebuild((b) => b..sharedDataUid = sharedDoc.documentID);
        } else {
          await refShared
              .document(game.sharedDataUid)
              .updateData(game.sharedData.toMap());
        }
      }
      // Update the game.
      await ref.document(game.uid).updateData(game.toMap());
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
      await tx.set(mainShared, s.toMap());
      gameBuilder.sharedDataUid = mainShared.documentID;
      // Add the game.
      await tx.set(mainRef, gameBuilder.build().toMap());
      for (var i = 0; i < dates.length; i++) {
        var time = dates.elementAt(i);
        if (game.sharedData.time.microsecondsSinceEpoch !=
            time.microsecondsSinceEpoch) {
          await tx.set(refShared[i], game.sharedData.toMap());
          gameBuilder.sharedDataUid = refShared[i].documentID;
          // Add the game.
          await tx.set(ref[i], gameBuilder.build().toMap());
          _analytics.logEvent(name: 'addTrainingEvent');
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
    _analytics.logEvent(name: 'updateSharedGame');
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
    _analytics.logEvent(name: 'deleteGame');
    return ref.delete();
  }

  @override
  Future<void> updateFirestoreGameAttendence(
      Game game, String playerUid, Attendance attend) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(game.uid);

    var data = <String, dynamic>{};
    data['${Game.ATTENDANCE}.$playerUid'] = attend.toString();
    _analytics.logEvent(name: 'updateGameAttendance');

    return ref.updateData(data).then((a) => print('Done stuff'));
  }

  @override
  Future<void> updateFirestoreGameResult(
      String gameUid, GameResultDetails result) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);

    var data = <String, dynamic>{};
    data[Game.RESULT] = result.toMap();
    _analytics.logEvent(name: 'updateGameResult');
    return ref.updateData(data);
  }

  @override
  Future<void> updateFirestoreOfficalGameResult(
      String sharedGameUid, GameOfficialResults result) {
    var ref =
        _wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);

    var data = <String, dynamic>{};
    data[GameSharedData.OFFICIALRESULT] = result.toMap();
    _analytics.logEvent(name: 'updateOfficalGameResult');

    return ref.updateData(data);
  }

  // Invite firestore updates
  @override
  Future<void> firestoreInviteDelete(String inviteUid) {
    _analytics.logEvent(name: 'inviteDelete');
    return _wrapper.collection(INVITE_COLLECTION).document(inviteUid).delete();
  }

  // Message Recipients
  @override
  Future<void> updateMessageRecipientState(
      MessageRecipient rec, MessageReadState state) {
    var doc =
        _wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document(rec.uid);
    _analytics.logEvent(name: 'updateMessageRecipientState');

    return doc.updateData({MessageRecipient.stateId: state.toString()});
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
      ..eventTimeInternal =
          TZDateTime.from(clock.now(), local).microsecondsSinceEpoch
      ..uid = ref.documentID);
    return ref.setData(log.toMap()).then((v) {
      return ref.documentID;
    }).catchError((e) {
      print('Got error $e');
      return null;
    });
  }

  @override
  Future<Message> addMessage(Message mess, String body) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection('Messages');
    _analytics.logEvent(name: 'updateMessage');
    var newDoc = ref.document();
    mess = mess.rebuild((b) => b
      ..timeSent = Timestamp.now().toUtc()
      ..fromUid = currentUser.uid
      ..uid = newDoc.documentID);
    print('utc...?');
    var bodyRef = _wrapper
        .collection(MESSAGES_COLLECTION)
        .document(newDoc.documentID)
        .collection(MESSAGES_COLLECTION)
        .document(newDoc.documentID);
    await _wrapper.runTransaction((t) async {
      // Add the message.
      var data = mess.toMap();
      data[Message.timeSentId] = _wrapper.fieldValueServerTimestamp;
      await t.set(newDoc, data);

      // Add the body.
      var messageData = <String, dynamic>{};
      messageData[Message.bodyId] = body;
      await t.set(bodyRef, messageData);

      // Add in the recipients collection.
      var recipients = mess.recipients.toBuilder();
      var sentTo = <String>{};
      for (var str in mess.recipients.keys) {
        if (!sentTo.contains(mess.recipients[str].userId)) {
          var docRef =
              _wrapper.collection(MESSAGE_RECIPIENTS_COLLECTION).document();
          var rec = mess.recipients[str].rebuild((b) => b
            ..messageId = mess.uid
            ..sentAt = mess.timeSent
            ..fromUid = currentUser.uid
            ..uid = docRef.documentID);
          var recipientData = mess.recipients[str].toMap();
          recipientData[MessageRecipient.sentAtId] =
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
    print('Message body $messageUid');
    if (snap.exists) {
      print(snap.data);
      yield snap.data[Message.bodyId] as String;
    } else {
      yield null;
    }
    await for (DocumentSnapshotWrapper snapper in ref.snapshots()) {
      if (snapper.exists) {
        yield snapper.data[Message.bodyId];
      } else {
        yield null;
      }
    }
  }

  @override
  Stream<Message> getMessage(String messageId) async* {
    var ref = _wrapper.collection(MESSAGES_COLLECTION).document(messageId);
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
    _analytics.logEvent(name: 'updateOpponent');
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
    _analytics.logEvent(name: 'addOpponent');

    return opponent;
  }

  @override
  Future<void> deleteFirestoreOpponent(Opponent opponent) async {
    // Add or update this record into the database.
    _analytics.logEvent(name: 'deleteOpponent');
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
    _analytics.logEvent(name: 'updateTeam');
    return team.uid;
  }

  @override
  Future<String> addFirestoreTeam(Team team, DocumentReferenceWrapper pregen,
      Season season, Uint8List imageFile) async {
    // Add or update this record into the database.
    pregen ??= _wrapper.collection(TEAMS_COLLECTION).document();
    var pregenSeason = _wrapper.collection(SEASONS_COLLECTION).document();
    var admins = team.adminsData.toBuilder();

    // Make sure we are admin in the team.
    admins[currentUser.uid] = BuiltMap.of({
      'added': true,
      'admin': true,
    });
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
      await updateTeamImage(pregen.documentID, imageFile);
    }
    _analytics.logEvent(name: 'addTeam');

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
    var ref = _wrapper.storageRef().child('team/team_$teamUid.img');
    var task = ref.putFile(imgFile);
    var snapshot = await task.future;
    var photoUrl = snapshot.downloadUrl;
    await _wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .updateData({Team.photoUrlField: photoUrl.toString()});
    _analytics.logEvent(name: 'updateTeamImage');
    return photoUrl;
  }

  @override
  Future<void> deleteAdmin(Team team, String uid) {
    var ref = _wrapper.collection(TEAMS_COLLECTION).document(team.uid);
    _analytics.logEvent(name: 'deleteAdmin');
    return ref.updateData(<String, dynamic>{'${Team.adminsField}.$uid': false});
  }

  @override
  Future<String> addAdmin(String teamUid, String uid) async {
    var ref = _wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    await ref.updateData(<String, dynamic>{
      '${Team.adminsField}.$uid.added': true,
      '${Team.adminsField}.$uid.admin': true,
    });
    _analytics.logEvent(name: 'addAdmin');
    return ref.documentID;
  }

  @override
  Stream<Iterable<InviteAsAdmin>> getInviteForTeamStream(Team team) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var snap = ref
        .where(Invite.typeField, isEqualTo: InviteType.Admin.toString())
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
        .where(Invite.typeField, isEqualTo: InviteType.Admin.toString())
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
      var team = Team.fromMap(userData?.uid ?? '', snap.data)
        ..rebuild((b) => b..publicOnly = true);
      yield team;
    } else {
      yield null;
    }
    await for (var doc in ref.snapshots()) {
      if (doc != null && doc.exists) {
        yield Team.fromMap(userData?.uid ?? '', snap.data)
          ..rebuild((b) => b..publicOnly = true);
        ;
      } else {
        yield Team((b) => b..uid = teamUid);
      }
    }
  }

  @override
  Stream<Team> getTeamDetails({@required String teamUid}) async* {
    print('Building $teamUid');
    var referenceWrapper =
        _wrapper.collection(TEAMS_COLLECTION).document(teamUid);
    var snap = await referenceWrapper.get();
    if (snap != null && snap.exists) {
      yield Team.fromMap(userData?.uid ?? '', snap.data);
    } else {
      yield Team((b) => b..uid = teamUid);
    }
    await for (var doc in referenceWrapper.snapshots()) {
      if (doc != null && doc.exists) {
        yield Team.fromMap(userData?.uid ?? '', doc.data);
      } else {
        yield Team((b) => b..uid = teamUid);
      }
    }
  }

  ///
  /// Returns the basic set of games for this specific team.
  ///
  @override
  Stream<BuiltList<Game>> getBasicGames(
      {DateTime start, DateTime end, String teamUid, String seasonUid}) async* {
    var gameQuery = _wrapper
        .collection(GAMES_COLLECTION)
        .where(Game.TEAMUID, isEqualTo: teamUid);
    if (start != null) {
      print('Start ${start.microsecondsSinceEpoch}');
      gameQuery = gameQuery
          .where(ARRIVALTIME, isGreaterThan: start.microsecondsSinceEpoch)
          .where(ARRIVALTIME, isLessThan: end.microsecondsSinceEpoch);
    }
    if (seasonUid != null) {
      gameQuery = gameQuery.where(Game.SEASONUID, isEqualTo: seasonUid);
    }
    var queryGameSnap = await gameQuery.getDocuments();

    var data = <Game>{};
    for (var snap in queryGameSnap.documents) {
      var sharedGameUid = snap.data[Game.SHAREDDATAUID];
      if (sharedGameUid == null || sharedGameUid.isEmpty) {
        // Missing shared data uid.
        snap.data[Game.GAMESHAREDDATA] = snap.data;
      }
      print(snap.documentID);
      var g = Game.fromMap(snap.data);
      data.add(g);
    }
    yield BuiltList.of(data);

    // Merge the streams.
    await for (queryGameSnap in gameQuery.snapshots()) {
      var data = <Game>{};
      for (var snap in queryGameSnap.documents) {
        String sharedGameUid;
        sharedGameUid = snap.data[Game.SHAREDDATAUID] as String;
        if (sharedGameUid == null || sharedGameUid.isEmpty) {
          snap.data[Game.GAMESHAREDDATA] = snap.data;
        }

        var newGame = Game.fromMap(snap.data);
        data.add(newGame);
      }
      yield BuiltList.of(data);
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
    _analytics.logEvent(name: 'updatePlayer');
  }

  // Player stuff
  @override
  Future<String> addFirestorePlayer(Player player) async {
    // Add or update this record into the database.
    var ref = _wrapper.collection(PLAYERS_COLLECTION);
    var docRef = ref.document();
    var eventName = 'addPlayer';
    switch (player.playerType) {
      case PlayerType.player:
        if (player.opponentUid != null ||
            player.gameUid != null ||
            player.teamUid != null) {
          throw FormatException('opponentuid or gameUid not null');
        }
        break;
      case PlayerType.opponent:
        if (player.opponentUid == null ||
            player.opponentUid.isEmpty ||
            player.teamUid == null ||
            player.teamUid.isEmpty ||
            player.gameUid != null ||
            player.gameUid.isNotEmpty) {
          throw FormatException('opponentuid or teamUid are null');
        }
        eventName = 'addGameOpponent';
        break;
      case PlayerType.guest:
        if (player.opponentUid != null ||
            player.gameUid == null ||
            player.gameUid.isEmpty ||
            player.teamUid != null ||
            player.teamUid.isNotEmpty) {
          throw FormatException('opponentuid is null or gameUid not null');
        }
        eventName = 'addGuestOpponent';
        break;
      case PlayerType.seasonGuest:
        throw FormatException('opponentuid or gameUid not null, need '
            'to create through invite');
    }
    // Add the game.
    var p = player.rebuild((b) => b..uid = docRef.documentID);
    await docRef.setData(p.toMap(includeUsers: true));
    _analytics.logEvent(name: eventName);
    return docRef.documentID;
  }

  @override
  Future<Uri> updatePlayerImage(String playerUid, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child('player/player_$playerUid.img');
    var task = ref.putFile(imgFile);
    var snapshot = (await task.future);
    var photoUrl = snapshot.downloadUrl.toString();
    var data = <String, String>{};
    data[Player.photoUrlField] = photoUrl;
    await _wrapper
        .collection(PLAYERS_COLLECTION)
        .document(playerUid)
        .updateData(data);
    _analytics.logEvent(name: 'updatePlayerImage');
    return snapshot.downloadUrl;
  }

  @override
  Stream<Player> getMePlayer(String userUid) async* {
    final query = _wrapper.collection(PLAYERS_COLLECTION).where(
        '${Player.usersField}.$userUid.relationship',
        isEqualTo: Relationship.Me.name);
    final data = await query.getDocuments();
    if (data.documents.isNotEmpty) {
      yield Player.fromMap(data.documents.first.data);
    } else {
      yield null;
    }
    await for (final doc in query.snapshots()) {
      if (doc.documents.isNotEmpty) {
        yield Player.fromMap(data.documents.first.data);
      }
    }
  }

  @override
  Stream<Iterable<Season>> getPlayerSeasons(String playerUid) async* {
    var ref = _wrapper
        .collection(SEASONS_COLLECTION)
        .where('${Season.playersField}.$playerUid.$ADDED', isEqualTo: true);
    if (userData != null) {
      ref = ref.where('${Season.usersField}.${userData.uid}.$ADDED',
          isEqualTo: true);
    } else {
      ref = ref.where('isPublic', isEqualTo: true);
    }
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
      final myPlayer = Player.fromMap(doc.data);
      if (myPlayer.playerType == PlayerType.guest ||
          myPlayer.playerType == PlayerType.player ||
          myPlayer.playerType == PlayerType.seasonGuest) {
        // Yay!  We have a player.
        var playerInternal = PlayerUserInternal((b) => b
          ..added = true
          ..relationship = player.relationship);
        var data = <String, dynamic>{};
        data['playerType'] = PlayerType.player;
        data['${Player.usersField}.${player.userUid}'] = playerInternal.toMap();
        await doc.reference.updateData(data);
        _analytics.logEvent(name: 'addUserToPlayer');
        return true;
      }
    }
    return false;
  }

  @override
  Future<String> createPlayer(Player player) async {
    var ref = _wrapper.collection(PLAYERS_COLLECTION);
    var doc = await ref.add(player.toMap(includeUsers: true));
    _analytics.logEvent(name: 'createPlayer');
    return doc.documentID;
  }

  @override
  Future<void> deletePlayer(String playerUid) {
    _analytics.logEvent(name: 'deletePlayer');
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
        .where(Invite.emailField, isEqualTo: email)
        .where(Invite.typeField, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.playerUidField, isEqualTo: playerUid)
        .getDocuments();
    if (snapshot.documents.isEmpty) {
      var docRef = _wrapper.collection(INVITE_COLLECTION).document();

      var invite = InviteToPlayer((b) => b
        ..uid = docRef.documentID
        ..playerUid = playerUid
        ..email = email
        ..playerName = playerName
        ..sentByUid = userData.uid);

      await docRef.setData(invite.toMap());
      return docRef.documentID;
    }
    _analytics.logEvent(name: 'inviteUserToPlayer');
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
        .where(Invite.emailField, isEqualTo: email)
        .where(Invite.typeField, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: teamUid)
        .getDocuments();
    if (snapshot.documents.isEmpty) {
      var docRef = _wrapper.collection(INVITE_COLLECTION).document();

      var invite = InviteAsAdmin((b) => b
        ..uid = docRef.documentID
        ..teamUid = teamUid
        ..email = email
        ..teamName = teamName
        ..sentByUid = userData.uid);

      await docRef.setData(invite.toMap());
      return docRef.documentID;
    }
    _analytics.logEvent(name: 'inviteAdminToTeam');
    return snapshot.documents[0].documentID;
  }

  @override
  Stream<Iterable<InviteToPlayer>> getInviteForPlayerStream(
      {String playerUid}) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var query = ref
        .where(Invite.typeField, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.playerUidField, isEqualTo: playerUid);
    var wrap = await query.getDocuments();
    yield wrap.documents.map((snap) => InviteToPlayer.fromMap(snap.data));
    await for (var wrap in query.snapshots()) {
      yield wrap.documents.map((snap) => InviteToPlayer.fromMap(snap.data));
    }
  }

  @override
  Future<void> removeUserFromPlayer(Player player, String userId) {
    var doc = _wrapper.collection(PLAYERS_COLLECTION).document(player.uid);
    _analytics.logEvent(name: 'removeUserFromPlayer');
    return doc.updateData(<String, dynamic>{
      '${Player.usersField}.$userId': _wrapper.fieldValueDelete()
    });
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
    _analytics.logEvent(name: 'updateFirestoreSeason');
  }

  @override
  Future<Season> addFirestoreSeason(
      Season season, DocumentReferenceWrapper pregenDoc) async {
    var ref = pregenDoc ?? _wrapper.collection(SEASONS_COLLECTION).document();
    // Make sure the current user is in the user list so it shows up for us.
    season = season.rebuild((b) => b
      ..uid = ref.documentID
      ..users = MapBuilder(
        {
          currentUser.uid: BuiltMap.of({
            'team': true,
            'added': true,
          }),
        },
      ));
    print(season.toMap(includePlayers: true));
    await ref.setData(season.toMap(includePlayers: true));

    _analytics.logEvent(name: 'addFirestoreSeason');
    return season;
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
    data['${Season.playersField}.$playerUid'] = null;
    await doc.updateData(data);
    _analytics.logEvent(name: 'removePlayerFromSeason');

    // Check and see if this player also has no other users associated with it.
    var playerDoc =
        await _wrapper.collection(PLAYERS_COLLECTION).document(playerUid).get();
    if (playerDoc.exists) {
      var player = Player.fromMap(playerDoc.data);
      // No users so it has not been added.
      if (player.users.isEmpty) {
        // Delete the player.
        await playerDoc.reference.delete();
      }
    }
  }

  @override
  Future<void> updateSeasonPlayerForSeason(
      String seasonUid, SeasonPlayer player) async {
    var data = <String, dynamic>{};

    data['${Season.playersField}.${player.playerUid}.${SeasonPlayer.roleField}'] =
        player.role.toString();
    data['${Season.playersField}.${player.playerUid}.${SeasonPlayer.jerseyNumberField}'] =
        player.jerseyNumber;
    data['${Season.playersField}.${player.playerUid}.${SeasonPlayer.isPublicField}'] =
        player.isPublic;

    await _wrapper
        .collection(SEASONS_COLLECTION)
        .document(seasonUid)
        .updateData(data);
    _analytics.logEvent(name: 'updateRoleInTeamForSeason');
  }

  @override
  Future<bool> playerExists(String uid) async {
    // Add ourselves to the player.
    var doc = await _wrapper.collection(PLAYERS_COLLECTION).document(uid).get();
    return doc.exists;
  }

  @override
  Stream<Player> getPlayerDetails(String uid) async* {
    final doc = _wrapper.collection(PLAYERS_COLLECTION).document(uid);
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

  Future<String> _buildInviteToSeason(
      {TransactionWrapper t,
      String playerUid,
      String seasonUid,
      String seasonName,
      String teamUid,
      String teamName,
      String email,
      String playerName,
      DocumentSnapshotWrapper document}) async {
    _analytics.logEvent(name: 'inviteUserToSeason');
    if (document != null) {
      var invite =
          InviteFactory.makeInviteFromJSON(document.documentID, document.data)
              as InviteToPlayer;

      var updatedInvite = InviteToPlayer((b) => b
        ..email = invite.email
        ..playerName = playerName
        ..sentByUid = userData.uid
        ..teamName = teamName
        ..seasonName = seasonName);
      print('old invite season');

      await t.update(document.reference, updatedInvite.toMap());
      return document.documentID;
    } else {
      if (email == null || email.isEmpty) {
        return '';
      }
      var docRef = _wrapper.collection(INVITE_COLLECTION).document();

      var invite = InviteToPlayer((b) => b
        ..playerUid = playerUid
        ..uid = docRef.documentID
        ..email = email
        ..playerName = playerName
        ..sentByUid = userData.uid
        ..teamName = teamName
        ..seasonName = seasonName);

      print('new invite season');

      await t.set(docRef, invite.toMap());
      return docRef.documentID;
    }
  }

  /// Send an invite to a user for this season and team.
  @override
  Future<String> inviteUserToSeason({
    @required String email,
    @required String playerName,
    @required RoleInTeam role,
    @required String seasonUid,
    @required String seasonName,
    @required String teamUid,
    @required String teamName,
    String playerUid,
    String jerseyNumber,
  }) async {
    String docId;
    final playerDoc = _wrapper.collection(PLAYERS_COLLECTION).document();
    final seasonDoc =
        _wrapper.collection(SEASONS_COLLECTION).document(seasonUid);

    final ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    final snapshot = await ref
        .where(Invite.emailField, isEqualTo: email)
        .where(Invite.typeField, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.playerUidField, isEqualTo: playerUid)
        .getDocuments();

    await _wrapper.runTransaction((t) async {
      if (playerUid == null) {
        // Create the player as a guest, convert to a real player
        // when the invite is accepted.
        final basicPlayer = Player((b) => b
          ..name = playerName
          ..uid = playerDoc.documentID
          ..playerType = PlayerType.seasonGuest
          ..seasonUid = seasonUid
          ..isPublic = false);
        await t.set(playerDoc, basicPlayer.toMap());
        // Add the player to the season.
        await t.update(
          seasonDoc,
          {
            '${Season.playersField}.${playerDoc.documentID}':
                SeasonPlayer((b) => b
                  ..playerUid = playerDoc.documentID
                  ..added = true
                  ..jerseyNumber = jerseyNumber ?? ''
                  ..role = role).toMap(),
          },
        );
      }

      // Only do this if the email is not empty.
      docId = await _buildInviteToSeason(
        t: t,
        playerUid: playerDoc.documentID,
        seasonUid: seasonUid,
        seasonName: seasonName,
        teamUid: teamUid,
        teamName: teamName,
        email: email,
        playerName: playerName,
        document: snapshot.documents.isEmpty ? null : snapshot.documents[0],
      );

      return {};
    });
    return docId;
  }

  @override
  Stream<BuiltList<Game>> getSeasonGames(Season season) async* {
    var query = _wrapper
        .collection(GAMES_COLLECTION)
        .where('teamUid', isEqualTo: season.teamUid)
        .where('seasonUid', isEqualTo: season.uid);
    var data = await query.getDocuments();
    var stuff = data.documents.map((d) => Game.fromMap(d.data));
    print(stuff);
    yield BuiltList.of(stuff);
    // Merge the streams.
    await for (var querySnap in query.snapshots()) {
      var stuff = querySnap.documents.map((d) => Game.fromMap(d.data));
      yield BuiltList.of(stuff);
    }
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
        .where('${Season.usersField}.${userData.uid}.$ADDED', isEqualTo: true);
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
    data['${Season.playersField}.${seasonPlayer.playerUid}'] =
        seasonPlayer.toMap();
    await doc.updateData(data);
    _analytics.logEvent(name: 'addPlayerToSeason');
    return;
  }

  Future<Team> _loadTeamFromClub(
      DocumentSnapshotWrapper snap, Club club) async {
    return Team.fromMap(userData?.uid ?? '', snap.data);
  }

  // Loads the seasons for the team.  This is only used for
  // admin teams and club teams.
  @override
  Stream<BuiltList<Season>> getSeasonsForTeam(String teamUid) async* {
    // Find the seasons for the team.
    var query = _wrapper
        .collection(SEASONS_COLLECTION)
        .where(Season.teamUidFIeld, isEqualTo: teamUid)
        .where('${Season.usersField}.${userData.uid}.$ADDED', isEqualTo: true);
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
        .where(Team.clubUidField, isEqualTo: club.uid);
    if (isPublic) {
      query = query.where(Team.isPublicField, isEqualTo: true);
    } else {
      // Only get teams we can see.
      query = query.where('${Team.userField}.${userData.uid}.$ADDED',
          isEqualTo: true);
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
    _analytics.logEvent(name: 'addUserToClub');
    return _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .updateData(<String, dynamic>{
      '${Club.MEMBERS}.$newUserUid': <String, dynamic>{
        ADDED: true,
        Club.ADMIN: admin
      }
    });
  }

  @override
  Future<String> inviteUserToClub(
      {String clubName, String clubUid, String email, bool admin}) async {
    var docRef = _wrapper.collection(INVITE_COLLECTION).document();
    var invite = InviteToClub((b) => b
      ..uid = docRef.documentID
      ..sentByUid = userData.uid
      ..admin = admin
      ..clubUid = clubUid
      ..clubName = clubName
      ..email = email);
    await docRef.setData(invite.toMap());
    _analytics.logEvent(name: 'inviteUserToClub');
    return docRef.documentID;
  }

  @override
  Future<String> addClub(DocumentReferenceWrapper ref, Club club) async {
    var data = club.toMap(includeMembers: true);
    if (ref != null) {
      ref = await _wrapper.collection(CLUB_COLLECTION).add(data);
    } else {
      await ref.updateData(data);
    }
    _analytics.logEvent(name: 'addClub');
    return ref.documentID;
  }

  @override
  Future<String> updateClub(Club club, {bool includeMembers = false}) async {
    var data = club.toMap(includeMembers: includeMembers);
    await _wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData(data);

    _analytics.logEvent(name: 'updateClub');
    return club.uid;
  }

  @override
  Future<Uri> updateClubImage(Club club, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child('club/club_${club.uid}.img');
    var task = ref.putFile(imgFile);
    var snapshot = (await task.future);
    var photoUrl = snapshot.downloadUrl.toString();
    await _wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData({PHOTOURL: photoUrl});

    _analytics.logEvent(name: 'updateClubImage');
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteClubMember(Club club, String memberUid) {
    _analytics.logEvent(name: 'deleteClubMember');
    return _wrapper.collection(CLUB_COLLECTION).document(club.uid).updateData(
        <String, dynamic>{'${Club.MEMBERS}.$memberUid.$ADDED': false});
  }

  @override
  Stream<Club> getClubData({String clubUid}) async* {
    print('Loading Club $clubUid');
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
    print('Getting coaches');
    var query = _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .collection(COACH_COLLECTION);
    var wrap = await query.getDocuments();

    print('Got docs');
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
    var imageRef = _wrapper
        .storageRef()
        .child('coach/coach_${coach.clubUid}_${coach.uid}.img');
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
        await imageRef.delete();
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
          .child('coach/coach_${coach.clubUid}_${coach.uid}.img');
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
  Stream<BuiltList<NewsItem>> getClubNews(String clubUid,
      {DateTime start, int limit}) async* {
    print('getClubNews $clubUid $start $limit');
    var query = _wrapper
        .collection(CLUB_COLLECTION)
        .document(clubUid)
        .collection(NEWS_COLLECTION)
        .orderBy(NewsItem.timeCreatedId)
        .limit(limit);
    if (start != null) {
      query = query.startAt(start);
    }
    var wrap = await query.getDocuments();

    print('Got docs ${wrap.documents.length}');
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
    news = news.rebuild((b) => b
      ..uid = ref.documentID
      ..postedByUid = currentUser.uid
      ..postedByName = currentUser.profile.displayName);
    var myData = news.toMap();
    myData[NewsItem.timeCreatedId] = _wrapper.fieldValueServerTimestamp;
    await ref.setData(myData);
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
        await doc.reference.updateData({'divisonUid': leagueDivisonUid});
      }
      if (!doc.data.containsKey('seasonUid') || doc.data['seasonUid'] == null) {
        await doc.reference
            .updateData({'seasonUid': divison.data['seasonUid']});
      }
      if (!doc.data.containsKey('leagueUid')) {
        await doc.reference
            .updateData({'leagueUid': divison.data['leagueUid']});
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
        '${GameSharedData.OFFICIALRESULT}.${GameOfficialResults.HOMETEAMUID}',
        isEqualTo: leagueTeamUid);
    var queryAway = _wrapper.collection(GAMES_SHARED_COLLECTION).where(
        '${GameSharedData.OFFICIALRESULT}.${GameOfficialResults.AWAYTEAMUID}',
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
    await str.add(queryHome.snapshots());
    await str.add(queryAway.snapshots());

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
    await str.close();
  }

  @override
  Future<void> addUserToLeague(String leagueUid, bool admin) {
    _analytics.logEvent(name: 'addUserToLeague');
    return _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      '${LeagueOrTournament.MEMBERS}.${userData.uid}': <String, dynamic>{
        ADDED: true,
        LeagueOrTournament.ADMIN: admin
      }
    });
  }

  @override
  Future<void> addUserToLeagueSeason(String leagueUid, bool admin) {
    _analytics.logEvent(name: 'addUserToLeagueSeason');
    return _wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      '${LeagueOrTournamentSeason.MEMBERS}.${userData.uid}':
          AddedOrAdmin((b) => b
            ..added = true
            ..admin = admin).toMap()
    });
  }

  @override
  Future<void> addUserToLeagueDivison(String leagueUid, bool admin) {
    _analytics.logEvent(name: 'addUserToLeagueDivison');
    return _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(leagueUid)
        .updateData(<String, dynamic>{
      '${LeagueOrTournamentDivison.MEMBERS}.${userData.uid}':
          AddedOrAdmin((b) => b
            ..added = true
            ..admin = admin)
    });
  }

  @override
  Future<String> inviteUserToLeague(InviteToLeagueAsAdmin invite) async {
    var docRef = _wrapper.collection(INVITE_COLLECTION).document();

    await docRef
        .setData(invite.rebuild((b) => b..uid = docRef.documentID).toMap());
    _analytics.logEvent(name: 'inviteUserToLeague');
    return docRef.documentID;
  }

  @override
  Future<String> inviteUserToLeagueTeam(
      {String leagueSeasonUid,
      LeagueOrTournamentTeam leagueTeam,
      String email}) async {
    var docRef = _wrapper.collection(INVITE_COLLECTION).document();
    var season = await getLeagueSeasonData(leagueSeasonUid).single;
    var str = getLeagueData(leagueUid: season.leagueOrTournmentUid);
    var leagueOrTournament = await str.single;

    var teamInvite = InviteToLeagueTeam((b) => b
      ..uid = docRef.documentID
      ..email = email
      ..leagueName = leagueOrTournament.name
      ..sentByUid = userData.uid
      ..leagueDivisonUid = leagueTeam.leagueOrTournamentDivisonUid
      ..leagueTeamName = leagueTeam.name
      ..leagueUid = leagueOrTournament.uid
      ..leagueSeasonName = season.name
      ..leagueTeamUid = leagueTeam.uid);
    // Write it out to firestore.  Yay.
    await docRef.setData(teamInvite.toMap());
    _analytics.logEvent(name: 'inviteUserToLeagueTeam');
    return docRef.documentID;
  }

  @override
  Stream<BuiltList<InviteToLeagueTeam>> getLeagueOrTournmentTeamInvitesStream(
      String leagueTeamUid) async* {
    var ref = _wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    var query = ref
        .where(Invite.typeField, isEqualTo: InviteType.LeagueTeam.toString())
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
    _analytics.logEvent(name: 'updateLeague');

    return league.uid;
  }

  @override
  Future<Uri> updateLeagueImage(
      LeagueOrTournament league, Uint8List imgFile) async {
    var ref = _wrapper.storageRef().child('league/league_${league.uid}.jpg');
    var task = ref.putFile(imgFile);
    var snapshot = (await task.future);
    var photoUrl = snapshot.downloadUrl.toString();
    // Update the reference in the class.
    await _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData({PHOTOURL: photoUrl});
    _analytics.logEvent(name: 'updateLeagueImage');
    return snapshot.downloadUrl;
  }

  @override
  Future<void> deleteLeagueMember(LeagueOrTournament league, String memberUid) {
    _analytics.logEvent(name: 'deleteLeagueMember');
    return _wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData(<String, dynamic>{
      '${LeagueOrTournament.MEMBERS}.$memberUid.$ADDED': false
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
    print('Divisons $leagueSeasonUid');
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
    _analytics.logEvent(name: 'updateLeagueDivison');
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
    _analytics.logEvent(name: 'updateLeagueSeason');
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
    data['${LeagueOrTournamentTeam.WINRECORD}.$divison'] = record.toMap();
    await doc.updateData(data);
    _analytics.logEvent(name: 'updateLeagueTeam');
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

  @override
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
        .where('${Club.MEMBERS}.${userData.uid}.$ADDED', isEqualTo: true);
    print('Get main clubs ${Club.MEMBERS}.${userData.uid}.$ADDED');
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
        '${LeagueOrTournament.MEMBERS}.${userData.uid}.$ADDED',
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
        .where('${Player.usersField}.${userData.uid}.$ADDED', isEqualTo: true);
    var wrap = await query.getDocuments();
    yield BuiltList(wrap.documents.map((snap) => Player.fromMap(snap.data)));
    await for (var wrap in query.snapshots()) {
      yield BuiltList(wrap.documents.map((snap) => Player.fromMap(snap.data)));
    }
  }

  @override
  Stream<BuiltList<MessageRecipient>> getMessages(bool unread,
      {DateTime start}) async* {
    QueryWrapper query;
    if (unread) {
      query = _wrapper
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.userIdId, isEqualTo: userData.uid)
          .where(MessageRecipient.stateId,
              isEqualTo: MessageReadState.Unread.toString())
          .orderBy(MessageRecipient.sentAtId)
          .limit(_maxMessages);
    } else {
      query = _wrapper
          .collection(MESSAGE_RECIPIENTS_COLLECTION)
          .where(MessageRecipient.userIdId, isEqualTo: userData.uid)
          .orderBy(MessageRecipient.sentAtId)
          .limit(_maxMessages);
    }
    if (start != null) {
      query = query.startAt(start);
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
        .where(Invite.emailField, isEqualTo: normalizeEmail(userData.email));

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
        .where('${Team.adminsField}.${userData.uid}.$ADDED', isEqualTo: true);

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
        .where('${Team.userField}.${userData.uid}.$ADDED', isEqualTo: true);

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
        .where(Invite.typeField, isEqualTo: InviteType.Club.toString());

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
    var ref = _wrapper
        .collection(GAMES_COLLECTION)
        .document(event.gameUid)
        .collection(GAME_EVENT_COLLECTION)
        .document();
    return ref.documentID;
  }

  @override
  Future<void> setGameEvent({GameEvent event}) async {
    if (event.uid == null || event.uid.isEmpty) {
      throw ArgumentError('uid must not be empty');
    }
    print('Saving game event $event');
    _analytics.logEvent(name: 'AddGameEvent', parameters: {
      'type': event.type.toString(),
      'points': event.points.toString()
    });
    return _wrapper
        .collection(GAMES_COLLECTION)
        .document(event.gameUid)
        .collection(GAME_EVENT_COLLECTION)
        .document(event.uid)
        .setData(event.toMap());
  }

  @override
  Future<void> deleteGameEvent({String gameUid, String gameEventUid}) {
    print('Deleting event $gameEventUid');
    _analytics.logEvent(name: 'DeleteGameEvent');
    return _wrapper
        .collection(GAMES_COLLECTION)
        .document(gameUid)
        .collection(GAME_EVENT_COLLECTION)
        .document(gameEventUid)
        .delete();
  }

  @override
  Stream<BuiltList<GameEvent>> getGameEvents({String gameUid}) async* {
    var q = _wrapper
        .collection(GAMES_COLLECTION)
        .document(gameUid)
        .collection(GAME_EVENT_COLLECTION)
        .orderBy('timestamp');
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
    data.putIfAbsent('uid', () => uid);
    return data;
  }

  @override
  Future<String> addMedia({MediaInfo media, Uint8List imageFile}) async {
    final ref = _wrapper.collection(MEDIA_COLLECTION).document();
    final storageRef =
        _wrapper.storageRef().child('media/media_${ref.documentID}.img');
    final task = storageRef.putFile(imageFile);
    final snapshot = (await task.future);
    final photoUrl = snapshot.downloadUrl;

    try {
      await _wrapper.runTransaction((t) async {
        // Write the data up to storage.
        final p = media.rebuild((b) => b
          ..uid = ref.documentID
          ..url = photoUrl);
        final data = p.toMap();
        data['uploadTime'] = _wrapper.fieldValueServerTimestamp;
        await t.set(ref, data);
        _analytics.logEvent(name: 'addMedia');
        return;
      });
    } catch (e) {
      await storageRef.delete();
      rethrow;
    }
    return ref.documentID;
  }

  @override
  Future<void> deleteMedia({String mediaInfoUid}) {
    _analytics.logEvent(name: 'DeleteMedia');
    return _wrapper
        .collection(MEDIA_COLLECTION)
        .document(mediaInfoUid)
        .delete();
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForGame({String gameUid}) async* {
    var q = _wrapper
        .collection(MEDIA_COLLECTION)
        .where('gameUid', isEqualTo: gameUid);
    if (currentUser == null) {
      q = q.where('isPublic', isEqualTo: true);
    }
    var snap = await q.getDocuments();
    yield BuiltList.of(snap.documents
        .map((snap) => MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    await for (var snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map(
          (snap) => MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForSeason({String seasonUid}) async* {
    var q = _wrapper
        .collection(MEDIA_COLLECTION)
        .where('seasonUid', isEqualTo: seasonUid);
    if (currentUser == null) {
      q = q.where('isPublic', isEqualTo: true);
    }
    var snap = await q.getDocuments();
    yield BuiltList.of(snap.documents
        .map((snap) => MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    await for (var snap in q.snapshots()) {
      yield BuiltList.of(snap.documents.map(
          (snap) => MediaInfo.fromMap(_addUid(snap.documentID, snap.data))));
    }
  }

  @override
  Stream<BuiltList<MediaInfo>> getMediaForPlayer({String playerUid}) async* {
    var q = _wrapper
        .collection(MEDIA_COLLECTION)
        .where('playerUid', isEqualTo: playerUid);
    if (currentUser == null) {
      q = q.where('isPublic', isEqualTo: true);
    }
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

  @override
  Future<void> updateMediaInfoThumbnail(
      {MediaInfo mediaInfo, String thumbnailUrl}) async {
    var ref = _wrapper.collection(MEDIA_COLLECTION).document(mediaInfo.uid);
    await ref.updateData({thumbnailUrl: thumbnailUrl});
  }

  @override
  Future<void> updateGamePlayerData(
      {String gameUid,
      String playerUid,
      GamePlayerSummary summary,
      bool opponent}) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    _analytics.logEvent(name: 'UpdateGamePlayer');
    return ref.updateData({
      '${Game.playersField}.$playerUid': summary.toMap(),
    });
  }

  @override
  Future<void> updateGameOpponentData(
      {String gameUid, String opponentUid, GamePlayerSummary summary}) {
    var ref = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    _analytics.logEvent(name: 'UpdateGameOpponent');
    return ref.updateData({
      '${Game.opponentField}.$opponentUid': summary.toMap(),
    });
  }

  @override
  Future<void> addGameOpponentPlayer({
    @required String gameUid,
    @required String teamUid,
    @required String opponentUid,
    @required String opponentName,
    @required String jerseyNumber,
  }) async {
    var playerDoc = _wrapper.collection(PLAYERS_COLLECTION).document();
    var gameDoc = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    var opDoc = _wrapper
        .collection(TEAMS_COLLECTION)
        .document(teamUid)
        .collection(OPPONENT_COLLECTION)
        .document(opponentUid);
    await _wrapper.runTransaction((t) async {
      if (opponentName == null) {
        var op = await t.get(opDoc);
        if (!op.exists) {
          throw FormatException('No opponent $opponentUid');
        }
        opponentName = Opponent.fromMap(op.data).name;
      }
      var play = Player((b) => b
        ..opponentUid = opponentUid
        ..isPublic = true
        ..name = opponentName
        ..uid = playerDoc.documentID
        ..playerType = PlayerType.opponent
        ..teamUid = teamUid);
      print('Bing ${play.toMap()}');
      await t.set(playerDoc, play.toMap());
      print('Updaing game ${gameDoc.documentID}');
      await t.update(gameDoc, {
        '${Game.opponentField}.${playerDoc.documentID}':
            GamePlayerSummary((b) => b
              ..playing = true
              ..jerseyNumber = jerseyNumber
              ..currentlyPlaying = true).toMap()
      });
      return;
    });
  }

  @override
  Future<void> addGameGuestPlayer({
    @required String gameUid,
    @required String guestName,
    @required String jerseyNumber,
  }) async {
    var playerDoc = _wrapper.collection(PLAYERS_COLLECTION).document();
    var gameDoc = _wrapper.collection(GAMES_COLLECTION).document(gameUid);
    await _wrapper.runTransaction((t) async {
      var play = Player((b) => b
        ..gameUid = gameUid
        ..isPublic = true
        ..name = guestName
        ..playerType = PlayerType.guest
        ..uid = playerDoc.documentID);
      await t.set(playerDoc, play.toMap());
      await t.update(gameDoc, {
        '${Game.opponentField}.${playerDoc.documentID}':
            GamePlayerSummary((b) => b
              ..playing = true
              ..jerseyNumber = jerseyNumber
              ..currentlyPlaying = true).toMap()
      });
      return;
    });
  }

  /// Gets the opponent players for the team/opponent.
  @override
  Stream<BuiltList<Player>> getPlayersForOpponent(
      {String teamUid, opponentUid}) async* {
    var query = _wrapper
        .collection(PLAYERS_COLLECTION)
        .where('teamUid', isEqualTo: teamUid)
        .where('opponentUid', isEqualTo: opponentUid);

    var docs = await query.getDocuments();
    var result = docs.documents.map<Player>((d) => Player.fromMap(d.data));
    yield BuiltList.of(result);

    await for (var snap in query.snapshots()) {
      var resultNew = snap.documents.map<Player>((d) => Player.fromMap(d.data));
      yield BuiltList.of(resultNew);
    }
  }
}
