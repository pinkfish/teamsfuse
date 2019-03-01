import 'package:flutter/material.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key key}) : super(key: key);

  @override
  VerifyEmailScreenState createState() => new VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() {
    UserDatabaseData.instance.userAuth
        .sendEmailVerification()
        .then((void user) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              content: new Text(Messages.of(context).verifyemailsent),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: new Text(
                        MaterialLocalizations.of(context).okButtonLabel))
              ],
            ),
      );
      Navigator.pushNamed(context, "/");
    }).catchError((Error error) {
      showInSnackBar(Messages.of(context).verifyemailerror);
    });
  }

  void _onLogout(BuildContext context) async {
    await UserDatabaseData.instance.userAuth.signOut();
    // Now navigate back to the login screen.
    Navigator.pushNamed(context, "/Login/Home");
  }

  void _onSignup(BuildContext context) async {
    await UserDatabaseData.instance.userAuth.signOut();
    // Now navigate back to the signup screen.
    Navigator.pushNamed(context, "/Login/SignUp");
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    // Reload the user when the page loads.
    UserDatabaseData.instance.userAuth.reloadUser();

    final Size screenSize = MediaQuery.of(context).size;
    double width =
        (screenSize.width < 500) ? 120.0 : (screenSize.width / 4) + 12.0;
    double height = screenSize.height / 4 + 20;
    if (width > height) {
      width = height;
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new SingleChildScrollView(
        controller: scrollController,
        child: new Container(
          padding: new EdgeInsets.all(16.0),
          //decoration: new BoxDecoration(image: backgroundImage),
          child: new Column(
            children: <Widget>[
              new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Show a circle avatar just to make it clear that this is signed in page.
                    new Center(
                      child: new CircleAvatar(
                        radius: width / 2,
                        child: new Text(UserDatabaseData.instance.userAuth
                                .currentUserNoWait()
                                ?.profile
                                ?.initials() ??
                            Messages.of(context).unknown),
                      ),
                    )
                  ],
                ),
              ),
              new Container(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new FutureBuilder<UserData>(
                      future: UserDatabaseData.instance.userAuth.currentUser(),
                      builder:
                          (BuildContext context, AsyncSnapshot<UserData> data) {
                        if (!data.hasData) {
                          return new Text(messages.loading);
                        }
                        return new Text(
                            messages.verifyexplanation(data.data.email));
                      },
                    ),
                    new Container(
                      child: new RaisedButton(
                          child: new Text(messages.resendverify),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: _handleSubmitted),
                      margin: new EdgeInsets.only(top: 20.0, bottom: 20.0),
                    ),
                  ],
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new FlatButton(
                    child: new Text(messages.createaccount),
                    textColor: Theme.of(context).accentColor,
                    onPressed: () => _onSignup(context),
                  ),
                  new FlatButton(
                    child: new Text(messages.logout),
                    textColor: Theme.of(context).accentColor,
                    onPressed: () => _onLogout(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
