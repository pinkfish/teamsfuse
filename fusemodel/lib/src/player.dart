import 'dart:async';
import 'dart:io';

import 'common.dart';
import 'userprofile.dart';
import 'userdatabasedata.dart';
import 'invite.dart';

enum Relationship { Me, Parent, Guardian, Friend }

class PlayerUser {
  String userUid;
  Relationship relationship;
  FusedUserProfile profile;

  PlayerUser({this.userUid, this.relationship, this.profile});

  static const String _RELATIONSHIP = 'relationship';

  void fromJSON(Map<dynamic, dynamic> data) {
    try {
      relationship = Relationship.values
          .firstWhere((e) => e.toString() == data[_RELATIONSHIP]);
    } catch (e) {
      relationship = Relationship.Friend;
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = new Map<String, dynamic>();

    data[_RELATIONSHIP] = relationship.toString();
    data[ADDED] = true;
    return data;
  }

  Future<FusedUserProfile> getProfile() async {
    return UserDatabaseData.instance.userAuth.getProfile(userUid);
  }

  String toString() {
    return "PlayerUser [$userUid, $relationship, $profile]";
  }
}

class Player {
  String name;
  String uid;
  String photoUrl;
  Map<String, PlayerUser> users = {};

  // Handle invirtes.
  StreamController<List<InviteToPlayer>> _controller;
  Stream<List<InviteToPlayer>> _stream;
  List<InviteToPlayer> _invites;

  // ignore
  List<StreamSubscription<dynamic>> _subscriptions = [];

  Player();

  Player.copy(Player copy) {
    name = copy.name;
    uid = copy.uid;
    photoUrl = copy.photoUrl;
    users = new Map.from(copy.users);
  }

  static const String USERS = 'user';

  void fromJSON(String playerUid, Map<String, dynamic> data) {
    uid = playerUid;
    name = data[NAME];
    photoUrl = data[PHOTOURL];

    Map<String, PlayerUser> newUsers = new Map<String, PlayerUser>();
    Map<dynamic, dynamic> usersData = data[USERS] as Map<dynamic, dynamic>;
    if (usersData != null) {
      usersData.forEach((dynamic key, dynamic data) {
        if (data != null) {
          PlayerUser mapToUser = new PlayerUser();
          mapToUser.userUid = key.toString();
          mapToUser.fromJSON(data as Map<dynamic, dynamic>);
          newUsers[key.toString()] = mapToUser;
        }
      });
    }
    users = newUsers;
  }

  void setupSnap() {
    _subscriptions =
        UserDatabaseData.instance.updateModel.setupPlayerSnap(this);
  }

  Map<String, dynamic> toJSON({bool includeUsers: false}) {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[NAME] = getString(name);
    ret[PHOTOURL] = getString(photoUrl);
    if (includeUsers) {
      Map<String, dynamic> userOut = new Map<String, dynamic>();
      users.forEach((String uid, PlayerUser players) {
        userOut[uid] = players.toJSON();
      });
      ret[USERS] = userOut;
    }
    return ret;
  }

  void dispose() {
    _subscriptions?.forEach((StreamSubscription<dynamic> sub) {
      sub.cancel();
    });
    _subscriptions = null;
    _controller?.close();
    _controller = null;
    _invites?.clear();
    _invites = null;
  }

  Future<void> updateFirestore({bool includeUsers = false}) async {
    return UserDatabaseData.instance.updateModel
        .updateFirestorePlayer(this, includeUsers);
  }

  Future<Uri> updateImage(File imgFile) async {
    return UserDatabaseData.instance.updateModel
        .updatePlayerImage(this, imgFile);
  }

  // Send an invite to a user for this season and team.
  Future<void> inviteUser({String email}) async {
    return UserDatabaseData.instance.updateModel
        .inviteUserToPlayer(this, email: normalizeEmail(email));
  }

  Stream<List<InviteToPlayer>> get inviteStream {
    if (_stream == null) {
      _controller = new StreamController<List<InviteToPlayer>>();
      _stream = _controller.stream.asBroadcastStream();
    }
    // Do an async query.
    _doInviteQuery();
    return _stream;
  }

  List<InviteToPlayer> get cachedInvites => _invites;

  Future<void> removeFirebaseUser(String userId) {
    return UserDatabaseData.instance.updateModel
        .removeUserFromPlayer(this, userId);
  }

  void setInvites(List<InviteToPlayer> invites) {
    _invites = invites;
    _controller.add(invites);
  }

  Future<void> _doInviteQuery() async {
    _subscriptions.add(await UserDatabaseData.instance.updateModel
        .getInviteForPlayerStream(this));
  }

  @override
  String toString() {
    return 'Player{name: $name, uid: $uid, photoUrl: $photoUrl, users: $users, invites: $_invites}';
  }
}
