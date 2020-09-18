import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../screens/home/home.dart';
import '../../screens/login/verifyemail.dart';
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
                    image: ExactAssetImage("assets/images/abstractsport.png"),
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

  @override
  Widget build(BuildContext context) {
    var _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    return BlocListener(
      cubit: _authenticationBloc,
      listener: (context, state) {
        if (state is AuthenticationLoggedIn) {
          RepositoryProvider.of<Notifications>(context).initForNotification();
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
        }
        if (state is AuthenticationLoggedOut) {
          // Navigate to the login screen at this point.
          Navigator.pushNamedAndRemoveUntil(
              context, '/Login/Home', ModalRoute.withName('/Login/Home'));
        }
      },
      child: BlocBuilder(
        cubit: _authenticationBloc,
        builder: (context, state) {
          if (state is AuthenticationUninitialized ||
              state is AuthenticationLoading) {
            return _loadingScreen(context);
          }
          if (state is AuthenticationLoggedIn) {
            return HomeScreen();
          }
          if (state is AuthenticationLoggedInUnverified) {
            return VerifyEmailScreen();
          }
          if (state is AuthenticationLoggedOut) {
            return _loadingScreen(context);
          }
          return Text(Messages.of(context).unknown);
        },
      ),
    );
  }
}
