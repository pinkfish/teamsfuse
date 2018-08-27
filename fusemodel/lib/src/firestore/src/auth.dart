part of firestore_wrapper;

abstract class AuthWrapper {
  Stream<FirebaseUserWrapper> get onAuthStateChanged;

  Future<FirebaseUserWrapper> createUserWithEmailAndPassword(
      {String email, String password});
  Future<FirebaseUserWrapper> signInWithEmailAndPassword(
      {String email, String password});
  Future<FirebaseUserWrapper> currentUser();
  Future<void> sendPasswordResetEmail({String email});
  Future<void> signOut();
}

abstract class FirebaseUserWrapper {
  FirebaseUserWrapper(
      {this.email, this.uid, this.isEmailVerified, this.loggedIn});
  String email;
  String uid;
  bool isEmailVerified;
  bool loggedIn;

  Future<void> sendEmailVerification();
  Future<void> reload();
}
