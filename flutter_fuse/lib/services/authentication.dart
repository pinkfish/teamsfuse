import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


class UserData {
  String displayName;
  String email;
  String uid;
  String password;
  String phoneNumber;
  String photoUrl;

  UserData({this.displayName, this.email, this.uid, this.password, this.phoneNumber, this.photoUrl});
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class UserAuth {
  // To create new User
  static Future<FirebaseUser> createUser(UserData userData) {
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
  static Future<FirebaseUser> signIn(UserData userData)  {
    return _auth
        .signInWithEmailAndPassword(email: userData.email, password: userData.password);
  }

  //To verify new User
  static Future<bool> sendPasswordResetEmail (String email) async {
    return _auth
        .sendPasswordResetEmail(email: email);
  }
}