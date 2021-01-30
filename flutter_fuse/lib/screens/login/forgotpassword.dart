import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/login/loginheader.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Shows the forgot password form.
///
class ForgotPasswordScreen extends StatefulWidget {
  /// Constructor.
  const ForgotPasswordScreen({Key key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  AutovalidateMode autovalidate = AutovalidateMode.disabled;
  Validations validations = Validations();
  String email = '';
  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  void onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() {
    var form = formKey.currentState;
    if (!form.validate()) {
      autovalidate =
          AutovalidateMode.always; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      _loginBloc.add(LoginEventForgotPasswordSend(email: email));
    }
  }

  Widget _buildForgotPasswordForm() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: formKey,
            autovalidateMode: autovalidate,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    hintText: Messages.of(context).email,
                    labelText: Messages.of(context).email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  onSaved: (value) {
                    email = value;
                  },
                ),
                Container(
                  child: RaisedButton(
                      child: Text(Messages.of(context).forgotPassword),
                      color: Theme.of(context).primaryColor,
                      key: Key("SUBMIT"),
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
                child: Text(Messages.of(context).createaccount),
                textColor: Theme.of(context).accentColor,
                key: Key("CREATEACCOUNT"),
                onPressed: () {
                  _loginBloc.add(LoginEventReset());
                  onPressed("/Login/SignUp");
                },
              ),
              FlatButton(
                child: Text(Messages.of(context).login),
                textColor: Theme.of(context).accentColor,
                key: Key("LOGIN"),
                onPressed: () {
                  _loginBloc.add(LoginEventReset());
                  onPressed("/Login/Home");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordDone() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: Text(Messages.of(context).forgotPasswordSent)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text(Messages.of(context).createaccount),
                textColor: Theme.of(context).accentColor,
                key: Key("CREATEACCOUNT"),
                onPressed: () {
                  _loginBloc.add(LoginEventReset());
                  onPressed("/Login/SignUp");
                },
              ),
              FlatButton(
                  child: Text(Messages.of(context).login),
                  textColor: Theme.of(context).accentColor,
                  key: Key("LOGIN"),
                  onPressed: () {
                    _loginBloc.add(LoginEventReset());
                    // Go back to the initial state.
                    onPressed("/Login/Home");
                  }),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              LoginHeader(),
              BlocBuilder(
                  cubit: _loginBloc,
                  builder: (context, state) {
                    var loading = LoginState is LoginValidatingForgotPassword;
                    if (state is LoginForgotPasswordFailed) {
                      showInSnackBar(state.error.toString());
                      return SavingOverlay(
                        saving: false,
                        child: _buildForgotPasswordDone(),
                      );
                    }
                    return SavingOverlay(
                      saving: loading,
                      child: _buildForgotPasswordForm(),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
