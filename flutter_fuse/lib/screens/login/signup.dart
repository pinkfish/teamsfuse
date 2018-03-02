import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/authentication.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  SignupScreenState createState() => new SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  BuildContext context;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey = new GlobalKey<FormFieldState<String>>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  Validations validations = new Validations();
  UserData person = new UserData();

  _onPressed() {
    print("button clicked");
  }

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
      Navigator.pushNamed(context, "/HomePage");
    }
  }

  String _validatePassword(String value) {
    final FormFieldState<String> passwordField = _passwordFieldKey.currentState;
    if (passwordField.value == null || passwordField.value.isEmpty)
      return 'Please choose a password.';
    if (passwordField.value != value)
      return 'Passwords don\'t match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final Size screenSize = MediaQuery.of(context).size;
    //print(context.widget.toString());
    Validations validations = new Validations();
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
                              image: new ExactAssetImage("assets/images/abstractsport.png"),
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
                                    icon: const Icon(Icons.account_box),
                                    hintText: 'Name',
                                    labelText: 'Name',
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                  validator: validations.validateName,
                                  onSaved: (String value) { person.displayName = value; }
                              ),
                              new TextFormField(
                                  decoration: const InputDecoration(
                                    icon: const Icon(Icons.email),
                                    hintText: 'Your email address',
                                    labelText: 'E-mail',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: false,
                                  validator: validations.validateEmail,
                                  onSaved: (String value) { person.email = value; }
                              ),
                              new TextFormField(
                                  decoration: const InputDecoration(
                                    icon: const Icon(Icons.phone),
                                    hintText: 'Phone Number (optional)',
                                    labelText: 'Phone number',
                                  ),
                                  keyboardType: TextInputType.phone,
                                  obscureText: false,
                                  validator: validations.validatePhone,
                                  onSaved: (String value) { person.phoneNumber = value; }
                              ),
                              new TextFormField(
                                  decoration: const InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: 'Password',
                                    labelText: 'Password',
                                  ),
                                  obscureText: true,
                                  key: _passwordFieldKey,
                                  onSaved: (String password) {
                                    person.password = password;
                                  }),
                              new TextFormField(
                                  decoration: const InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: 'Verify Password',
                                    labelText: 'Verify Password',
                                  ),
                                  obscureText: true,
                                  validator: _validatePassword,
                                  onSaved: (String password) {
                                    person.password = password;
                                  }),
                              new Container(
                                child: new RaisedButton(
                                    child: const Text("Create"),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: _handleSubmitted
                                ),
                                margin: new EdgeInsets.only(top: 20.0, bottom: 20.0),
                              ),
                            ],
                          ),
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new FlatButton(
                              child: const Text("Login"),
                              textColor: Theme.of(context).accentColor,
                              onPressed: () => onPressed("/"),
                            ),
                            new FlatButton(
                                child: const Text("Forgot Password"),
                                textColor: Theme.of(context).accentColor,
                                onPressed: () => onPressed("/ForgotPassword")),
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