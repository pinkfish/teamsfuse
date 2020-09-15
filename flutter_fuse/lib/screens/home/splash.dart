import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';

///
/// Shows a splash screen with a 'loading' message on it.
///
class SplashScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(child: new Text(Messages.of(context).loading)),
    );
  }
}
