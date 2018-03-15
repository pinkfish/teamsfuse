import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  UserAuth() {
    _auth.onAuthStateChanged.listen((FirebaseUser input) async {
      print('onAuthStateChanged');
      print(input);
      if (input == null) {
        _controller.add(null);
      } else {
        _controller.add(await _userDataFromFirebase(input));
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
    FirebaseUser fbUser = await _auth.currentUser();
    if (fbUser != null) {
      return await _userDataFromFirebase(fbUser);
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

  Future<UserData> _userDataFromFirebase(FirebaseUser input) async {
    UserData user = new UserData();
    user.email = input.email;
    user.uid = input.uid;
    user.isEmailVerified = input.isEmailVerified;
    DocumentSnapshot ref = await Firestore.instance
        .collection("UserData")
        .document(input.uid)
        .get();
    UserProfile profile = new UserProfile();
    profile.fromJSON(ref.data);
    user.profile = profile;
    _currentUser = user;
    return user;
  }
}
