import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fuse/services/sqldata.dart';

class UserProfile {
  String displayName;
  String email;
  String phoneNumber;

  UserProfile({this.displayName, this.email, this.phoneNumber});

  UserProfile.copy(UserProfile copy) {
    this.displayName = copy.displayName;
    this.email = copy.email;
    this.phoneNumber = copy.phoneNumber;
  }

  static const String _NAME = "name";
  static const String _EMAIL = "email";
  static const String _PHONE = "phone";

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> ret = new Map<String, dynamic>();
    ret[_NAME] = displayName;
    ret[_EMAIL] = email;
    ret[_PHONE] = phoneNumber;
    return ret;
  }

  void fromJSON(Map<String, dynamic> data) {
    displayName = data[_NAME];
    email = data[_EMAIL];
    phoneNumber = data[_PHONE];
  }
}

class UserData {
  String _email;
  String uid;
  String password;
  bool isEmailVerified;
  UserProfile profile;

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
    this.profile = new UserProfile.copy(copy.profile);
    this.email = copy.email;
    this.uid = copy.uid;
    this.password = copy.password;
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class UserAuth {
  static UserAuth instance = new UserAuth();
  UserData _currentUser;
  StreamController<UserData> _controller = new StreamController<UserData>();
  Stream<UserData> _stream;
  StreamSubscription<DocumentSnapshot> _profileUpdates;

  UserAuth() {
    _auth.onAuthStateChanged.listen((FirebaseUser input) async {
      print('onAuthStateChanged');
      print(input);
      if (_profileUpdates != null) {
        _profileUpdates.cancel();
        _profileUpdates = null;
      }
      if (input == null) {
        _controller.add(null);
      } else {
        _controller.add(await _userDataFromFirestore(input, true));
        DocumentReference ref =
            Firestore.instance.collection("UserData").document(input.uid);
        _profileUpdates = ref.snapshots.listen(this._onProfileUpdates);
      }
    });
  }

  // To create new User
  FutureOr<FirebaseUser> createUser(UserData userData) {
    return _auth
        .createUserWithEmailAndPassword(
            email: userData.email, password: userData.password)
        .then((FirebaseUser user) {
      DocumentReference ref =
          Firestore.instance.collection("UserData").document(user.uid);
      ref.updateData(userData.profile.toJSON());
    });
  }

  // To verify new User
  Future<FirebaseUser> signIn(UserData userData) {
    print(userData);
    return _auth.signInWithEmailAndPassword(
        email: userData.email, password: userData.password);
  }

  //To verify new User
  Future<bool> sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  //To verify new User
  Future<bool> signOut() async {
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
    FirebaseUser fbUser = await _auth.currentUser();
    if (fbUser != null) {
      print('Loading from firestore');
      UserData user = await _userDataFromFirestore(fbUser, false);
      print('Loaded!');
      if (_profileUpdates == null) {
        DocumentReference ref =
            Firestore.instance.collection("UserData").document(user.uid);
        _profileUpdates = ref.snapshots.listen(this._onProfileUpdates);
      }
      return user;
    }
    return null;
  }

  UserData cachedCurrentUser() {
    return _currentUser;
  }

  Future<void> updateProfile(UserData user) async {
    DocumentReference ref =
        Firestore.instance.collection("UserData").document(user.uid);
    await ref.updateData(user.profile.toJSON());
  }

  Future<UserProfile> getProfile(String userId) async {
    DocumentSnapshot ref =
        await Firestore.instance.collection("UserData").document(userId).get();
    if (ref.exists) {
      UserProfile profile = new UserProfile();
      profile.fromJSON(ref.data);
      return profile;
    }
    return null;
  }

  void _onProfileUpdates(DocumentSnapshot doc) {
    if (doc.exists) {
      SqlData.instance
          .updateElement(SqlData.PROFILE_TABLE, doc.documentID, doc.data);
      UserProfile profile = new UserProfile();
      profile.fromJSON(doc.data);
      _currentUser.profile = profile;
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
    if (data == null && forceProfile) {
      print('No sql data');
      Future<DocumentSnapshot> ref =
          Firestore.instance.collection("UserData").document(input.uid).get();
      if (forceProfile) {
        DocumentSnapshot doc = await ref;
        data = doc.data;
      } else {
        // Update when ready.
        ref.then((DocumentSnapshot doc) {
          print('Loaded from firestore');
          UserProfile profile = new UserProfile();
          profile.fromJSON(doc.data);
          user.profile = profile;
          SqlData.instance
              .updateElement(SqlData.PROFILE_TABLE, doc.documentID, data);
        });
      }
      print('loaded from firestore $data');
    }
    if (data != null) {
      UserProfile profile = new UserProfile();
      profile.fromJSON(data);
      user.profile = profile;
    }
    _currentUser = user;
    return user;
  }
}
