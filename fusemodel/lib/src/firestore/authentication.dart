import 'dart:async';

import 'package:fusemodel/fusemodel.dart';

import 'firestore.dart';

///
/// Wrapped around the uaerdata into the firestore stuff.
///
class UserData {
  final String email;
  final String uid;
  final String password;
  final bool isEmailVerified;
  FusedUserProfile profile;

  UserData(
      {this.profile,
      this.email,
      this.uid,
      this.password,
      this.isEmailVerified});

  UserData.copy(UserData copy)
      : email = copy.email,
        uid = copy.uid,
        password = copy.password,
        isEmailVerified = copy.isEmailVerified,
        profile = copy.profile;

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
      print('onAuthStateChanged $input');
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
      print('end onAuthStateChanged $input');
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
      UserData newData = new UserData(
          profile: profile, email: userData.email, isEmailVerified: false);
      user.sendEmailVerification();
      DocumentReferenceWrapper ref =
          wrapper.collection(USER_DATA_COLLECTION).document(user.uid);
      return ref.setData(profile.toJSON()).then((void data) async {
        // With update uid.
        // Create a 'me' user.
        PlayerBuilder player = new PlayerBuilder();
        player.name = userData.profile.displayName;
        PlayerUserBuilder playerUser = new PlayerUserBuilder();
        playerUser.userUid = user.uid;
        playerUser.relationship = Relationship.Me;
        player.users[user.uid] = playerUser.build();
        wrapper
            .collection(PLAYERS_COLLECTION)
            .add(player.build().toJSON(includeUsers: true));
        await signIn(userData);
        return newData;
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
    return wrapper.auth.signOut().then((void a) {
      _profileUpdates?.cancel();
      _profileUpdates = null;
    });
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
          FusedUserProfile.fromJSON(ref.documentID, ref.data).build();
      return profile;
    }
    return null;
  }

  void _onProfileUpdates(DocumentSnapshotWrapper doc) {
    if (doc.exists) {
      persistenData.updateElement(
          PersistenData.profileTable, doc.documentID, doc.data);
      FusedUserProfile profile =
          FusedUserProfile.fromJSON(doc.documentID, doc.data).build();
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
    UserData user = new UserData(
        email: input.email,
        uid: input.uid,
        isEmailVerified: input.isEmailVerified);
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
              FusedUserProfile.fromJSON(doc.documentID, doc.data).build();
          user.profile = profile;
          persistenData.updateElement(
              PersistenData.profileTable, doc.documentID, data);
        });
      }
    }
    if (data != null) {
      FusedUserProfile profile =
          FusedUserProfile.fromJSON(input.uid, data).build();
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
