import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../services/validations.dart';
import '../../widgets/login/loginheader.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Shows a login screen with the username/password setup as well as a
/// connection to a google signin.
///
class LoginScreen extends StatefulWidget {
  /// Constructor.
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  bool autovalidate = false;
  Validations validations = Validations();
  String email;
  String password;
  String errorText = '';
  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    super.initState();
  }

  void _onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() async {
    print('Submit');
    var form = formKey.currentState;
    if (!form.validate()) {
      print('Validate?');
      autovalidate = true; // Start validating on every change.
      setState(() {
        errorText = Messages.of(context).formerror;
      });
      _showInSnackBar(errorText);
    } else {
      // Save the data and login.
      form.save();
      _loginBloc
          .add(LoginEventAttempt(email: email.trim(), password: password));
    }
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        padding: EdgeInsets.all(16.0),
        //decoration: BoxDecoration(image: backgroundImage),
        child: Column(
          children: <Widget>[
            LoginHeader(),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: formKey,
                    autovalidate: autovalidate,
                    child: Column(
                      children: <Widget>[
                        Text(errorText),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email),
                            hintText: 'Your email address',
                            labelText: 'E-mail',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          onSaved: (value) {
                            email = value;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock_open),
                            hintText: 'Password',
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          onSaved: (pass) {
                            password = pass;
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      child: Text(Messages.of(context).login),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: _handleSubmitted,
                    ),
                    margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        child: Text(Messages.of(context).createaccount),
                        textColor: Theme.of(context).accentColor,
                        onPressed: () => _onPressed("/Login/SignUp"),
                      ),
                      FlatButton(
                        child: Text(Messages.of(context).forgotPassword),
                        textColor: Theme.of(context).accentColor,
                        onPressed: () => _onPressed("/Login/ForgotPassword"),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: BlocListener(
        cubit: _loginBloc,
        listener: (context, state) {
          if (state is LoginFailed) {
            errorText = Messages.of(context).passwordnotcorrect;
            _showInSnackBar(errorText);
          } else if (state is LoginSucceeded) {
            Navigator.pushNamedAndRemoveUntil(
                context, "/Login/Home", (d) => false);
          } else if (state is LoginEmailNotValidated) {
            Navigator.popAndPushNamed(context, "/Login/Verify");
          }
        },
        child: BlocBuilder(
          cubit: _loginBloc,
          builder: (context, state) {
            return SavingOverlay(
                saving: state is LoginValidating, child: _buildLoginForm());
          },
        ),
      ),
    );
  }
}
