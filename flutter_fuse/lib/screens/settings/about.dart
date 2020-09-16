import 'package:flutter/material.dart';

import '../../services/analytics.dart';
import '../../services/messages.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AboutDialog(
      applicationName: Messages.of(context).title,
      applicationVersion: Analytics.instance.getVersion(),
      applicationIcon: Image(
        image: ExactAssetImage("assets/images/abstractsport.png"),
        width: (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        height: screenSize.height / 4 + 20,
      ),
    );
  }
}
