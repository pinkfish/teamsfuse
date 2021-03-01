import 'package:flutter/material.dart';

import '../../services/analytics.dart';
import '../../services/messages.dart';

///
/// Show the about screen for the app.
///
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return AboutDialog(
      applicationName: Messages.of(context).title,
      applicationVersion: AnalyticsSubsystemImpl.instance.getVersion(),
      applicationIcon: Image(
        image: ExactAssetImage("assets/images/hands_and_trophy.png"),
        width: (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0,
        height: screenSize.height / 4 + 20,
      ),
    );
  }
}
