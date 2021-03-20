import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Shows the verify email form.
///
class VerifyEmailScreen extends StatefulWidget {
  /// COnstructor.
  VerifyEmailScreen({Key key}) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  bool autovalidate = false;

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() {
    BlocProvider.of<AuthenticationBloc>(context)
        .add(AuthenticationResendEmail());
  }

  void _onLogout(BuildContext context) async {
    BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationLogOut());
    // Now navigate back to the login screen.
    await Navigator.pushNamed(context, '/Login/Home');
  }

  void _onSignup(BuildContext context) async {
    BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationLogOut());
    // Now navigate back to the signup screen.
    await Navigator.pushNamed(context, '/Login/SignUp');
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    // Reload the user when the page loads.
    //UserDatabaseData.instance.userAuth.reloadUser();

    var screenSize = MediaQuery.of(context).size;
    var width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    var height = screenSize.height / 4 + 20;
    if (width > height) {
      width = height;
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: BlocConsumer(
          bloc: BlocProvider.of<AuthenticationBloc>(context),
          listener: (context, state) {
            if (state is AuthenticationDone) {
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(Messages.of(context).verifyemailsent),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                            MaterialLocalizations.of(context).okButtonLabel))
                  ],
                ),
              ).then((res) {
                Navigator.pushNamed(context, '/');
              });
            } else if (state is AuthenticationFailed) {
              showInSnackBar(Messages.of(context).verifyemailerror);
            } else if (!(state is AuthenticationLoggedInUnverified)) {
              Navigator.popAndPushNamed(context, '/Login/Home');
            }
          },
          builder: (context, state) {
            if (state is AuthenticationLoggedInUnverified) {
              return Container(
                padding: EdgeInsets.all(16.0),
                //decoration: BoxDecoration(image: backgroundImage),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Show a circle avatar just to make it clear that
                          // this is signed in page.
                          Center(
                            child: CircleAvatar(
                              radius: width / 2,
                              child: Text(state.user.profile?.initials() ??
                                  Messages.of(context).unknown),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(messages.verifyExplanation(state.user.email)),
                          Container(
                            margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: RaisedButton(
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              key: Key('SUBMIT'),
                              onPressed: _handleSubmitted,
                              child: Text(messages.resendverify),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          textColor: Theme.of(context).accentColor,
                          key: Key('CREATEACCOUNT'),
                          onPressed: () => _onSignup(context),
                          child: Text(messages.createaccount),
                        ),
                        FlatButton(
                          textColor: Theme.of(context).accentColor,
                          key: Key('LOGOUT'),
                          onPressed: () => _onLogout(context),
                          child: Text(messages.logout),
                        ),
                      ],
                    )
                  ],
                ),
              );
            } else {
              return Text(Messages.of(context).loading);
            }
          },
        ),
      ),
    );
  }
}
