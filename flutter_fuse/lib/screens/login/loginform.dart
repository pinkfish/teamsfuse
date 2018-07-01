import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:fusemodel/firestore.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/analytics.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  Validations validations = new Validations();
  UserData person = new UserData();
  String errorText = '';
  bool _loggingIn = false;

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    print("Showing snack of $value");
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() async {
    print('Submit');
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      print('Validate?');
      autovalidate = true; // Start validating on every change.
      setState(() {
        errorText = Messages.of(context).formerror;
      });
      showInSnackBar(errorText);
    } else {
      setState(() {
        _loggingIn = true;
      });
      // Save the data and login.
      form.save();

      // Login!
      // Remove any spaces at the begining/end.
      person.email = person.email.trim();
      print('Doing login');
      UserDatabaseData.instance.userAuth.signIn(person).then((UserData user) async {
        print('Home page');
        await UserDatabaseData.instance.userAuth.reloadUser();
        print('reloaded user');
        Analytics.analytics.logLogin();
        setState(() {
          _loggingIn = false;
        });
      }).catchError((Error error) {
        print('Right here $error');
        setState(() {
          errorText = "Invaid password or difficulty logging on";
        });
        showInSnackBar(errorText);
        setState(() {
          _loggingIn = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      key: _scaffoldKey,
      body: new SavingOverlay(
        saving: _loggingIn,
        child: new SingleChildScrollView(
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
                      new Center(
                        child: new Image(
                          image: new ExactAssetImage(
                              "assets/images/abstractsport.png"),
                          width: (screenSize.width < 500)
                              ? 120.0
                              : (screenSize.width / 4) + 12.0,
                          height: screenSize.height / 4 + 20,
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Form(
                        key: formKey,
                        autovalidate: autovalidate,
                        child: new Column(
                          children: <Widget>[
                            new Text(errorText),
                            new TextFormField(
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.email),
                                hintText: 'Your email address',
                                labelText: 'E-mail',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              onSaved: (String value) {
                                person.email = value;
                              },
                            ),
                            new TextFormField(
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.lock_open),
                                hintText: 'Password',
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              onSaved: (String password) {
                                person.password = password;
                              },
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        child: new RaisedButton(
                          child: new Text(Messages.of(context).login),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () => _handleSubmitted(),
                        ),
                        margin: new EdgeInsets.only(top: 20.0, bottom: 20.0),
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new FlatButton(
                            child: new Text(Messages.of(context).createaccount),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => onPressed("/Login/SignUp"),
                          ),
                          new FlatButton(
                            child:
                                new Text(Messages.of(context).forgotPassword),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () => onPressed("/Login/ForgotPassword"),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
