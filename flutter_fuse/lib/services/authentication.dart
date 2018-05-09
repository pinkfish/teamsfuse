import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';
import 'package:fusemodel/fusemodel.dart';

class UserData {
  String _email;
  String uid;
  String password;
  bool isEmailVerified;
  FusedUserProfile profile;

  UserData({this.profile, String email, this.uid, this.password})
      : _email = email;

  set email(String val) {
    if (profile != null) {
      profile.email = val;
    }
    _email = val;
  }

  String get email {
    return _email;
  }

  UserData.copy(UserData copy) {
    this.profile = new FusedUserProfile.copy(copy.profile);
    this.email = copy.email;
    this.uid = copy.uid;
    this.password = copy.password;
  }

  String toString() {
    return "UserData [$email $uid $profile]";
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class UserAuth {
  static UserAuth instance = new UserAuth();
  UserData _currentUser;
  FirebaseUser _currentFirebaseUser;
  StreamController<UserData> _controller = new StreamController<UserData>();
  Stream<UserData> _stream;
  StreamSubscription<DocumentSnapshot> _profileUpdates;
  String _token;
  StreamSubscription<FirebaseUser> _updateStream;

  UserAuth() {
    _updateStream = _auth.onAuthStateChanged.listen((FirebaseUser input) async {
      print('onAuthStateChanged');
      print(input);
      if (_profileUpdates != null) {
        _profileUpdates.cancel();
        _profileUpdates = null;
      }
      if (_currentUser != null) {
        // Delete the old token.
        deleteNotificationToken();
      }
      if (input == null) {
        _currentUser = null;
        _currentFirebaseUser = null;
        _controller.add(null);
      } else {
        _currentUser = await _userDataFromFirestore(input, true);
        _currentFirebaseUser = input;
        _controller.add(_currentUser);
        // Update the notification token.
        if (_token != null) {
          setNotificationToken(_token);
        }
        DocumentReference ref = Firestore.instance
            .collection(USER_DATA_COLLECTION)
            .document(input.uid);
        _profileUpdates = ref.snapshots.listen(this._onProfileUpdates);
      }
    });
  }

  void dispose() {
    _profileUpdates?.cancel();
    _updateStream?.cancel();
  }

  // To create new User
  Future<UserData> createUser(UserData userData) {
    return _auth
        .createUserWithEmailAndPassword(
            email: userData.email, password: userData.password)
        .then((FirebaseUser user) {
      userData.uid = user.uid;
      user.sendEmailVerification();
      DocumentReference ref = Firestore.instance
          .collection(USER_DATA_COLLECTION)
          .document(user.uid);
      return ref.setData(userData.profile.toJSON()).then((void data) async {
        // With update uid.
        // Create a 'me' user.
        Player player = new Player();
        player.name = userData.profile.displayName;
        PlayerUser playerUser = new PlayerUser();
        playerUser.userUid = user.uid;
        playerUser.relationship = Relationship.Me;
        player.users[user.uid] = playerUser;
        await player.updateFirestore();
        await signIn(userData);
        return userData;
      });
    });
  }

  // To verify new User
  Future<UserData> signIn(UserData userData) async {
    print('Signin $userData');
    FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: userData.email, password: userData.password);
    print("Got the sign in $user, now returning current user");
    return currentUser();
  }

  // To reset the password.
  Future<void> sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // New user verification email.
  Future<bool> sendEmailVerification() async {
    if (_currentFirebaseUser != null) {
      await _currentFirebaseUser.sendEmailVerification();
      return true;
    } else {
      return false;
    }
  }

  Future<void> reloadUser() async {
    await _currentFirebaseUser.reload();
    // Force an update once it is reloaded.
    _userDataFromFirestore(_currentFirebaseUser, false);
  }

  // Sign the user out.
  Future<void> signOut() async {
    return _auth.signOut();
  }

  Stream<UserData> onAuthChanged() {
    if (_stream == null) {
      _stream = _controller.stream.asBroadcastStream();
    }
    return _stream;
  }

  Future<UserData> currentUser() async {
    print('Loading locally');
    if (_currentUser == null) {
      FirebaseUser fbUser = await _auth.currentUser();
      if (fbUser != null) {
        _currentFirebaseUser = fbUser;
        print('Loading from firestore');
        UserData user = await _userDataFromFirestore(fbUser, false);
        print('Loaded!');
        if (_profileUpdates == null) {
          DocumentReference ref = Firestore.instance
              .collection(USER_DATA_COLLECTION)
              .document(user.uid);
          _profileUpdates = ref.snapshots.listen(this._onProfileUpdates);
        }
        return user;
      } else {
        _currentFirebaseUser = null;
      }
    } else {
      return _currentUser;
    }
    return null;
  }

  Future<void> updateProfile(UserData user) async {
    DocumentReference ref =
        Firestore.instance.collection(USER_DATA_COLLECTION).document(user.uid);
    await ref.updateData(user.profile.toJSON());
  }

  Future<FusedUserProfile> getProfile(String userId) async {
    DocumentSnapshot ref = await Firestore.instance
        .collection(USER_DATA_COLLECTION)
        .document(userId)
        .get();
    if (ref.exists) {
      FusedUserProfile profile = new FusedUserProfile();
      profile.fromJSON(ref.data);
      return profile;
    }
    return null;
  }

  void _onProfileUpdates(DocumentSnapshot doc) {
    if (doc.exists) {
      SqlData.instance
          .updateElement(SqlData.PROFILE_TABLE, doc.documentID, doc.data);
      FusedUserProfile profile = new FusedUserProfile();
      profile.fromJSON(doc.data);
      _currentUser.profile = profile;
      _controller.add(_currentUser);
    }
  }

  Future<UserData> _userDataFromFirestore(
      FirebaseUser input, bool forceProfile) async {
    // Read from sql for the profile details first, assume the snap
    // shot listener will catch the actual firebase stuff when
    // it exists.
    Map<String, dynamic> data =
        await SqlData.instance.getElement(SqlData.PROFILE_TABLE, input.uid);
    print('sql data $data');
    UserData user = new UserData();
    user.email = input.email;
    user.uid = input.uid;
    user.isEmailVerified = input.isEmailVerified;
    _currentFirebaseUser = input;
    if (data == null && forceProfile) {
      print('No sql data');
      Future<DocumentSnapshot> ref = Firestore.instance
          .collection(USER_DATA_COLLECTION)
          .document(input.uid)
          .get();
      if (forceProfile) {
        DocumentSnapshot doc = await ref;
        data = doc.data;
      } else {
        // Update when ready.
        ref.then((DocumentSnapshot doc) {
          print('Loaded from firestore');
          FusedUserProfile profile = new FusedUserProfile();
          profile.fromJSON(doc.data);
          user.profile = profile;
          SqlData.instance
              .updateElement(SqlData.PROFILE_TABLE, doc.documentID, data);
        });
      }
      print('loaded from firestore $data');
    }
    if (data != null) {
      FusedUserProfile profile = new FusedUserProfile();
      profile.fromJSON(data);
      user.profile = profile;
    }
    _currentUser = user;
    return user;
  }

  // User profile
  Future<void> setNotificationToken(String token) async {
    if (_currentUser != null) {
      Map<String, bool> data = {};
      data["${FusedUserProfile.TOKENS}.$token"] = true;
      Firestore.instance
          .collection(USER_DATA_COLLECTION)
          .document(_currentUser.uid)
          .updateData(data);
    } else {
      _token = token;
    }
  }

  // Returns the current user without a future.
  UserData currentUserNoWait() {
    return _currentUser;
  }

  // User profile
  Future<void> deleteNotificationToken() async {
    if (_currentUser != null) {
      Map<String, bool> data = {};
      data[FusedUserProfile.TOKENS + "." + _token] = false;
      Firestore.instance
          .collection(USER_DATA_COLLECTION)
          .document(_currentUser.uid)
          .updateData(data);
    }
  }
}
