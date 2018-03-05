import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';

class SplashScreen extends StatelessWidget {
  _onPressed(BuildContext context) {
    Navigator.popAndPushNamed(context, "EditGame/add");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return
      new Scaffold(
        body: new Center(
            child: new Text('Loading')
        ),
      );
  }
}

