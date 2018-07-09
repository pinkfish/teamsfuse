part of firestore_mobile;

class Auth extends wfs.AuthWrapper {
  @override
  Stream<wfs.FirebaseUserWrapper> get onAuthStateChanged {
    return fa.FirebaseAuth.instance.onAuthStateChanged
        .transform(new UserTransformer());
  }

  @override
  Future<Function> signOut() {}

  @override
  Future<Function> sendPasswordResetEmail({String email}) {}

  @override
  Future<wfs.FirebaseUserWrapper> currentUser() {}

  @override
  Future<wfs.FirebaseUserWrapper> signInWithEmailAndPassword(
      {String email, String password}) {}

  @override
  Future<wfs.FirebaseUserWrapper> createUserWithEmailAndPassword(
      {String email, String password}) {}
}

class FirebaseUser extends wfs.FirebaseUserWrapper {
  fa.FirebaseUser _user;

  FirebaseUser(this._user)
      : super(
            email: _user.email,
            isEmailVerified: _user.isEmailVerified,
            uid: _user.uid);

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
    extends StreamTransformerBase<fa.FirebaseUser, wfs.FirebaseUserWrapper> {
  StreamController<wfs.FirebaseUserWrapper> _controller;

  StreamSubscription _subscription;

  // Original Stream
  Stream<fa.FirebaseUser> _stream;

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

  void onData(fa.FirebaseUser data) {
    _controller.add(new FirebaseUser(data));
  }

  /**
   * Bind
   */
  Stream<wfs.FirebaseUserWrapper> bind(Stream<fa.FirebaseUser> stream) {
    this._stream = stream;
    return _controller.stream;
  }
}