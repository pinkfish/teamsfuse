import 'package:fusemodel/fusemodel.dart';
import 'dart:async';
import 'package:timezone/timezone.dart';
import 'dart:io';
import 'firestore.dart';

class DatabaseUpdateModelImpl implements DatabaseUpdateModel {
  static const int maxMessages = 20;
  FirestoreWrapper wrapper;
  PersistenData persistenData;

  DatabaseUpdateModelImpl(this.wrapper, this.persistenData);

  // Stuff for game updates.
  @override
  Future<void> updateFirestoreGame(Game game, bool sharedData) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(GAMES_COLLECTION);
    CollectionReferenceWrapper refShared =
        wrapper.collection(GAMES_SHARED_COLLECTION);
    if (game.uid == null || game.uid == '') {
      // Add the shared stuff, then the game.
      if (game.sharedData.officialResults.homeTeamLeagueUid == null) {
        game.sharedData.officialResults.homeTeamLeagueUid = game.teamUid;
      }
      DocumentReferenceWrapper sharedDoc =
          await refShared.add(game.sharedData.toJSON());
      game.sharedDataUid = sharedDoc.documentID;
      // Add the game.
      DocumentReferenceWrapper doc = await ref.add(game.toJSON());
      game.uid = doc.documentID;
    } else {
      if (sharedData) {
        if (game.sharedDataUid.isEmpty) {
          DocumentReferenceWrapper sharedDoc =
              await refShared.add(game.sharedData.toJSON());
          game.sharedDataUid = sharedDoc.documentID;
        } else {
          refShared
              .document(game.sharedDataUid)
              .updateData(game.sharedData.toJSON());
        }
      }
      // Update the game.
      return ref.document(game.uid).updateData(game.toJSON());
    }
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
      game.uid = sharedDoc.documentID;
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

  Future<void> deleteFirestoreSharedGame(GameSharedData game) async {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(game.uid);
    await ref.delete();
    QuerySnapshotWrapper snap = await wrapper
        .collection(GAMES_COLLECTION)
        .where(Game.SHAREDDATAUID, isEqualTo: game.uid)
        .getDocuments();

    for (DocumentSnapshotWrapper doc in snap.documents) {
      await doc.reference.delete();
    }
    return;
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
  Future<void> updateFirestoreGameResult(Game game, GameResultDetails result) {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_COLLECTION).document(game.uid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[Game.RESULT] = result.toJSON();
    return ref.updateData(data);
  }

  Future<void> updateFirestoreOfficalGameResult(
      GameSharedData game, GameOfficialResults result) {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(game.uid);

    Map<String, dynamic> data = <String, dynamic>{};
    data[GameSharedData.OFFICIALRESULT] = result.toJSON();
    return ref.updateData(data);
  }

  // Invite firestore updates
  @override
  Future<void> firestoreInviteDelete(Invite invite) {
    return wrapper.collection(INVITE_COLLECTION).document(invite.uid).delete();
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

  Future<List<GameLog>> _getGameLogs(
      Game game, Future<QuerySnapshotWrapper> query) async {
    List<GameLog> logs = <GameLog>[];
    QuerySnapshotWrapper acutalData = await query;
    acutalData.documents.forEach((DocumentSnapshotWrapper doc) {
      GameLog log = new GameLog.fromJson(doc.documentID, doc.data);
      logs.add(log);
    });
    return logs;
  }

  @override
  GameLogReturnData readGameLogs(Game game) {
    GameLogReturnData ret = new GameLogReturnData();
    CollectionReferenceWrapper coll = wrapper
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    Future<QuerySnapshotWrapper> query = coll.getDocuments();
    ret.logs = _getGameLogs(game, query);

    ret.myLogStream =
        coll.snapshots().listen((QuerySnapshotWrapper snap) async {
      game.updateLogs(await _getGameLogs(game, query));
    });
    return ret;
  }

  @override
  Future<String> addFirestoreGameLog(Game game, GameLog log) {
    CollectionReferenceWrapper coll = wrapper
        .collection(GAMES_COLLECTION)
        .document(game.uid)
        .collection(GAME_LOG_COLLECTION);
    log.eventTime = new TZDateTime.now(local);
    return coll.add(log.toJSON()).then((DocumentReferenceWrapper ref) {
      log.uid = ref.documentID;
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
    CollectionReferenceWrapper ref = wrapper.collection("Messages");
    if (mess.uid == '' || mess.uid == null) {
      // Add the game.
      DocumentReferenceWrapper doc =
          await ref.add(mess.toJSON(includeMessage: true));
      mess.timeSent = new DateTime.now().millisecondsSinceEpoch;
      mess.uid = doc.documentID;
      // Add the message body.
      DocumentReferenceWrapper messageRef = wrapper
          .collection(MESSAGES_COLLECTION)
          .document(mess.uid)
          .collection(MESSAGES_COLLECTION)
          .document(mess.uid);
      // Add in the recipients collection.
      await Future.forEach(mess.recipients.keys, (String str) async {
        MessageRecipient rec = mess.recipients[str];
        rec.messageId = mess.uid;
        rec.sentAt = new DateTime.now().millisecondsSinceEpoch;
        DocumentReferenceWrapper recRef = await wrapper
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
    DocumentReferenceWrapper ref = wrapper
        .collection("Messages")
        .document(mess.uid)
        .collection(Message.BODY)
        .document(mess.uid);
    DocumentSnapshotWrapper snap = await ref.get();
    if (snap.exists) {
      mess.message = snap.data[Message.BODY] as String;
      mess.messagesLoaded = true;
      return mess.message;
    }
    return null;
  }

  @override
  Future<Message> getMessage(String messageId) async {
    DocumentSnapshotWrapper ref =
        await wrapper.collection(MESSAGES_COLLECTION).document(messageId).get();
    if (ref.exists) {
      return new Message.fromJSON(ref.documentID, ref.data);
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
    if (opponent.uid == '' || opponent.uid == null) {
      // Add the game.
      DocumentReferenceWrapper doc = await ref.add(opponent.toJSON());
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
    return wrapper
        .collection(TEAMS_COLLECTION)
        .document(opponent.teamUid)
        .collection(OPPONENT_COLLECTION)
        .document(opponent.uid)
        .delete();
  }

  @override
  Future<Iterable<Game>> getOpponentGames(Opponent opponent) async {
    CollectionReferenceWrapper ref = wrapper.collection(GAMES_COLLECTION);
    // See if the games for the season.
    QuerySnapshotWrapper snap = await ref
        .where(Game.TEAMUID, isEqualTo: opponent.teamUid)
        .where(Game.OPPONENTUID, isEqualTo: opponent.uid)
        .getDocuments();
    return Future.wait(snap.documents.map((DocumentSnapshotWrapper doc) async {
      String sharedGameUid = doc.data[Game.SHAREDDATAUID];
      GameSharedData sharedData;
      if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
        // Load the shared stuff too.
        DocumentSnapshotWrapper doc = await wrapper
            .collection(GAMES_SHARED_COLLECTION)
            .document(sharedGameUid)
            .get();
        sharedData = new GameSharedData.fromJSON(doc.documentID, doc.data);
      } else {
        sharedData = new GameSharedData.fromJSON(sharedGameUid, doc.data);
      }
      Game game = new Game.fromJSON(
          opponent.teamUid, doc.documentID, doc.data, sharedData);
      return game;
    }));
  }

  // Team stuff
  void _onTeamUpdated(Team team, DocumentSnapshotWrapper snap) {
    if (snap.exists) {
      team.updateFromJSON(snap.data);
      persistenData.updateElement(
          PersistenData.teamsTable, team.uid, team.toJSON());
    }
  }

  @override
  Future<List<StreamSubscription<dynamic>>> setupSnapForTeam(Team team) async {
    List<StreamSubscription<dynamic>> ret = <StreamSubscription<dynamic>>[];
    ret.add(wrapper
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .snapshots()
        .listen((DocumentSnapshotWrapper snap) => _onTeamUpdated(team, snap)));

    CollectionReferenceWrapper opCollection = wrapper
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .collection(OPPONENT_COLLECTION);
    QuerySnapshotWrapper queryOpponentSnap = await opCollection.getDocuments();
    team.onOpponentUpdated(_firestoreData(queryOpponentSnap.documents));
    ret.add(opCollection.snapshots().listen((QuerySnapshotWrapper snap) =>
        team.onOpponentUpdated(_firestoreData(snap.documents))));
    print('Loaded ops ${team.uid} ${queryOpponentSnap.documents.length}');

    // If there is a club for this team, load that too.
    if (team.clubUid != null) {
      DocumentReferenceWrapper ref =
          wrapper.collection(CLUB_COLLECTION).document(team.clubUid);

      DocumentSnapshotWrapper query = await ref.get();
      UserDatabaseData.instance.onClubUpdated(new FirestoreWrappedData(
          id: query.documentID, data: query.data, exists: query.exists));
      ret.add(ref.snapshots().listen((DocumentSnapshotWrapper snap) {
        UserDatabaseData.instance.onClubUpdated(new FirestoreWrappedData(
            id: query.documentID, data: query.data, exists: query.exists));
      }));
    }

    if (team.isAdmin()) {
      QueryWrapper query = wrapper
          .collection(SEASONS_COLLECTION)
          .where(Season.TEAMUID, isEqualTo: team.uid);
      // Get all the seasons.
      query.getDocuments().then((QuerySnapshotWrapper query) {
        for (DocumentSnapshotWrapper doc in query.documents) {
          team.updateSeason(doc.documentID, doc.data);
          persistenData.updateElement(
              PersistenData.seasonTable, doc.documentID, doc.data);
        }
      });
      ret.add(query.snapshots().listen((QuerySnapshotWrapper query) {
        for (DocumentSnapshotWrapper doc in query.documents) {
          team.updateSeason(doc.documentID, doc.data);
          persistenData.updateElement(
              PersistenData.seasonTable, doc.documentID, doc.data);
        }
        for (DocumentChangeWrapper change in query.documentChanges) {
          if (change.type == DocumentChangeTypeWrapper.removed) {
            team.seasons.remove(change.document.documentID);
            persistenData.deleteElement(
                PersistenData.seasonTable, change.document.documentID);
          }
        }
      }));
    }
    return ret;
  }

  @override
  Future<void> loadOpponents(Team team) async {
    Map<String, Map<String, dynamic>> opps = await persistenData
        .getAllTeamElements(PersistenData.opponentsTable, team.uid);

    Map<String, Opponent> ops = <String, Opponent>{};
    opps.forEach((String opUid, Map<String, dynamic> data) {
      Opponent op = new Opponent();
      op.fromJSON(opUid, team.uid, data);
      ops[opUid] = op;
    });
    print('Update ops ${team.uid} $ops');
    team.opponents = ops;
  }

  @override
  Future<void> updateFirestoreTeam(Team team, PregenUidRet pregen) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(TEAMS_COLLECTION);
    if (team.uid == '' || team.uid == null) {
      // Add the game.
      DocumentReferenceWrapper doc;
      if (pregen != null) {
        doc = pregen.extra as DocumentReferenceWrapper;
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
    CollectionReferenceWrapper ref = wrapper.collection(TEAMS_COLLECTION);
    DocumentReferenceWrapper docRef = ref.document();
    ret.uid = docRef.documentID;
    ret.extra = docRef;
    return ret;
  }

  @override
  Future<Uri> updateTeamImage(Team team, File imgFile) async {
    final StorageReferenceWrapper ref =
        wrapper.storageRef().child("team_" + team.uid + ".img");
    final StorageUploadTaskWrapper task = ref.putFile(imgFile);
    final UploadTaskSnapshotWrapper snapshot = await task.future;
    team.photoUrl = snapshot.downloadUrl.toString();
    await wrapper
        .collection(TEAMS_COLLECTION)
        .document(team.uid)
        .updateData({PHOTOURL: team.photoUrl});
    return snapshot.downloadUrl;
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
  Future<String> inviteAdminToTeam(Team team, String email) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshotWrapper snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .getDocuments();
    if (snapshot.documents.length == 0) {
      InviteAsAdmin invite = new InviteAsAdmin(
          email: email,
          teamName: team.name,
          teamUid: team.uid,
          sentByUid: UserDatabaseData.instance.userUid);

      DocumentReferenceWrapper doc = await ref.add(invite.toJSON());
      return doc.documentID;
    }
    return snapshot.documents[0].documentID;
  }

  @override
  StreamSubscription<dynamic> getInviteForTeamStream(Team team) {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshotWrapper> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Admin.toString())
        .where(InviteAsAdmin.TEAMUID, isEqualTo: team.uid)
        .snapshots()
        .listen((QuerySnapshotWrapper query) {
      List<InviteAsAdmin> ret = <InviteAsAdmin>[];

      for (DocumentSnapshotWrapper doc in query.documents) {
        InviteAsAdmin invite =
            new InviteAsAdmin.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      }
      team.setInvites(ret);
    });
    return snap;
  }

  @override
  SeasonSubscription getAllSeasons(String teamUid) {
    SeasonSubscription seasonSubscription = new SeasonSubscription();
    seasonSubscription.subscriptions.add(wrapper
        .collection(SEASONS_COLLECTION)
        .where(Season.TEAMUID, isEqualTo: teamUid)
        .snapshots()
        .listen((QuerySnapshotWrapper wrap) {
      List<Season> seasons = <Season>[];
      for (DocumentSnapshotWrapper doc in wrap.documents) {
        Season s = new Season();
        s.fromJSON(doc.documentID, doc.data);
        seasons.add(s);
      }
      seasonSubscription.addUpdate(seasons);
    }));
    return seasonSubscription;
  }

  Future<Team> getPublicTeamDetails(String uid) async {
    DocumentSnapshotWrapper snap =
        await wrapper.collection(TEAMS_COLLECTION).document(uid).get();
    if (snap.exists) {
      Team team =
          new Team.fromJSON(snap.documentID, snap.data, publicOnly: true);
      return team;
    }
    return null;
  }

  GameSubscription _getGamesInternal(
      Iterable<Game> cachedGames,
      Set<String> teams,
      String seasonUid,
      DateTime start,
      DateTime end,
      FilterDetails details) {
    GameSubscription sub = new GameSubscription(cachedGames);
    sub.loaded = cachedGames.isNotEmpty;
    if (teams.length == 0) {
      // No teams, we are finished then.
      sub.loaded = true;
      return sub;
    }
    Map<String, Set<Game>> maps = <String, Set<Game>>{};
    for (String teamUid in teams) {
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

      gameQuery.getDocuments().then((QuerySnapshotWrapper queryGameSnap) async {
        Set<Game> data = new Set<Game>();
        for (DocumentSnapshotWrapper snap in queryGameSnap.documents) {
          String sharedGameUid = snap.data[Game.SHAREDDATAUID];
          GameSharedData sharedData;
          if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
            DocumentReferenceWrapper sharedRef = wrapper
                .collection(GAMES_SHARED_COLLECTION)
                .document(sharedGameUid);
            DocumentSnapshotWrapper snapShared = await sharedRef.get();
            sharedData = new GameSharedData.fromJSON(
                snapShared.documentID, snapShared.data);
            // Add in a subscription to this shared game stuff and listen to it.
            sub.subscriptions.add(sharedRef
                .snapshots()
                .listen((DocumentSnapshotWrapper snapUpdate) {
              if (snapUpdate.exists) {
                GameSharedData newData = GameSharedData.fromJSON(
                    snapUpdate.documentID, snapUpdate.data);
                if (maps.containsKey(teamUid)) {
                  Game g = maps[teamUid].lookup(snap.documentID);
                  if (g != null) {
                    g.sharedData.updateFrom(newData);
                    g.markGameChanged();
                  }
                }
              }
            }));
          } else {
            sharedData = new GameSharedData.fromJSON(sharedGameUid, snap.data);
          }
          Game g = new Game.fromJSON(
              teamUid, snap.documentID, snap.data, sharedData);
          Season season;
          if (UserDatabaseData.instance.teams.containsKey(g.teamUid)) {
            if (UserDatabaseData.instance.teams[g.teamUid].seasons
                .containsKey(g.seasonUid)) {
              season = UserDatabaseData
                  .instance.teams[g.teamUid].seasons[g.seasonUid];
            }
          }
          if (details == null || details.isIncluded(g, season)) {
            data.add(g);
          }
        }
        if (!maps.containsKey(teamUid)) {
          maps[teamUid] = new Set<Game>();
        }
        maps[teamUid] = data;
        if (maps.length == teams.length) {
          List<Game> newData = <Game>[];

          for (Set<Game> it in maps.values) {
            newData.addAll(it);
          }
          sub.addUpdate(newData);
          sub.initialData = newData;
          sub.loaded = true;
          UserDatabaseData.instance.doCacheGames(newData);
        }
      });

      sub.subscriptions.add(gameQuery
          .snapshots()
          .listen((QuerySnapshotWrapper queryGameSnap) async {
        Set<Game> data = new Set<Game>();
        if (!maps.containsKey(teamUid)) {
          maps[teamUid] = new Set<Game>();
        }
        for (DocumentSnapshotWrapper snap in queryGameSnap.documents) {
          String sharedGameUid;
          Game g = maps[teamUid].lookup(snap.documentID);
          GameSharedData sharedData;
          if (g == null) {
            sharedGameUid = snap.data[Game.SHAREDDATAUID] as String;
            if (sharedGameUid != null && sharedGameUid.isNotEmpty) {
              DocumentReferenceWrapper sharedRef = wrapper
                  .collection(GAMES_SHARED_COLLECTION)
                  .document(sharedGameUid);
              DocumentSnapshotWrapper snapShared = await sharedRef.get();
              sharedData = new GameSharedData.fromJSON(
                  snapShared.documentID, snapShared.data);
              // Listen to changes too.
              sub.subscriptions.add(sharedRef
                  .snapshots()
                  .listen((DocumentSnapshotWrapper snapUpdate) {
                if (snapUpdate.exists) {
                  GameSharedData newData = GameSharedData.fromJSON(
                      snapUpdate.documentID, snapUpdate.data);
                  if (maps.containsKey(teamUid)) {
                    Game g = maps[teamUid].lookup(snap.documentID);
                    if (g != null) {
                      g.sharedData.updateFrom(newData);
                      g.markGameChanged();
                    }
                  }
                }
              }));
            } else {
              sharedData =
                  new GameSharedData.fromJSON(sharedGameUid, snap.data);
            }
          } else {
            sharedData = g.sharedData;
          }

          Game newGame = new Game.fromJSON(
              teamUid, snap.documentID, snap.data, sharedData);
          bool include = true;
          Season season;
          if (UserDatabaseData.instance.teams.containsKey(newGame.teamUid)) {
            if (UserDatabaseData.instance.teams[newGame.teamUid].seasons
                .containsKey(newGame.seasonUid)) {
              season = UserDatabaseData
                  .instance.teams[newGame.teamUid].seasons[newGame.seasonUid];
            }
          }
          if (details != null && !details.isIncluded(newGame, season)) {
            include = false;
          }

          // If we have a game already, update that.
          if (g != null) {
            g.updateFrom(newGame);
            newGame.sharedData = g.sharedData;
            if (include) {
              data.add(g);
            }
          } else if (include) {
            data.add(newGame);
          }
        }
        maps[teamUid] = data;
        // Only notify if we have loaded everything already.
        if (maps.length == teams.length) {
          Set<Game> newData = new Set<Game>();
          for (Set<Game> it in maps.values) {
            newData.addAll(it);
          }
          // Update the cache so we can find these games when the
          // app is open.
          UserDatabaseData.instance.doCacheGames(newData);
          sub.addUpdate(newData);
          sub.initialData = newData;
          sub.loaded = true;
        }
      }));
    }
    return sub;
  }

  // Games!
  @override
  GameSubscription getGames(Iterable<Game> cachedGames, Set<String> teams,
      DateTime start, DateTime end, FilterDetails details) {
    return _getGamesInternal(cachedGames, teams, null, start, end, details);
  }

  Future<GameSharedData> _getSharedGameInternal(String sharedGameUid) async {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);

    DocumentSnapshotWrapper doc = await ref.get();
    if (doc.exists) {
      GameSharedData gameSharedData =
          new GameSharedData.fromJSON(doc.documentID, doc.data);

      return gameSharedData;
    }
    return null;
  }

  @override
  SharedGameSubscription getSharedGame(String sharedGameUid) {
    DocumentReferenceWrapper ref =
        wrapper.collection(GAMES_SHARED_COLLECTION).document(sharedGameUid);
    SharedGameSubscription sub = new SharedGameSubscription();
    sub.subscriptions
        .add(ref.snapshots().listen((DocumentSnapshotWrapper snap) {
      GameSharedData gameSharedData =
          new GameSharedData.fromJSON(snap.documentID, snap.data);
      sub.addUpdate([gameSharedData]);
    }));
    ref.get().then((DocumentSnapshotWrapper snap) {
      GameSharedData gameSharedData =
          new GameSharedData.fromJSON(snap.documentID, snap.data);
      sub.addUpdate([gameSharedData]);
    });
    return sub;
  }

  @override
  Future<Game> getGame(String gameUid) async {
    DocumentSnapshotWrapper doc =
        await wrapper.collection(GAMES_COLLECTION).document(gameUid).get();
    if (!doc.exists) {
      return null;
    }

    String sharedGameUid = doc.data[Game.SHAREDDATAUID];
    GameSharedData shared = await _getSharedGameInternal(sharedGameUid);
    Game game =
        new Game.fromJSON(doc.data[Game.TEAMUID], gameUid, doc.data, shared);
    return game;
  }

  // Player stuff
  @override
  Future<void> updateFirestorePlayer(Player player, bool includeUsers) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(PLAYERS_COLLECTION);
    if (player.uid == '' || player.uid == null) {
      // Add the game.
      DocumentReferenceWrapper doc =
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
    final StorageReferenceWrapper ref =
        wrapper.storageRef().child("player_" + player.uid + ".img");
    final StorageUploadTaskWrapper task = ref.putFile(imgFile);
    final UploadTaskSnapshotWrapper snapshot = (await task.future);
    player.photoUrl = snapshot.downloadUrl.toString();
    print('photurl $player.photoUrl');
    Map<String, String> data = <String, String>{};
    data[PHOTOURL] = player.photoUrl;
    await wrapper
        .collection(PLAYERS_COLLECTION)
        .document(player.uid)
        .updateData(data);
    return snapshot.downloadUrl;
  }

  @override
  List<StreamSubscription<dynamic>> setupPlayerSnap(Player player) {
    List<StreamSubscription<dynamic>> ret = <StreamSubscription<dynamic>>[];
    // Teams.
    QueryWrapper ref = wrapper.collection(SEASONS_COLLECTION).where(
        Season.PLAYERS + "." + player.uid + "." + ADDED,
        isEqualTo: true);
    ret.add(ref.snapshots().listen((QuerySnapshotWrapper query) {
      UserDatabaseData.instance
          .onSeasonUpdated(_firestoreData(query.documents));
    }));
    return ret;
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
    player.uid = doc.documentID;
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
  Future<void> inviteUserToPlayer(Player player, {String email}) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshotWrapper snapshot = await ref
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

      return ref.add(invite.toJSON());
    }
  }

  @override
  Future<StreamSubscription<dynamic>> getInviteForPlayerStream(
      Player player) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshotWrapper> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Player.toString())
        .where(InviteToPlayer.PLAYERUID, isEqualTo: player.uid)
        .snapshots()
        .listen((QuerySnapshotWrapper query) {
      List<InviteToPlayer> ret = <InviteToPlayer>[];

      for (DocumentSnapshotWrapper doc in query.documents) {
        InviteToPlayer invite =
            new InviteToPlayer.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      }
      player.setInvites(ret);
    });
    return snap;
  }

  @override
  Future<void> removeUserFromPlayer(Player player, String userId) {
    DocumentReferenceWrapper doc =
        wrapper.collection(PLAYERS_COLLECTION).document(player.uid);
    return doc.updateData(<String, dynamic>{Player.USERS + userId: null});
  }

  // Season updates
  @override
  Future<void> updateFirestoreSeason(
      Season season, bool includePlayers, PregenUidRet pregen) async {
    // Add or update this record into the database.
    CollectionReferenceWrapper ref = wrapper.collection(SEASONS_COLLECTION);
    if (season.uid == '' || season.uid == null) {
      // Add the game.
      DocumentReferenceWrapper doc;
      if (pregen != null) {
        doc = pregen.extra as DocumentReferenceWrapper;
        await doc.setData(season.toJSON(includePlayers: includePlayers));
      } else {
        doc = await ref.add(season.toJSON(includePlayers: includePlayers));
      }
      season.uid = doc.documentID;
      persistenData.updateElement(PersistenData.seasonTable, season.uid,
          season.toJSON(includePlayers: true));
    } else {
      // Update the game.
      await ref
          .document(season.uid)
          .updateData(season.toJSON(includePlayers: includePlayers));
      persistenData.updateElement(PersistenData.seasonTable, season.uid,
          season.toJSON(includePlayers: true));
    }
  }

  @override
  PregenUidRet precreateUidSeason(Season season) {
    PregenUidRet ret = new PregenUidRet();
    CollectionReferenceWrapper ref = wrapper.collection(SEASONS_COLLECTION);
    DocumentReferenceWrapper docRef = ref.document();
    ret.uid = docRef.documentID;
    ret.extra = docRef;
    return ret;
  }

  @override
  Future<void> removePlayerFromSeason(
      Season season, SeasonPlayer player) async {
    DocumentReferenceWrapper doc =
        wrapper.collection(SEASONS_COLLECTION).document(season.uid);
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
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshotWrapper snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: season.uid)
        .where(InviteToTeam.TEAMUID, isEqualTo: season.teamUid)
        .getDocuments();
    Team team = UserDatabaseData.instance.teams[season.teamUid];
    if (snapshot.documents.length > 0) {
      InviteToTeam invite = InviteFactory.makeInviteFromJSON(
          snapshot.documents[0].documentID, snapshot.documents[0].data);

      invite.playerName.add(playername);
      InviteToTeam updatedInvite = new InviteToTeam(
          email: invite.email,
          teamUid: invite.teamUid,
          seasonUid: invite.uid,
          playerName: invite.playerName,
          sentByUid: invite.sentByUid,
          teamName: team.name,
          seasonName: season.name,
          role: role);
      snapshot.documents[0].reference.updateData(updatedInvite.toJSON());
    } else {
      InviteToTeam invite = new InviteToTeam(
          email: email,
          teamUid: season.teamUid,
          seasonUid: season.uid,
          playerName: <String>[playername],
          sentByUid: userId,
          teamName: team.name,
          seasonName: season.name,
          role: role);

      return ref.add(invite.toJSON());
    }
  }

  @override
  Future<StreamSubscription<dynamic>> getInviteForSeasonStream(
      Season season) async {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshotWrapper> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.Team.toString())
        .where(InviteToTeam.SEASONUID, isEqualTo: season.uid)
        .where(InviteToTeam.TEAMUID, isEqualTo: season.teamUid)
        .snapshots()
        .listen((QuerySnapshotWrapper query) {
      List<InviteToTeam> ret = <InviteToTeam>[];

      for (DocumentSnapshotWrapper doc in query.documents) {
        InviteToTeam invite =
            new InviteToTeam.fromJSON(doc.documentID, doc.data);
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
    return _getGamesInternal(games, teams, season.uid, null, null, null);
  }

  @override
  Future<Season> getSeason(String seasonUid) async {
    DocumentSnapshotWrapper doc =
        await wrapper.collection(SEASONS_COLLECTION).document(seasonUid).get();
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
    DocumentReferenceWrapper doc =
        await wrapper.collection(SEASONS_COLLECTION).document(seasonUid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[Season.PLAYERS + "." + seasonPlayer.playerUid] = seasonPlayer.toJSON();
    doc.updateData(data);
    return;
  }

  List<FirestoreWrappedData> _firestoreData(
      List<DocumentSnapshotWrapper> documents) {
    List<FirestoreWrappedData> data = <FirestoreWrappedData>[];
    for (DocumentSnapshotWrapper snap in documents) {
      data.add(new FirestoreWrappedData(id: snap.documentID, data: snap.data));
    }
    return data;
  }

  List<FirestoreWrappedData> _firestoreRemovedData(
      List<DocumentChangeWrapper> documents) {
    List<FirestoreWrappedData> data = <FirestoreWrappedData>[];
    for (DocumentChangeWrapper snap in documents) {
      if (snap.type == DocumentChangeTypeWrapper.removed) {
        data.add(new FirestoreWrappedData(
            id: snap.document.documentID, data: snap.document.data));
      }
    }
    return data;
  }

  Future<Team> _loadTeamFromClub(
      DocumentSnapshotWrapper snap, Club club) async {
    if (UserDatabaseData.instance.teams.containsKey(snap.documentID)) {
      // Team in here should always be up to date.
      return UserDatabaseData.instance.teams[snap.documentID];
    } else {
      final Team team = new Team.fromJSON(snap.documentID, snap.data,
          publicOnly: !club.isAdmin());
      // Find the seasons for the team.
      QuerySnapshotWrapper query = await wrapper
          .collection(SEASONS_COLLECTION)
          .where(Season.TEAMUID, isEqualTo: snap.documentID)
          .getDocuments();
      for (DocumentSnapshotWrapper doc in query.documents) {
        Season season = new Season();
        season.fromJSON(doc.documentID, doc.data);
        team.seasons[season.uid] = season;
        persistenData.updateElement(
            PersistenData.seasonTable, season.uid, doc.data);
      }
      return team;
    }
  }

  // clubs!
  @override
  TeamSubscription getClubTeams(Club club) {
    TeamSubscription sub = new TeamSubscription();
    QueryWrapper query = wrapper
        .collection(TEAMS_COLLECTION)
        .where(Team.CLUBUID, isEqualTo: club.uid);
    query.getDocuments().then((QuerySnapshotWrapper snap) async {
      List<Team> teams = <Team>[];
      for (DocumentSnapshotWrapper mySnap in snap.documents) {
        teams.add(await _loadTeamFromClub(mySnap, club));
      }
      sub.addUpdate(teams);
    });
    sub.subscriptions
        .add(query.snapshots().listen((QuerySnapshotWrapper snap) async {
      List<Team> teams = <Team>[];
      for (DocumentSnapshotWrapper mySnap in snap.documents) {
        teams.add(await _loadTeamFromClub(mySnap, club));
      }
      sub.addUpdate(teams);
    }));
    return sub;
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
  Future<String> inviteUserToClub(InviteToClub invite) async {
    DocumentReferenceWrapper ref =
        await wrapper.collection(INVITE_COLLECTION).add(invite.toJSON());
    return ref.documentID;
  }

  @override
  Future<String> updateClub(Club club, {bool includeMembers = false}) async {
    Map<String, dynamic> data = club.toJson(includeMembers: includeMembers);
    if (club.uid == null) {
      DocumentReferenceWrapper ref =
          await wrapper.collection(CLUB_COLLECTION).add(data);
      club.uid = ref.documentID;
    } else {
      await wrapper
          .collection(CLUB_COLLECTION)
          .document(club.uid)
          .updateData(data);
    }
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
    club.photoUrl = snapshot.downloadUrl.toString();
    await wrapper
        .collection(CLUB_COLLECTION)
        .document(club.uid)
        .updateData({PHOTOURL: club.photoUrl});

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
  Future<Club> getClubData(String clubUid) async {
    DocumentSnapshotWrapper snap =
        await wrapper.collection(CLUB_COLLECTION).document(clubUid).get();
    if (snap.exists) {
      persistenData.updateElement(
          PersistenData.clubsTable, snap.documentID, snap.data);

      return new Club.fromJson(snap.documentID, snap.data);
    }
    return null;
  }

  // leagues!
  @override
  LeagueOrTournmentTeamSubscription getLeagueDivisionTeams(
      String leagueDivisonUid) {
    LeagueOrTournmentTeamSubscription sub =
        new LeagueOrTournmentTeamSubscription();
    QueryWrapper query = wrapper.collection(LEAGUE_TEAM_COLLECTION).where(
        LeagueOrTournamentTeam.LEAGUEORTOURNMENTDIVISONUID,
        isEqualTo: leagueDivisonUid);
    query.getDocuments().then((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentTeam> teams = <LeagueOrTournamentTeam>[];
      for (DocumentSnapshotWrapper mySnap in snap.documents) {
        LeagueOrTournamentTeam team =
            new LeagueOrTournamentTeam.fromJSON(mySnap.documentID, mySnap.data);
        teams.add(team);
      }
      sub.addUpdate(teams);
    });
    sub.subscriptions.add(query.snapshots().listen((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentTeam> teams = <LeagueOrTournamentTeam>[];
      for (DocumentSnapshotWrapper mySnap in snap.documents) {
        LeagueOrTournamentTeam team =
            new LeagueOrTournamentTeam.fromJSON(mySnap.documentID, mySnap.data);
        teams.add(team);
      }
      sub.addUpdate(teams);
    }));
    return sub;
  }

  @override
  SharedGameSubscription getLeagueGamesForDivison(String leagueDivisonUid) {
    QueryWrapper query = wrapper
        .collection(GAMES_SHARED_COLLECTION)
        .where(GameSharedData.LEAGUEDIVISIONUID, isEqualTo: leagueDivisonUid);

    // Snapshot and the main query.
    SharedGameSubscription sub = new SharedGameSubscription();
    sub.subscriptions.add(query.snapshots().listen((QuerySnapshotWrapper snap) {
      List<GameSharedData> ret = <GameSharedData>[];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        GameSharedData game =
            new GameSharedData.fromJSON(doc.documentID, doc.data);
        ret.add(game);
      }
      sub.addUpdate(ret);
    }));
    query.getDocuments().then((QuerySnapshotWrapper snap) {
      List<GameSharedData> ret = <GameSharedData>[];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        GameSharedData game =
            new GameSharedData.fromJSON(doc.documentID, doc.data);
        ret.add(game);
      }
      sub.addUpdate(ret);
    });
    return sub;
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

  Future<void> inviteUserToLeagueTeam(
      LeagueOrTournament league,
      LeagueOrTournamentSeason season,
      LeagueOrTournamentTeam leagueTeam,
      String email) async {
    InviteToLeagueTeam teamInvite = new InviteToLeagueTeam(
        email: email,
        leagueName: league.name,
        sentByUid: UserDatabaseData.instance.userUid,
        leagueDivisonUid: leagueTeam.leagueOrTournamentDivisonUid,
        leagueTeamName: leagueTeam.name,
        leagueUid: league.uid,
        leagueSeasonName: season.name,
        leagueTeamUid: leagueTeam.uid);
    // Write it out to firestore.  Yay.
    return wrapper.collection(INVITE_COLLECTION).add(teamInvite.toJSON());
  }

  @override
  StreamSubscription<dynamic> getLeagueOrTournmentTeamInvitesStream(
      LeagueOrTournamentTeam leagueOrTournmentTeam) {
    CollectionReferenceWrapper ref = wrapper.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    StreamSubscription<QuerySnapshotWrapper> snap = ref
        .where(Invite.TYPE, isEqualTo: InviteType.LeagueTeam.toString())
        .where(InviteToLeagueTeam.LEAGUETEAMUID,
            isEqualTo: leagueOrTournmentTeam.uid)
        .snapshots()
        .listen((QuerySnapshotWrapper query) {
      List<InviteToLeagueTeam> ret = <InviteToLeagueTeam>[];

      for (DocumentSnapshotWrapper doc in query.documents) {
        InviteToLeagueTeam invite =
            new InviteToLeagueTeam.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      }
      leagueOrTournmentTeam.setInvites(ret);
    });
    return snap;
  }

  @override
  Future<String> updateLeague(LeagueOrTournament league,
      {bool includeMembers = false}) async {
    Map<String, dynamic> data = league.toJson(includeMembers: includeMembers);
    if (league.uid == null) {
      DocumentReferenceWrapper ref =
          await wrapper.collection(LEAGUE_COLLECTON).add(data);
      league.uid = ref.documentID;
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
    league.photoUrl = snapshot.downloadUrl.toString();
    // Update the reference in the class.
    await wrapper
        .collection(LEAGUE_COLLECTON)
        .document(league.uid)
        .updateData({PHOTOURL: league.photoUrl});
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
  Future<LeagueOrTournament> getLeagueData(String leagueUid) async {
    DocumentSnapshotWrapper snap =
        await wrapper.collection(LEAGUE_COLLECTON).document(leagueUid).get();
    if (snap.exists) {
      persistenData.updateElement(
          PersistenData.leagueOrTournamentTable, snap.documentID, snap.data);
      return new LeagueOrTournament.fromJson(snap.documentID, snap.data);
    }
    return null;
  }

  @override
  LeagueOrTournamentSeasonSubscription getLeagueSeasons(String leagueUid) {
    LeagueOrTournamentSeasonSubscription sub =
        new LeagueOrTournamentSeasonSubscription();
    QueryWrapper query = wrapper.collection(LEAGUE_SEASON_COLLECTION).where(
        LeagueOrTournamentSeason.LEAGUEORTOURNMENTUID,
        isEqualTo: leagueUid);
    sub.subscriptions.add(query.snapshots().listen((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentSeason> seasons = <LeagueOrTournamentSeason>[];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        seasons.add(
            new LeagueOrTournamentSeason.fromJSON(doc.documentID, doc.data));
      }
      sub.addUpdate(seasons);
    }));
    query.getDocuments().then((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentSeason> seasons = <LeagueOrTournamentSeason>[];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        seasons.add(
            new LeagueOrTournamentSeason.fromJSON(doc.documentID, doc.data));
      }
      sub.addUpdate(seasons);
    });
    return sub;
  }

  @override
  LeagueOrTournamentDivisonSubscription getLeagueDivisonsForSeason(
      String leagueSeasonUid) {
    LeagueOrTournamentDivisonSubscription sub =
        new LeagueOrTournamentDivisonSubscription();
    QueryWrapper query = wrapper.collection(LEAGUE_DIVISION_COLLECTION).where(
        LeagueOrTournamentDivison.LEAGUEORTOURNMENTSEASONUID,
        isEqualTo: leagueSeasonUid);
    sub.subscriptions.add(query.snapshots().listen((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentDivison> divisions = <LeagueOrTournamentDivison>[];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        divisions.add(
            new LeagueOrTournamentDivison.fromJSON(doc.documentID, doc.data));
      }
      sub.addUpdate(divisions);
    }));
    query.getDocuments().then((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentDivison> divisions = <LeagueOrTournamentDivison>[];
      for (DocumentSnapshotWrapper doc in snap.documents) {
        divisions.add(
            new LeagueOrTournamentDivison.fromJSON(doc.documentID, doc.data));
      }
      sub.addUpdate(divisions);
    });
    return sub;
  }

  @override
  LeagueOrTournmentTeamSubscription getLeagueTeamsForTeamSeason(
      String teamSeasonUid) {
    LeagueOrTournmentTeamSubscription sub =
        new LeagueOrTournmentTeamSubscription();
    QueryWrapper query = wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .where(LeagueOrTournamentTeam.SEASONUID, isEqualTo: teamSeasonUid);
    query.getDocuments().then((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentTeam> teams = <LeagueOrTournamentTeam>[];
      for (DocumentSnapshotWrapper mySnap in snap.documents) {
        LeagueOrTournamentTeam team =
            new LeagueOrTournamentTeam.fromJSON(mySnap.documentID, mySnap.data);
        teams.add(team);
      }
      sub.addUpdate(teams);
    });
    sub.subscriptions.add(query.snapshots().listen((QuerySnapshotWrapper snap) {
      List<LeagueOrTournamentTeam> teams = <LeagueOrTournamentTeam>[];
      for (DocumentSnapshotWrapper mySnap in snap.documents) {
        LeagueOrTournamentTeam team =
            new LeagueOrTournamentTeam.fromJSON(mySnap.documentID, mySnap.data);
        teams.add(team);
      }
      sub.addUpdate(teams);
    }));
    return sub;
  }

  @override
  Future<LeagueOrTournamentDivison> getLeagueDivisionData(
      String leagueDivisionUid) async {
    DocumentSnapshotWrapper doc = await wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(leagueDivisionUid)
        .get();
    if (doc.exists) {
      return new LeagueOrTournamentDivison.fromJSON(doc.documentID, doc.data);
    }
    return null;
  }

  @override
  Future<LeagueOrTournamentSeason> getLeagueSeasonData(
      String leagueSeasonUid) async {
    DocumentSnapshotWrapper doc = await wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(leagueSeasonUid)
        .get();
    if (doc.exists) {
      return new LeagueOrTournamentSeason.fromJSON(doc.documentID, doc.data);
    }
    return null;
  }

  @override
  Future<void> updateLeagueDivison(LeagueOrTournamentDivison division) async {
    if (division.uid == null) {
      DocumentReferenceWrapper doc = await wrapper
          .collection(LEAGUE_DIVISION_COLLECTION)
          .add(division.toJSON());
      division.uid = doc.documentID;
      return new Future.value(null);
    }
    return wrapper
        .collection(LEAGUE_DIVISION_COLLECTION)
        .document(division.uid)
        .updateData(division.toJSON());
  }

  @override
  Future<void> updateLeagueSeason(LeagueOrTournamentSeason season) async {
    if (season.uid == null) {
      DocumentReferenceWrapper doc = await wrapper
          .collection(LEAGUE_SEASON_COLLECTION)
          .add(season.toJSON());
      season.uid = doc.documentID;
      return new Future.value(null);
    }
    return wrapper
        .collection(LEAGUE_SEASON_COLLECTION)
        .document(season.uid)
        .updateData(season.toJSON());
  }

  @override
  Future<void> updateLeagueTeam(LeagueOrTournamentTeam team) async {
    if (team.uid == null) {
      DocumentReferenceWrapper doc =
          await wrapper.collection(LEAGUE_TEAM_COLLECTION).add(team.toJSON());
      team.uid = doc.documentID;
      return new Future.value(null);
    }
    return wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(team.uid)
        .updateData(team.toJSON());
  }

  @override
  Future<void> updateLeagueTeamRecord(
      LeagueOrTournamentTeam team, String divison) async {
    DocumentReferenceWrapper doc =
        await wrapper.collection(LEAGUE_TEAM_COLLECTION).document(team.uid);
    Map<String, dynamic> data = <String, dynamic>{};
    data[LeagueOrTournamentTeam.WINRECORD + "." + divison] =
        team.record[divison].toJSON();
    doc.updateData(data);
  }

  @override
  Future<LeagueOrTournamentTeam> getLeagueTeamData(String teamUid) async {
    DocumentSnapshotWrapper doc = await wrapper
        .collection(LEAGUE_TEAM_COLLECTION)
        .document(teamUid)
        .get();
    if (doc.exists) {
      return new LeagueOrTournamentTeam.fromJSON(doc.documentID, doc.data);
    }
    return null;
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
        new LeagueOrTournamentTeam.fromJSON(doc.documentID, doc.data);
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
  InitialSubscription getMainClubs(String userUid) {
    QueryWrapper query = wrapper
        .collection(CLUB_COLLECTION)
        .where(Club.MEMBERS + "." + userUid + "." + ADDED, isEqualTo: true);
    InitialSubscription sub = new InitialSubscription(
        startData: query.getDocuments().then(
            (QuerySnapshotWrapper query) => _firestoreData(query.documents)));
    query.snapshots().listen((QuerySnapshotWrapper snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getMainLeagueOrTournaments(String userUid) {
    QueryWrapper query = wrapper.collection(LEAGUE_COLLECTON).where(
        LeagueOrTournament.MEMBERS + "." + userUid + "." + ADDED,
        isEqualTo: true);
    InitialSubscription sub = new InitialSubscription(
        startData: query.getDocuments().then(
            (QuerySnapshotWrapper query) => _firestoreData(query.documents)));
    query.snapshots().listen((QuerySnapshotWrapper snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getPlayers(String userUid) {
    QueryWrapper collection = wrapper
        .collection(PLAYERS_COLLECTION)
        .where(Player.USERS + "." + userUid + "." + ADDED, isEqualTo: true);
    InitialSubscription sub = new InitialSubscription(
        startData: collection.getDocuments().then(
            (QuerySnapshotWrapper query) => _firestoreData(query.documents)));
    collection.snapshots().listen((QuerySnapshotWrapper snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getMessages(String userUid, bool unread) {
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
    InitialSubscription sub = new InitialSubscription(
        startData: query.getDocuments().then(
            (QuerySnapshotWrapper query) => _firestoreData(query.documents)));
    query.snapshots().listen((QuerySnapshotWrapper snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getInvites(String email) {
    QueryWrapper inviteCollection = wrapper
        .collection(INVITE_COLLECTION)
        .where(Invite.EMAIL, isEqualTo: normalizeEmail(email));

    InitialSubscription sub = new InitialSubscription(
        startData: inviteCollection.getDocuments().then(
            (QuerySnapshotWrapper query) => _firestoreData(query.documents)));
    inviteCollection.snapshots().listen((QuerySnapshotWrapper snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }

  @override
  InitialSubscription getTeamAdmins(String userUid) {
    QueryWrapper teamCollection = wrapper
        .collection(TEAMS_COLLECTION)
        .where(Team.ADMINS + "." + userUid, isEqualTo: true);

    InitialSubscription sub = new InitialSubscription(
        startData: teamCollection.getDocuments().then(
            (QuerySnapshotWrapper query) => _firestoreData(query.documents)));
    teamCollection.snapshots().listen((QuerySnapshotWrapper snap) {
      sub.addData(new FirestoreChangedData(
          newList: _firestoreData(snap.documents),
          removed: _firestoreRemovedData(snap.documentChanges)));
    });
    return sub;
  }
}
