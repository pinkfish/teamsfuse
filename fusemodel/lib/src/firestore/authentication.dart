import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'firestore.dart';

class UserData {
  String _email;
  String uid;
  String password;
  bool isEmailVerified;
  FusedUserProfile profile;

  UserData({this.profile, String email, this.uid, this.password})
      : _email = email;

  UserData.copy(UserData copy) {
    profile = new FusedUserProfile.copy(copy.profile);
    email = copy.email;
    uid = copy.uid;
    password = copy.password;
  }

  set email(String val) {
    if (profile != null) {
      profile = profile.copyWith(email: val);
    }
    _email = val;
  }

  String get email {
    return _email;
  }

  @override
  String toString() {
    return "UserData [$email $password $uid $profile]";
  }
}

class UserAuthImpl {
  FirestoreWrapper wrapper;
  PersistenData persistenData;
  UserData _currentUser;
  FirebaseUserWrapper _currentFirebaseUser;
  StreamController<UserData> _controller = new StreamController<UserData>();
  Stream<UserData> _stream;
  StreamSubscription<DocumentSnapshotWrapper> _profileUpdates;
  String _token;
  StreamSubscription<FirebaseUserWrapper> _updateStream;

  UserAuthImpl(this.wrapper, this.persistenData) {
    _updateStream = wrapper.auth.onAuthStateChanged
        .listen((FirebaseUserWrapper input) async {
      print('onAuthStateChanged');
      if (_profileUpdates != null) {
        _profileUpdates.cancel();
        _profileUpdates = null;
      }
      if (_currentUser != null) {
        // Delete the old token.
        deleteNotificationToken();
      }
      if (input == null || !input.loggedIn) {
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
        DocumentReferenceWrapper ref =
            wrapper.collection(USER_DATA_COLLECTION).document(input.uid);
        _profileUpdates = ref.snapshots().listen(_onProfileUpdates);
      }
    });
  }

  void dispose() {
    _profileUpdates?.cancel();
    _updateStream?.cancel();
  }

  // To create new User
  Future<UserData> createUser(UserData userData, FusedUserProfile profile) {
    return wrapper.auth
        .createUserWithEmailAndPassword(
            email: userData.email, password: userData.password)
        .then((FirebaseUserWrapper user) {
      userData.uid = user.uid;
      user.sendEmailVerification();
      DocumentReferenceWrapper ref =
          wrapper.collection(USER_DATA_COLLECTION).document(user.uid);
      return ref.setData(profile.toJSON()).then((void data) async {
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
    FirebaseUserWrapper user = await wrapper.auth.signInWithEmailAndPassword(
        email: userData.email, password: userData.password);
    print("Got the sign in $user, now returning current user");
    if (user != null && user.loggedIn) {
      print('In here');
      return currentUser();
    }
    print('Throwing exception');
    throw new ArgumentError("Invalud login");
  }

  // To reset the password.
  Future<void> sendPasswordResetEmail(String email) async {
    return wrapper.auth.sendPasswordResetEmail(email: email);
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
    return wrapper.auth.signOut();
  }

  Stream<UserData> onAuthChanged() {
    if (_stream == null) {
      _stream = _controller.stream.asBroadcastStream();
    }
    return _stream;
  }

  Future<UserData> currentUser() async {
    if (_currentUser == null) {
      FirebaseUserWrapper fbUser = await wrapper.auth.currentUser();
      if (fbUser != null && fbUser.loggedIn) {
        _currentFirebaseUser = fbUser;
        UserData user = await _userDataFromFirestore(fbUser, false);
        if (_profileUpdates == null) {
          DocumentReferenceWrapper ref =
              wrapper.collection(USER_DATA_COLLECTION).document(user.uid);
          _profileUpdates = ref.snapshots().listen(_onProfileUpdates);
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

  Future<void> updateProfile(String uid, FusedUserProfile profile) async {
    DocumentReferenceWrapper ref =
        wrapper.collection(USER_DATA_COLLECTION).document(uid);
    await ref.updateData(profile.toJSON());
  }

  Future<FusedUserProfile> getProfile(String userId) async {
    print("Looking for $userId");
    DocumentSnapshotWrapper ref =
        await wrapper.collection(USER_DATA_COLLECTION).document(userId).get();
    print("Found $userId ${ref.data}");
    if (ref.exists) {
      FusedUserProfile profile =
          new FusedUserProfile.fromJSON(ref.documentID, ref.data);
      return profile;
    }
    return null;
  }

  void _onProfileUpdates(DocumentSnapshotWrapper doc) {
    if (doc.exists) {
      persistenData.updateElement(
          PersistenData.profileTable, doc.documentID, doc.data);
      FusedUserProfile profile =
          new FusedUserProfile.fromJSON(doc.documentID, doc.data);
      _currentUser.profile = profile;
      _controller.add(_currentUser);
    }
  }

  Future<UserData> _userDataFromFirestore(
      FirebaseUserWrapper input, bool forceProfile) async {
    // Read from sql for the profile details first, assume the snap
    // shot listener will catch the actual firebase stuff when
    // it exists.
    Map<String, dynamic> data =
        await persistenData.getElement(PersistenData.profileTable, input.uid);
    UserData user = new UserData();
    user.email = input.email;
    user.uid = input.uid;
    user.isEmailVerified = input.isEmailVerified;
    _currentFirebaseUser = input;
    if (data == null && forceProfile) {
      Future<DocumentSnapshotWrapper> ref =
          wrapper.collection(USER_DATA_COLLECTION).document(input.uid).get();
      if (forceProfile) {
        DocumentSnapshotWrapper doc = await ref;
        data = doc.data;
      } else {
        // Update when ready.
        ref.then((DocumentSnapshotWrapper doc) {
          print('Loaded from firestore');
          FusedUserProfile profile =
              new FusedUserProfile.fromJSON(doc.documentID, doc.data);
          user.profile = profile;
          persistenData.updateElement(
              PersistenData.profileTable, doc.documentID, data);
        });
      }
    }
    if (data != null) {
      FusedUserProfile profile = new FusedUserProfile.fromJSON(input.uid, data);
      user.profile = profile;
    }
    _currentUser = user;
    return user;
  }

  // User profile
  Future<void> setNotificationToken(String token) async {
    if (_currentUser != null) {
      Map<String, bool> data = <String, bool>{};
      String key = "${FusedUserProfile.TOKENS}.$token";
      if (!data.containsKey(key) || !data[key]) {
        data[key] = true;
        wrapper
            .collection(USER_DATA_COLLECTION)
            .document(_currentUser.uid)
            .updateData(data);
      }
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
      Map<String, bool> data = <String, bool>{};
      String key = "${FusedUserProfile.TOKENS}.$_token";
      if (data.containsKey(key) && data[key]) {
        data[key] = false;
        wrapper
            .collection(USER_DATA_COLLECTION)
            .document(_currentUser.uid)
            .updateData(data);
      }
    }
  }
}