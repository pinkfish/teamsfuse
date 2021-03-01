import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

import '../../services/analytics.dart';
import '../../services/messages.dart';
import '../../services/notifications.dart';

///
/// The splash screen to show when logging into the program.
///
class SplashScreen extends StatelessWidget {
  Widget _loadingScreen(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        //decoration: BoxDecoration(image: backgroundImage),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Image(
                    image:
                        ExactAssetImage("assets/images/hands_and_trophy.png"),
                    width: (screenSize.width < 500)
                        ? 120.0
                        : (screenSize.width / 4) + 12.0,
                    height: screenSize.height / 4 + 20,
                  ))
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text(Messages.of(context).loading),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Check the state and navigate after a timeout.
  void _checkState(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationLoggedIn) {
      Timer(Duration(milliseconds: 1), () {
        RepositoryProvider.of<Notifications>(context).initForNotification();
        Navigator.pushNamedAndRemoveUntil(
            context, '/Main/Home', ModalRoute.withName('/Main/Home'));
        AnalyticsSubsystemImpl.analytics.setUserId(state.user.uid);
        if (AnalyticsSubsystemImpl.instance.debugMode) {
          AnalyticsSubsystemImpl.analytics
              .setUserProperty(name: "developer", value: "true");
        } else {
          AnalyticsSubsystemImpl.analytics
              .setUserProperty(name: "developer", value: "false");
        }
      });
    }
    if (state is AuthenticationLoggedInUnverified) {
      Timer(Duration(milliseconds: 1), () {
        // Navigate to the login screen at this point.
        Navigator.pushNamedAndRemoveUntil(
            context, '/Login/Verify', ModalRoute.withName('/Login/Home'));
      });
    }

    if (state is AuthenticationLoggedOut) {
      Timer(Duration(milliseconds: 1), () {
        // Navigate to the login screen at this point.
        Navigator.pushNamedAndRemoveUntil(
            context, '/Login/Home', ModalRoute.withName('/Login/Home'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    return BlocBuilder(
      cubit: _authenticationBloc,
      builder: (context, state) {
        _checkState(context, state);
        return _loadingScreen(context);
      },
    );
  }
}
