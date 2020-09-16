import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

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
  LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _loginBloc.add(LoginEventReload());
  }

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() {
    _loginBloc.add(LoginEventResendEmail());
  }

  void _onLogout(BuildContext context) async {
    _loginBloc.add(LoginEventLogout());
    // Now navigate back to the login screen.
    Navigator.pushNamed(context, "/Login/Home");
  }

  void _onSignup(BuildContext context) async {
    _loginBloc.add(LoginEventLogout());
    // Now navigate back to the signup screen.
    Navigator.pushNamed(context, "/Login/SignUp");
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
        child: BlocListener(
          cubit: _loginBloc,
          listener: (context, state) {
            if (state is LoginVerificationDone) {
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(Messages.of(context).verifyemailsent),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                            MaterialLocalizations.of(context).okButtonLabel))
                  ],
                ),
              ).then((res) {
                Navigator.pushNamed(context, "/");
              });
            } else if (state is LoginVerificationFailed) {
              showInSnackBar(Messages.of(context).verifyemailerror);
            } else if (!(state is LoginEmailNotValidated)) {
              Navigator.popAndPushNamed(context, "/Login/Home");
            }
          },
          child: BlocBuilder(
            cubit: _loginBloc,
            builder: (context, state) {
              if (state is LoginEmailNotValidated) {
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
                            // Show a circle avatar just to make it clear that this is signed in page.
                            Center(
                              child: CircleAvatar(
                                radius: width / 2,
                                child: Text(
                                    state.userData.profile?.initials() ??
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
                            Text(messages
                                .verifyexplanation(state.userData.email)),
                            Container(
                              child: RaisedButton(
                                  child: Text(messages.resendverify),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  onPressed: _handleSubmitted),
                              margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton(
                            child: Text(messages.createaccount),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => _onSignup(context),
                          ),
                          FlatButton(
                            child: Text(messages.logout),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => _onLogout(context),
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
      ),
    );
  }
}
