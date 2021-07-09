import 'dart:async';

import 'package:fusemodel/fusemodel.dart';

import 'firestore.dart';
import 'userdata.dart';

///
/// Implementation for user auth in the system.
///
class UserAuthImpl {
  final FirestoreWrapper _wrapper;
  UserData _currentUser;
  FirebaseUserWrapper _currentFirebaseUser;
  final StreamController<UserData> _controller = StreamController<UserData>();
  Stream<UserData> _stream;
  StreamSubscription<DocumentSnapshotWrapper> _profileUpdates;
  String _token;
  StreamSubscription<FirebaseUserWrapper> _updateStream;

  UserAuthImpl(this._wrapper) {
    _updateStream = _wrapper.auth.onAuthStateChanged
        .listen((FirebaseUserWrapper input) async {
      if (_profileUpdates != null) {
        await _profileUpdates.cancel();
        _profileUpdates = null;
      }
      if (_currentUser != null) {
        // Delete the old token.
        await deleteNotificationToken();
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
          await setNotificationToken(_token);
        }
        final ref =
            _wrapper.collection(USER_DATA_COLLECTION).document(input.uid);
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
  Future<UserData> createUser(
      UserData userData, FusedUserProfile profile) async {
    final user = await _wrapper.auth.createUserWithEmailAndPassword(
        email: userData.email, password: userData.password);
    final newData = UserData((b) => b
      ..profile = profile.toBuilder()
      ..email = userData.email
      ..isEmailVerified = false);
    await user.sendEmailVerification();
    final ref = _wrapper.collection(USER_DATA_COLLECTION).document(user.uid);
    await ref.setData(profile.toMap());

    // With update uid.
    // Create a 'me' user.
    final player = PlayerBuilder();
    player.name = userData.profile.displayName;
    final playerUser = PlayerUserInternalBuilder();
    playerUser.relationship = Relationship.Me;
    playerUser.added = true;
    player.usersData[user.uid] = playerUser.build();
    await _wrapper
        .collection(PLAYERS_COLLECTION)
        .add(player.build().toMap(includeUsers: true));
    await signIn(userData);
    return newData;
  }

  // To verify new User
  Future<UserData> signIn(UserData userData) async {
    final user = await _wrapper.auth.signInWithEmailAndPassword(
        email: userData.email, password: userData.password);
    if (user != null && user.loggedIn) {
      return currentUser();
    }
    throw ArgumentError('Invalid login');
  }

  // To reset the password.
  Future<void> sendPasswordResetEmail(String email) async {
    return _wrapper.auth.sendPasswordResetEmail(email: email);
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
    await _userDataFromFirestore(_currentFirebaseUser, false);
  }

  // Sign the user out.
  Future<void> signOut() async {
    return _wrapper.auth.signOut().then((void a) {
      _profileUpdates?.cancel();
      _profileUpdates = null;
    });
  }

  Stream<UserData> onAuthChanged() {
    _stream ??= _controller.stream.asBroadcastStream();
    return _stream;
  }

  Future<UserData> currentUser() async {
    if (_currentUser == null) {
      final fbUser = await _wrapper.auth.currentUser();
      if (fbUser != null && fbUser.loggedIn) {
        _currentFirebaseUser = fbUser;
        final user = await _userDataFromFirestore(fbUser, false);
        if (_profileUpdates == null) {
          final ref =
              _wrapper.collection(USER_DATA_COLLECTION).document(user.uid);
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
    final ref = _wrapper.collection(USER_DATA_COLLECTION).document(uid);
    await ref.updateData(profile.toMap());
  }

  Stream<FusedUserProfile> getProfileStream(String userId) async* {
    final ref = _wrapper.collection(USER_DATA_COLLECTION).document(userId);
    final snap = await ref.get();
    if (snap.exists) {
      final profile = FusedUserProfile.fromMap(snap.data);
      yield profile;
      await for (final snap in ref.snapshots()) {
        yield FusedUserProfile.fromMap(snap.data);
      }
    }
    yield null;
  }

  void _onProfileUpdates(DocumentSnapshotWrapper doc) {
    if (doc.exists) {
      final profile = FusedUserProfile.fromMap(doc.data).toBuilder();
      profile.uid = doc.documentID;
      _currentUser = _currentUser.rebuild((b) => b..profile = profile);
      _controller.add(_currentUser);
    }
  }

  Future<UserData> _userDataFromFirestore(
      FirebaseUserWrapper input, bool forceProfile) async {
    // Read from sql for the profile details first, assume the snap
    // shot listener will catch the actual firebase stuff when
    // it exists.
    FusedUserProfileBuilder userProfile;
    userProfile = FusedUserProfileBuilder();
    userProfile.displayName = input.email.split('@')[0];
    userProfile.email = input.email;
    userProfile.phoneNumber = '';
    userProfile.emailOnUpdates = true;
    userProfile.emailUpcomingGame = true;
    userProfile.notifyOnlyForGames = false;
    userProfile.uid = input.uid;

    var user = UserData((b) => b
      ..email = input.email
      ..uid = input.uid
      ..isEmailVerified = input.isEmailVerified
      ..profile = userProfile);
    _currentFirebaseUser = input;
    if (forceProfile) {
      final ref =
          _wrapper.collection(USER_DATA_COLLECTION).document(input.uid).get();
      if (forceProfile) {
        final doc = await ref;
        final profile = FusedUserProfile.fromMap(doc.data).toBuilder();
        profile.uid = user.uid;
        user = user.rebuild((b) => b..profile = profile);
      } else {
        // Update when ready.
        final doc = await ref;

        var profile = FusedUserProfile.fromMap(doc.data).toBuilder();
        profile.uid = user.uid;
        user = user.rebuild((b) => b..profile = profile);
      }
    }
    _currentUser = user;
    return user;
  }

  // User profile
  Future<void> setNotificationToken(String token) async {
    if (_currentUser != null) {
      final data = <String, bool>{};
      final key = '${FusedUserProfile.TOKENS}.$token';
      if (!data.containsKey(key) || !data[key]) {
        data[key] = true;
        await _wrapper
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
      final data = <String, bool>{};
      final key = '${FusedUserProfile.TOKENS}.$_token';
      if (data.containsKey(key) && data[key]) {
        data[key] = false;
        await _wrapper
            .collection(USER_DATA_COLLECTION)
            .document(_currentUser.uid)
            .updateData(data);
      }
    }
  }
}
