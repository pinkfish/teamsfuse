import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/screens/home/home.dart';
import 'package:flutter_fuse/screens/login/verifyemail.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/notifications.dart';
import 'package:fusemodel/blocs.dart';

class SplashScreen extends StatelessWidget {
  Widget _loadingScreen(BuildContext context) {
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
    AuthenticationBloc _authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return BlocBuilder<AuthenticationEvent, AuthenticationState>(
      bloc: _authenticationBloc,
      builder: (BuildContext context, AuthenticationState state) {
        if (state is AuthenticationUninitialized ||
            state is AuthenticationLoading) {
          return _loadingScreen(context);
        }
        if (state is AuthenticationLoggedIn) {
          Notifications.instance.initForNotification();
          Navigator.pushNamedAndRemoveUntil(
              context, '/Home', ModalRoute.withName('/Home'));
          Analytics.analytics.setUserId(state.user.uid);
          if (Analytics.instance.debugMode) {
            Analytics.analytics
                .setUserProperty(name: "developer", value: "true");
          } else {
            Analytics.analytics
                .setUserProperty(name: "developer", value: "false");
          }
          return new HomeScreen();
        }
        if (state is AuthenticationLoggedInUnverified) {
          return new VerifyEmailScreen();
        }
        if (state is AuthenticationLoggedOut) {
          // Navigate to the login screen at this point.
          Navigator.pushNamedAndRemoveUntil(
              context, '/Home/Login', ModalRoute.withName('/Home/Login'));
          return _loadingScreen(context);
        }
      },
    );
  }
}
