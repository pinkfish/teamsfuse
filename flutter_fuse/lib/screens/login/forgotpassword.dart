import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/authentication.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key key}) : super(key: key);

  @override
  ForgotPasswordScreenState createState() => new ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  BuildContext context;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  Validations validations = new Validations();
  String email = '';

  onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() {
    final FormState form = formKey.currentState;
    if (!form.validate()) {
      autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      UserAuth.instance.sendPasswordResetEmail(email).then((void nothing) {
        // Show a dialog saying we sent the email.
        Navigator.pushNamed(context, "/Login/Home");
      }).catchError((error) {
        showInSnackBar(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final Size screenSize = MediaQuery.of(context).size;
    return new Scaffold(
        key: _scaffoldKey,
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
                        new Center(
                            child: new Image(
                          image: new ExactAssetImage(
                              "assets/images/abstractsport.png"),
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
                        new Form(
                          key: formKey,
                          autovalidate: autovalidate,
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                  decoration: const InputDecoration(
                                    icon: const Icon(Icons.email),
                                    hintText: 'Your email address',
                                    labelText: 'E-mail',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: false,
                                  onSaved: (String value) {
                                    email = value;
                                  }),
                              new Container(
                                child: new RaisedButton(
                                    child: const Text("Forgot Password"),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: _handleSubmitted),
                                margin: new EdgeInsets.only(
                                    top: 20.0, bottom: 20.0),
                              ),
                            ],
                          ),
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new FlatButton(
                              child: const Text("Create Account"),
                              textColor: Theme.of(context).accentColor,
                              onPressed: () => onPressed("/Login/SignUp"),
                            ),
                            new FlatButton(
                                child: const Text("Login"),
                                textColor: Theme.of(context).accentColor,
                                onPressed: () => onPressed("/")),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
