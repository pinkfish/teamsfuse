import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/screens/login/verifyemail.dart';
import 'loginform.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static UserData currentUser;
  static bool loaded = false;
  static bool loadOnMounted = false;
  StreamSubscription<UserData> _stream;

  SplashScreenState() {
    _startLoading();
  }

  void initState() {
    _startLoading();
    super.initState();
    _stream = UserAuth.instance.onAuthChanged().listen(_onAuthStateChanged);
  }

  void dispose() {
    super.dispose();
    _stream?.cancel();
    _stream = null;
  }

  void _onAuthStateChanged(UserData data) {
    if (data != null) {
      if (currentUser != null) {
        // Nothing changed...
        if (currentUser.uid == data.uid &&
            currentUser.isEmailVerified == data.isEmailVerified) {
          return;
        }
      }
      setState(() => currentUser = data);
    } else if (currentUser != null) {
      // Logged out.
      setState(() => currentUser = data);
    }
  }

  Future<Null> _startLoading() async {
    print('Loading...');
    if (!loaded) {
      currentUser = await UserAuth.instance.currentUser();
    }
    print('Got current user $currentUser');
    setState(() {
      loaded = true;
    });
  }

  Widget _loadingScreen() {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        //decoration: new BoxDecoration(image: backgroundImage),
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                      child: new Image(
                    image:
                        new ExactAssetImage("assets/images/abstractsport.png"),
                    width: (screenSize.width < 500)
                        ? 120.0
                        : (screenSize.width / 4) + 12.0,
                    height: screenSize.height / 4 + 20,
                  ))
                ],
              ),
            ),
            new Container(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(),
                  new Text(Messages.of(context).loading),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return _loadingScreen();
    }
    if (currentUser != null && currentUser.isEmailVerified) {
      return new HomeScreen();
    }
    if (currentUser != null) {
      return new VerifyEmailScreen();
    }
    return new LoginScreen();
  }
}
