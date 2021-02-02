part of firestore_web;

class Auth extends wfs.AuthWrapper {
  @override
  Stream<wfs.FirebaseUserWrapper> get onAuthStateChanged {
    return fb.auth().onAuthStateChanged.transform(new UserTransformer());
  }

  @override
  Future<void> signOut() {
    return fb.auth().signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({String email}) async {
    if (email != null) {
      return fb.auth().sendPasswordResetEmail(email);
    }
    return;
  }

  @override
  Future<wfs.FirebaseUserWrapper> currentUser() async {
    fb.User user = fb.auth().currentUser;
    return new FirebaseUser(user);
  }

  @override
  Future<wfs.FirebaseUserWrapper> signInWithEmailAndPassword(
      {String email, String password}) async {
    if (email != null && password != null) {
      fb.UserCredential user =
          await fb.auth().signInWithEmailAndPassword(email, password);
      return new FirebaseUser(user.user);
    }
    throw FormatException("Invalid email and password");
  }

  @override
  Future<wfs.FirebaseUserWrapper> createUserWithEmailAndPassword(
      {String email, String password}) async {
    if (email != null && password != null) {
      fb.UserCredential user =
          await fb.auth().createUserWithEmailAndPassword(email, password);
      return new FirebaseUser(user.user);
    }
    throw FormatException("Invalid email and password");
  }
}

class FirebaseUser extends wfs.FirebaseUserWrapper {
  fb.User _user;

  FirebaseUser(this._user)
      : super(
            email: _user?.email,
            isEmailVerified: _user?.emailVerified,
            uid: _user?.uid,
            loggedIn: _user != null);

  @override
  Future<void> reload() {
    return _user.reload();
  }

  @override
  Future<void> sendEmailVerification() {
    return _user.sendEmailVerification();
  }
}

class UserTransformer
    extends StreamTransformerBase<fb.User, wfs.FirebaseUserWrapper> {
  StreamController<wfs.FirebaseUserWrapper> _controller;

  StreamSubscription _subscription;

  // Original Stream
  Stream<fb.User> _stream;

  UserTransformer() {
    _controller = new StreamController<wfs.FirebaseUserWrapper>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          if (_subscription != null) {
            _subscription?.pause();
          }
        },
        onResume: () {
          if (_subscription != null) {
            _subscription?.resume();
          }
        });
  }

  void _onListen() {
    if (_stream != null) {
      _subscription = _stream?.listen(onData,
          onError: _controller.addError, onDone: _controller.close);
    }
  }

  void _onCancel() {
    if (_subscription != null) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  void onData(fb.User data) {
    _controller.add(new FirebaseUser(data));
  }

  @override
  Stream<wfs.FirebaseUserWrapper> bind(Stream<fb.User> stream) {
    _stream = stream;
    return _controller.stream;
  }
}
