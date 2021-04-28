import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

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
                        ExactAssetImage('assets/images/hands_and_trophy.png'),
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
      Timer(Duration(milliseconds: 1), () async {
        final analytics =
            RepositoryProvider.of<AnalyticsSubsystemImpl>(context);
        await analytics.firebase.setUserId(state.user.uid);
        if (analytics.debugMode) {
          await analytics.firebase
              .setUserProperty(name: 'developer', value: 'true');
        } else {
          await analytics.firebase
              .setUserProperty(name: 'developer', value: 'false');
        }

        final links = RepositoryProvider.of<FirebaseDynamicLinks>(context);
        final data = await links.getInitialLink();
        final deepLink = data?.link;
        Navigator.popUntil(context, (route) => route.isFirst);
        final delayed = [Navigator.pushNamed(context, '/Main/Home')];
        if (deepLink != null) {
          var myPath = deepLink.path;
          if (!myPath.startsWith('/')) {
            myPath = '/' + myPath;
          }
          delayed.add(Navigator.pushNamed(context, myPath));
        }
        await Future.wait(delayed);
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
      bloc: _authenticationBloc,
      builder: (context, state) {
        _checkState(context, state);
        return _loadingScreen(context);
      },
    );
  }
}
