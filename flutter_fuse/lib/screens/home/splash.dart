import 'package:flutter/material.dart';

import '../../services/messages.dart';

///
/// Shows a splash screen with a 'loading' message on it.
///
class SplashScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(Messages.of(context).loading)),
    );
  }
}
