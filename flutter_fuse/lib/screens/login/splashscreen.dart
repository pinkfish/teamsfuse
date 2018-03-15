import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'dart:async';
import 'loginform.dart';
import 'package:flutter_fuse/screens/home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static UserData currentUser;
  static bool loaded = false;
  static bool loadOnMounted = false;

  SplashScreenState() {
    _startLoading();
  }

  void initState() {
    super.initState();

    _startLoading();
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

    return new Container(
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
                  image: new ExactAssetImage("assets/images/abstractsport.png"),
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
                new Text('Loading...'),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return _loadingScreen();
      /*
      return new FutureBuilder<Null>(
          future: this._startLoading(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (loaded) {
                  if (currentUser != null && currentUser.isEmailVerified) {
                    return new HomeScreen();
                  }
                  return new LoginScreen();
                }
                return _loadingScreen();
              case ConnectionState.waiting:
              case ConnectionState.none:
              case ConnectionState.active:
                return _loadingScreen();
            }
          }
      );
      */
    }
    if (currentUser != null && currentUser.isEmailVerified) {
      return new HomeScreen();
    }
    return new LoginScreen();
  }
}
