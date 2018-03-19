import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/messages.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key key}) : super(key: key);

  @override
  VerifyEmailScreenState createState() => new VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
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
      showInSnackBar(Messages.of(context).formerror);
    } else {
      form.save();
      UserAuth.instance.sendPasswordResetEmail(email).then((bool user) {
        Navigator.pushNamed(context, "/");
      }).catchError((error) {
        showInSnackBar(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);
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
                              new Text(messages.verifyexplanation),
                              new TextFormField(
                                  decoration: new InputDecoration(
                                    icon: const Icon(Icons.email),
                                    hintText: messages.email,
                                    labelText: messages.youremailHint,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: false,
                                  onSaved: (String value) {
                                    email = value;
                                  }),
                              new Container(
                                child: new RaisedButton(
                                    child: new Text(messages.resendverify),
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
                              child: new Text(messages.createaccount),
                              textColor: Theme.of(context).accentColor,
                              onPressed: () => onPressed("/SignUp"),
                            ),
                            new FlatButton(
                                child: new Text(messages.login),
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
