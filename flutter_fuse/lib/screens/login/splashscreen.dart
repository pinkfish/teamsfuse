import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/screens/login/verifyemail.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';

import 'loginform.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  SplashScreenState() {
    _startLoading();
  }

  static UserData currentUser;
  static bool loaded = false;
  static bool loadOnMounted = false;
  StreamSubscription<UserData> _stream;

  @override
  void initState() {
    _startLoading();
    super.initState();
    _stream = UserDatabaseData.instance.userAuth
        .onAuthChanged()
        .listen(_onAuthStateChanged);
    // Setup the notifications listen/sender.
    Notifications.instance.initForNotification(this);
  }

  @override
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
      currentUser = await UserDatabaseData.instance.userAuth.currentUser();
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
      print('Not loaded yet');
      return _loadingScreen();
    }
    if (currentUser != null && currentUser.isEmailVerified) {
      print('Show home screen');
      return new HomeScreen();
    }
    if (currentUser != null) {
      print('Verify user screen');
      return new VerifyEmailScreen();
    }
    print('Login screen');
    return new LoginScreen();
  }
}
