import 'dart:async';
import 'common.dart';
import 'base.dart';
import 'invite.dart';
import 'game.dart';
import 'team.dart';
import 'winrecord.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RoleInTeam { Player, Coach, NonPlayer }

class SeasonPlayer {
  String playerUid;
  String displayName;
  String photoUrl;
  RoleInTeam role;

  SeasonPlayer({this.playerUid, this.displayName, this.role, this.photoUrl});

  SeasonPlayer.copy(SeasonPlayer copy) {
    playerUid = copy.playerUid;
    displayName = copy.displayName;
    role = copy.role;
    photoUrl = copy.photoUrl;
  }

  static const String _ROLE = 'role';
  static const String _PHOTOURL = 'photourl';

  void fromJSON(Map<String, dynamic> data) {
    role = RoleInTeam.values.firstWhere((e) => e.toString() == data[_ROLE]);
    displayName = getString(data[NAME]);
    photoUrl = getString(data[_PHOTOURL]);
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_ROLE] = role.toString();
    ret[NAME] = displayName;
    ret[ADDED] = true;
    ret[_PHOTOURL] = photoUrl;
    return ret;
  }
}

class Season {
  String name;
  String uid;
  String teamUid;
  WinRecord record;
  List<SeasonPlayer> players;

  StreamController<List<Invite>> _controller;
  StreamSubscription<QuerySnapshot> _inviteSnapshot;
  Stream<List<Invite>> _stream;
  List<Invite> _invites;

  Season({this.name, this.uid, this.teamUid, this.record, this.players}) {
    if (players == null) {
      players = new List<SeasonPlayer>();
    }
  }

  Season.copy(Season copy) {
    name = copy.name;
    uid = copy.uid;
    teamUid = copy.teamUid;
    record = copy.record;
    players = copy.players;
  }

  Iterable<Game> getGames() {
    // Get all the games for this season.
    return UserDatabaseData.instance.games.values.where((game) {
      return game.teamUid == this.teamUid && game.seasonUid == uid;
    });
  }

  static const String RECORD = 'record';
  static const String PLAYERS = 'players';
  static const String TEAMUID = 'teamUid';

  void fromJSON(String uid, Map<String, dynamic> data) {
    this.uid = uid;
    name = getString(data[NAME]);
    record = new WinRecord();
    record.fromJSON(data[RECORD]);
    this.teamUid = teamUid;
    this.record = record;
    this.teamUid = data[TEAMUID];
    Map<String, dynamic> playersData = data[PLAYERS];
    List<SeasonPlayer> newPlayers = new List<SeasonPlayer>();
    playersData.forEach((key, val) {
      SeasonPlayer player = new SeasonPlayer();
      player.playerUid = key;
      if (val != null) {
        player.fromJSON(val);
        newPlayers.add(player);
      }
    });
    players = newPlayers;
    print('Update Season ' + uid);
  }

  Map<String, dynamic> toJSON({bool includePlayers: false}) {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = name;
    ret[RECORD] = record.toJSON();
    ret[TEAMUID] = teamUid;
    if (includePlayers) {
      Map<String, dynamic> output = new Map<String, dynamic>();
      players.forEach((value) {
        output[value.playerUid] = value.toJSON();
      });
      ret[PLAYERS] = output;
    }
    return ret;
  }

  Future<void> updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(SEASONS_COLLECTION);
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON());
      this.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(uid).updateData(toJSON());
    }
  }

  Future<void> removePlayer(SeasonPlayer player) async {
    DocumentReference doc =
        Firestore.instance.collection(SEASONS_COLLECTION).document(uid);
    Map<String, dynamic> data = new Map<String, dynamic>();
    data[PLAYERS + "." + player.playerUid] = null;
    await doc.updateData(data);
  }

  Future<void> updateRoleInTeam(SeasonPlayer player, RoleInTeam role) async {
    Map<String, dynamic> data = new Map<String, dynamic>();

    data[PLAYERS + "." + player.playerUid + "." + SeasonPlayer._ROLE] =
        role.toString();
    Firestore.instance.collection(SEASONS_COLLECTION).document(uid).updateData(data);
  }

  // Send an invite to a user for this season and team.
  Future<void> inviteUser(
      {String userId, String playername, String email}) async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    QuerySnapshot snapshot = await ref
        .where(Invite.EMAIL, isEqualTo: email)
        .where(Invite.SEASONUID, isEqualTo: uid)
        .where(Invite.TEAMUID, isEqualTo: teamUid)
        .getDocuments();
    Team team = UserDatabaseData.instance.teams[teamUid];
    if (snapshot.documents.length > 0) {
      Invite invite = new Invite();
      invite.fromJSON(
          snapshot.documents[0].documentID, snapshot.documents[0].data);
      invite.playerName.add(playername);
      invite.seasonName = name;
      invite.teamName = team.name;
      snapshot.documents[0].reference.updateData(invite.toJSON());
      print('Updating invite');
    } else {
      Invite invite = new Invite();
      invite.email = email;
      invite.teamUid = this.teamUid;
      invite.seasonUid = this.uid;
      invite.playerName = [playername];
      invite.sentByUid = userId;
      invite.teamName = team.name;
      invite.seasonName = name;

      print('Adding invite');
      return ref.add(invite.toJSON());
    }
  }

  Stream<List<Invite>> get inviteStream {
    if (_stream == null) {
      _controller = new StreamController<List<Invite>>();
      _stream = _controller.stream.asBroadcastStream();
    }
    // Do an async query.
    _doInviteQuery();
    return _stream;
  }

  Future<void> _doInviteQuery() async {
    CollectionReference ref = Firestore.instance.collection(INVITE_COLLECTION);
    // See if the invite already exists.
    _inviteSnapshot = ref
        .where(Invite.SEASONUID, isEqualTo: uid)
        .where(Invite.TEAMUID, isEqualTo: teamUid)
        .snapshots
        .listen((QuerySnapshot query) {
      List<Invite> ret = new List<Invite>();

      query.documents.forEach((DocumentSnapshot doc) {
        Invite invite = new Invite();
        invite.fromJSON(doc.documentID, doc.data);
        ret.add(invite);
      });
      _invites = ret;
      _controller.add(_invites);
    });
  }

  void close() {
    if (_controller != null) {
      _controller.close();
    }
    if (_stream != null) {
      _stream = null;
    }
    if (_inviteSnapshot != null) {
      _inviteSnapshot.cancel();
      _inviteSnapshot = null;
    }
  }

  // Is one of the players associated with this user an admin?
  bool isAdmin() {
    //Find the team and check there.
    if (UserDatabaseData.instance.teams.containsKey(teamUid)) {
      return UserDatabaseData.instance.teams[teamUid].isAdmin();
    }
    return false;
  }
}
