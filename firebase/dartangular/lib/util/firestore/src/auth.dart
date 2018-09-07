part of firestore_web;

class Auth extends wfs.AuthWrapper {
  @override
  Stream<wfs.FirebaseUserWrapper> get onAuthStateChanged {
    return fb.auth().onAuthStateChanged.transform(new UserTransformer());
  }

  @override
  Future<Function> signOut() {
    return fb.auth().signOut();
  }

  @override
  Future<Function> sendPasswordResetEmail({String email}) {
    return fb.auth().sendPasswordResetEmail(email);
  }

  @override
  Future<wfs.FirebaseUserWrapper> currentUser() async {
    fb.User user = fb.auth().currentUser;
    return new FirebaseUser(user);
  }

  @override
  Future<wfs.FirebaseUserWrapper> signInWithEmailAndPassword(
      {String email, String password}) async {
    fb.User user = await fb.auth().signInWithEmailAndPassword(email, password);
    return new FirebaseUser(user);
  }

  @override
  Future<wfs.FirebaseUserWrapper> createUserWithEmailAndPassword(
      {String email, String password}) async {
    fb.User user =
        await fb.auth().createUserWithEmailAndPassword(email, password);
    return new FirebaseUser(user);
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
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  /**
   * Transformation
   */

  void onData(fb.User data) {
    _controller.add(new FirebaseUser(data));
  }

  /**
   * Bind
   */
  Stream<wfs.FirebaseUserWrapper> bind(Stream<fb.User> stream) {
    this._stream = stream;
    return _controller.stream;
  }
}