import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fuse/services/validations.dart';
import 'package:fusemodel/firestore.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  SignupScreenState createState() => new SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      new GlobalKey<FormFieldState<String>>();
  ScrollController _scrollController = new ScrollController();
  bool _autovalidate = false;
  UserData _person = new UserData();

  // Profile details.
  String _displayName;
  String _phoneNumber;
  String _email;
  String _password;
  bool _saving = false;
  FocusNode _focusNodeDisplayName = new FocusNode();
  FocusNode _focusNodePhoneNumber = new FocusNode();
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodePassword = new FocusNode();
  FocusNode _focusNodePasswordVerify = new FocusNode();

  @override
  void initState() {
    _person.profile = new FusedUserProfile(null);
    super.initState();
  }

  void _onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar(Messages.of(context).formerror);
    } else {
      _saving = true;
      form.save();
      _person.email = _email;
      _person.password = _password;

      UserDatabaseData.instance.userAuth
          .createUser(
              _person,
              new FusedUserProfile(null,
                  displayName: _displayName,
                  phoneNumber: _phoneNumber,
                  email: _email))
          .then((UserData data) async {
        _saving = false;
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                content: new Text(Messages.of(context).createdaccount),
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
        Navigator.pushNamed(context, "/Login/Verify");
      }).catchError((dynamic e) {
        print(e);
        _saving = false;
        showInSnackBar(Messages.of(context).errorcreatinguser);
      });
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
    final Size screenSize = MediaQuery.of(context).size;
    //print(context.widget.toString());
    Validations validations = new Validations();
    return new Scaffold(
      key: _scaffoldKey,
      body: new SavingOverlay(
        saving: _saving,
        child: new SingleChildScrollView(
          controller: _scrollController,
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
                        key: _formKey,
                        autovalidate: _autovalidate,
                        child: new Column(
                          children: <Widget>[
                            new EnsureVisibleWhenFocused(
                              focusNode: _focusNodeDisplayName,
                              child: new TextFormField(
                                decoration: new InputDecoration(
                                    icon: const Icon(Icons.account_box),
                                    hintText:
                                        Messages.of(context).displaynamehint,
                                    labelText:
                                        Messages.of(context).displayname),
                                keyboardType: TextInputType.text,
                                obscureText: false,
                                focusNode: _focusNodeDisplayName,
                                validator: (String str) {
                                  return validations.validateName(context, str);
                                },
                                onSaved: (String value) {
                                  _displayName = value;
                                },
                              ),
                            ),
                            new EnsureVisibleWhenFocused(
                              focusNode: _focusNodeEmail,
                              child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(Icons.email),
                                  hintText: Messages.of(context).youremailHint,
                                  labelText: Messages.of(context).email,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                obscureText: false,
                                focusNode: _focusNodeEmail,
                                validator: (String str) {
                                  return validations.validateEmail(
                                      context, str);
                                },
                                onSaved: (String value) {
                                  _email = value;
                                },
                              ),
                            ),
                            new EnsureVisibleWhenFocused(
                              focusNode: _focusNodePhoneNumber,
                              child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(Icons.phone),
                                  hintText: Messages.of(context)
                                      .phonenumberhintoptional,
                                  labelText: Messages.of(context).phonenumber,
                                ),
                                keyboardType: TextInputType.phone,
                                obscureText: false,
                                focusNode: _focusNodePhoneNumber,
                                validator: (String str) {
                                  return validations.validatePhone(
                                      context, str);
                                },
                                onSaved: (String value) {
                                  _phoneNumber = value;
                                },
                              ),
                            ),
                            new EnsureVisibleWhenFocused(
                              focusNode: _focusNodePassword,
                              child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(Icons.lock),
                                  hintText: Messages.of(context).password,
                                  labelText: Messages.of(context).password,
                                ),
                                obscureText: true,
                                focusNode: _focusNodePassword,
                                validator: (String str) {
                                  return validations.validatePassword(
                                      context, str);
                                },
                                key: _passwordFieldKey,
                                onSaved: (String password) {
                                  _password = password;
                                },
                              ),
                            ),
                            new EnsureVisibleWhenFocused(
                              focusNode: _focusNodePasswordVerify,
                              child: new TextFormField(
                                decoration: new InputDecoration(
                                  icon: const Icon(Icons.lock),
                                  hintText: Messages.of(context).verifypassword,
                                  labelText:
                                      Messages.of(context).verifypassword,
                                ),
                                focusNode: _focusNodePasswordVerify,
                                obscureText: true,
                                validator: _validatePassword,
                                onSaved: (String password) {},
                              ),
                            ),
                            new Container(
                              child: new RaisedButton(
                                  child: new Text(
                                      Messages.of(context).createaccount),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  onPressed: _handleSubmitted),
                              margin:
                                  new EdgeInsets.only(top: 20.0, bottom: 20.0),
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
                            onPressed: () => _onPressed("/Login/Home"),
                          ),
                          new FlatButton(
                            child:
                                new Text(Messages.of(context).forgotPassword),
                            textColor: Theme.of(context).accentColor,
                            onPressed: () =>
                                _onPressed("/Login/ForgotPassword"),
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
