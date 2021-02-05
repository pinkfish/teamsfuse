part of firestore_mobile;

///
/// Auth wrapper to make auth easier to use for the app.
///
class Auth extends wfs.AuthWrapper {
  @override
  Stream<wfs.FirebaseUserWrapper> get onAuthStateChanged {
    return fa.FirebaseAuth.instance
        .authStateChanges()
        .transform(_UserTransformer());
  }

  @override
  Future<void> signOut() {
    return fa.FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({String email}) {
    return fa.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  @override
  Future<wfs.FirebaseUserWrapper> currentUser() async {
    var u = fa.FirebaseAuth.instance.currentUser;
    var user = u;
    return FirebaseUser(user);
  }

  @override
  Future<wfs.FirebaseUserWrapper> signInWithEmailAndPassword(
      {String email, String password}) async {
    var user = await fa.FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return FirebaseUser(user.user);
  }

  @override
  Future<wfs.FirebaseUserWrapper> createUserWithEmailAndPassword(
      {String email, String password}) async {
    var user = await fa.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return FirebaseUser(user.user);
  }
}

///
/// Firebase user wrapper for use in the app.
///
class FirebaseUser extends wfs.FirebaseUserWrapper {
  /// Constrctor for the wrapper, takes a firebase user as input.
  FirebaseUser(this._user)
      : super(
            email: _user?.email,
            isEmailVerified: _user?.emailVerified,
            uid: _user?.uid,
            loggedIn: _user != null);

  final fa.User _user;

  @override
  Future<void> reload() {
    return _user.reload();
  }

  @override
  Future<void> sendEmailVerification() {
    return _user.sendEmailVerification();
  }
}

class _UserTransformer
    extends StreamTransformerBase<fa.User, wfs.FirebaseUserWrapper> {
  _UserTransformer() {
    _controller = StreamController<wfs.FirebaseUserWrapper>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        });
  }

  StreamController<wfs.FirebaseUserWrapper> _controller;

  StreamSubscription<fa.User> _subscription;

  // Original Stream
  Stream<fa.User> _stream;

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  ///
  /// Transformation
  ///

  void onData(fa.User data) {
    _controller.add(FirebaseUser(data));
  }

  ///
  ///Bind
  ///
  @override
  Stream<wfs.FirebaseUserWrapper> bind(Stream<fa.User> stream) {
    _stream = stream;
    return _controller.stream;
  }
}
