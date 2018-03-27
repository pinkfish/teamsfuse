import 'dart:async';
import 'dart:io';

import 'common.dart';
import 'base.dart';
import 'season.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_fuse/services/authentication.dart';

enum Relationship { Me, Parent, Guardian, Friend }

class PlayerUser {
  String userUid;
  Relationship relationship;
  UserProfile profile;

  static const String _RELATIONSHIP = 'relationship';

  void fromJSON(Map<String, dynamic> data) {
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

  Future<UserProfile> getProfile() async {
    profile = await UserAuth.instance.getProfile(userUid);
    return profile;
  }
}

class Player {
  String name;
  String uid;
  String photoUrl;
  Map<String, PlayerUser> users;

  Player();

  Player.copy(Player copy) {
    name = copy.name;
    uid = copy.uid;
    photoUrl = copy.photoUrl;
  }

  // ignore
  StreamSubscription<QuerySnapshot> get snapshot {
    return UserDatabaseData.snapshotMapping[this];
  }

  static const String USERS = 'user';

  void fromJSON(String playerUid, Map<String, dynamic> data) {
    uid = playerUid;
    name = data[NAME];
    photoUrl = data[PHOTOURL];

    Map<String, PlayerUser> newUsers = new Map<String, PlayerUser>();
    Map<String, dynamic> usersData = data[USERS];
    if (usersData != null) {
      usersData.forEach((String key, dynamic data) {
        PlayerUser mapToUser = new PlayerUser();
        mapToUser.userUid = key;
        mapToUser.fromJSON(data);
        newUsers[key] = mapToUser;
      });
    }
    users = newUsers;
  }

  void setupSnap() {
    // Teams.
    CollectionReference ref = Firestore.instance
        .collection(SEASONS_COLLECTION)
        .where(Season.PLAYERS + '.' + uid + '.' + ADDED, isEqualTo: true)
        .reference();
    UserDatabaseData.snapshotMapping[this] =
        ref.snapshots.listen(UserDatabaseData.instance.onSeasonUpdated);
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

  void close() {
    if (UserDatabaseData.snapshotMapping.containsKey(this)) {
      UserDatabaseData.snapshotMapping[this].cancel();
      UserDatabaseData.snapshotMapping.remove(this);
    }
  }

  Future<void> updateFirestore() async {
    // Add or update this record into the database.
    CollectionReference ref = Firestore.instance.collection(PLAYERS_COLLECTION);
    if (uid == '' || uid == null) {
      // Add the game.
      DocumentReference doc = await ref.add(toJSON());
      this.uid = doc.documentID;
    } else {
      // Update the game.
      await ref.document(uid).updateData(toJSON());
    }
  }

  Future<Uri> updateImage(File imgFile) async {
    final StorageReference ref =
        FirebaseStorage.instance.ref().child("player_" + uid + ".img");
    final StorageUploadTask task = ref.put(imgFile);
    final UploadTaskSnapshot snapshot = (await task.future);
    this.photoUrl = snapshot.downloadUrl.toString();
    print('photurl $photoUrl');
    Map<String, String> data = new Map<String, String>();
    data[PHOTOURL] = photoUrl;
    await Firestore.instance
        .collection(PLAYERS_COLLECTION)
        .document(uid)
        .updateData(data);
    return snapshot.downloadUrl;
  }
}
