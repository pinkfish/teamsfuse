import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


class UserData {
  String displayName;
  String email;
  String uid;
  String password;
  String phoneNumber;
  String photoUrl;
  bool isEmailVerified;

  UserData({this.displayName, this.email, this.uid, this.password, this.phoneNumber, this.photoUrl});
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class UserAuth {
  static UserAuth instance = new UserAuth();

  // To create new User
  Future<FirebaseUser> createUser(UserData userData) {
    return _auth.createUserWithEmailAndPassword(
        email: userData.email,
        password: userData.password).then((FirebaseUser) {
          UserUpdateInfo update = new UserUpdateInfo();
          update.displayName = userData.displayName;
          update.photoUrl = userData.photoUrl;
          return _auth.updateProfile(update);
        });
  }

  // To verify new User
  Future<FirebaseUser> signIn(UserData userData)  {
    print(userData);
    return _auth
        .signInWithEmailAndPassword(
        email: userData.email,
        password: userData.password);
  }

  //To verify new User
  Future<bool> sendPasswordResetEmail (String email) async {
    return _auth
        .sendPasswordResetEmail(email: email);
  }

  //To verify new User
  Future<bool> signOut () async {
    return _auth.signOut();
  }

  Stream<UserData> onAuthChanged() {
    StreamController<UserData> controller = new StreamController<UserData>();
    _auth.onAuthStateChanged.listen((input) {
      print('onAuthStateChanged');
      print(input);
      if (input == null) {
        controller.add(null);
      } else {
        controller.add(_userDataFromFirebase(input));
      }
    });
    return controller.stream;
  }

  Future<UserData> currentUser() async {
    FirebaseUser fbUser = await _auth.currentUser();
    if (fbUser != null) {
      return await _userDataFromFirebase(fbUser);
    }
    return null;
  }

  UserData _userDataFromFirebase(FirebaseUser input) {
    UserData user = new UserData();
    user.email = input.email;
    user.displayName = input.displayName;
    user.photoUrl = input.photoUrl;
    user.uid = input.uid;
    user.isEmailVerified = input.isEmailVerified;
    return user;
  }
}