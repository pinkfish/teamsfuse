import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/messages.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  SignupScreenState createState() => new SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  BuildContext context;
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      new GlobalKey<FormFieldState<String>>();
  ScrollController scrollController = new ScrollController();
  bool autovalidate = false;
  Validations validations = new Validations();
  UserData person = new UserData();

 void  _onPressed(String routeName) {
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
      showInSnackBar(Messages.of(context).formerror);
    } else {
      form.save();
      Navigator.pushNamed(context, "/HomePage");
    }
  }

  String _validatePassword(String value) {
   String old = _passwordFieldKey.currentState.value;
   if (value != old) {
     return Messages.of(context).passwordsnotmatching;
   }
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
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.account_box),
                                    hintText: Messages.of(context).displaynamehint,
                                    labelText: Messages.of(context).displayname
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                  validator: (String str) {
                                    return validations.validateName(
                                        context, str);
                                  },
                                  onSaved: (String value) {
                                    person.profile.displayName = value;
                                  }),
                              new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.email),
                                    hintText: Messages.of(context).youremailHint,
                                    labelText: Messages.of(context).email,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: false,
                                  validator: (String str) {
                                    return validations.validateEmail(
                                        context, str);
                                  },
                                  onSaved: (String value) {
                                    person.email = value;
                                  }),
                              new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.phone),
                                    hintText: Messages.of(context).phonenumberhintoptional,
                                    labelText: Messages.of(context).phonenumber,
                                  ),
                                  keyboardType: TextInputType.phone,
                                  obscureText: false,
                                  validator: (String str) {
                                    return validations.validatePhone(
                                        context, str);
                                  },
                                  onSaved: (String value) {
                                    person.profile.phoneNumber = value;
                                  }),
                              new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: Messages.of(context).password,
                                    labelText: Messages.of(context).password,
                                  ),
                                  obscureText: true,
                                  validator: (String str) {
                                    return validations.validatePassword(
                                        context, str);
                                  },
                                  key: _passwordFieldKey,
                                  onSaved: (String password) {
                                    person.password = password;
                                  }),
                              new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: Messages.of(context).verifypassword,
                                    labelText: Messages.of(context).verifypassword,
                                  ),
                                  obscureText: true,
                                  validator: _validatePassword,
                                  onSaved: (String password) {
                                    person.password = password;
                                  }),
                              new Container(
                                child: new RaisedButton(
                                    child: new Text(Messages.of(context).createaccount),
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
                              child: new Text(Messages.of(context).login),
                              textColor: Theme.of(context).accentColor,
                              onPressed: () => _onPressed("/"),
                            ),
                            new FlatButton(
                                child: new Text(Messages.of(context).forgotPassword),
                                textColor: Theme.of(context).accentColor,
                                onPressed: () => _onPressed("/ForgotPassword")),
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
