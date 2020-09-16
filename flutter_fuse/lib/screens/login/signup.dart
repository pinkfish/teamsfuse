import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/util/ensurevisiblewhenfocused.dart';
import '../../widgets/util/savingoverlay.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key key}) : super(key: key);

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();
  ScrollController _scrollController = ScrollController();
  bool _autovalidate = false;

  // Profile details.
  String _displayName;
  String _phoneNumber;
  String _email;
  String _password;
  FocusNode _focusNodeDisplayName = FocusNode();
  FocusNode _focusNodePhoneNumber = FocusNode();
  FocusNode _focusNodeEmail = FocusNode();
  FocusNode _focusNodePassword = FocusNode();
  FocusNode _focusNodePasswordVerify = FocusNode();
  LoginBloc _loginBloc;

  @override
  void initState() {
    //_person.profile = FusedUserProfile(null);
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  void _onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar(Messages.of(context).formerror);
    } else {
      form.save();
      //email = _email;
      //password = _password;
      _loginBloc.add(LoginEventSignupUser(
          email: _email,
          password: _password,
          displayName: _displayName,
          phoneNumber: _phoneNumber));
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
    Validations validations = Validations();

    return Scaffold(
      key: _scaffoldKey,
      body: BlocListener(
        cubit: _loginBloc,
        listener: (BuildContext context, LoginState state) {
          if (state is LoginSignupFailed) {
            showInSnackBar(Messages.of(context).errorcreatinguser);
          } else if (state is LoginSignupSucceeded) {
            showDialog<bool>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: Text(Messages.of(context).createdaccount),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child:
                          Text(MaterialLocalizations.of(context).okButtonLabel))
                ],
              ),
            ).then((bool ok) {
              Navigator.pushNamed(context, "/Login/Verify");
            });
          }
        },
        child: BlocBuilder(
          cubit: _loginBloc,
          builder: (BuildContext context, LoginState state) => SavingOverlay(
            saving: state is LoginValidatingSignup,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
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
                            image: ExactAssetImage(
                                "assets/images/abstractsport.png"),
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
                          Form(
                            key: _formKey,
                            autovalidate: _autovalidate,
                            child: Column(
                              children: <Widget>[
                                EnsureVisibleWhenFocused(
                                  focusNode: _focusNodeDisplayName,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        icon: const Icon(Icons.account_box),
                                        hintText: Messages.of(context)
                                            .displaynamehint,
                                        labelText:
                                            Messages.of(context).displayname),
                                    keyboardType: TextInputType.text,
                                    obscureText: false,
                                    focusNode: _focusNodeDisplayName,
                                    validator: (String str) {
                                      return validations.validateName(
                                          context, str);
                                    },
                                    onSaved: (String value) {
                                      _displayName = value;
                                    },
                                  ),
                                ),
                                EnsureVisibleWhenFocused(
                                  focusNode: _focusNodeEmail,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      icon: const Icon(Icons.email),
                                      hintText:
                                          Messages.of(context).youremailHint,
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
                                EnsureVisibleWhenFocused(
                                  focusNode: _focusNodePhoneNumber,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      icon: const Icon(Icons.phone),
                                      hintText: Messages.of(context)
                                          .phonenumberhintoptional,
                                      labelText:
                                          Messages.of(context).phonenumber,
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
                                EnsureVisibleWhenFocused(
                                  focusNode: _focusNodePassword,
                                  child: TextFormField(
                                    decoration: InputDecoration(
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
                                EnsureVisibleWhenFocused(
                                  focusNode: _focusNodePasswordVerify,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      icon: const Icon(Icons.lock),
                                      hintText:
                                          Messages.of(context).verifypassword,
                                      labelText:
                                          Messages.of(context).verifypassword,
                                    ),
                                    focusNode: _focusNodePasswordVerify,
                                    obscureText: true,
                                    validator: _validatePassword,
                                    onSaved: (String password) {},
                                  ),
                                ),
                                Container(
                                  child: RaisedButton(
                                      child: Text(
                                          Messages.of(context).createaccount),
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      onPressed: _handleSubmitted),
                                  margin:
                                      EdgeInsets.only(top: 20.0, bottom: 20.0),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                child: Text(Messages.of(context).login),
                                textColor: Theme.of(context).accentColor,
                                onPressed: () => _onPressed("/Login/Home"),
                              ),
                              FlatButton(
                                child:
                                    Text(Messages.of(context).forgotPassword),
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
        ),
      ),
    );
  }
}
