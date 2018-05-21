import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/analytics.dart';

class AboutScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new AboutDialog(
      applicationName: Messages.of(context).title,
      applicationVersion: Analytics.instance.getVersion(),
      applicationIcon: new Image(
        image: new ExactAssetImage("assets/images/abstractsport.png"),
        width: (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        height: screenSize.height / 4 + 20,
      ),
    );
  }
}
