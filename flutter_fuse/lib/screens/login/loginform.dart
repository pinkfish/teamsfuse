import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

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
  final ScrollController scrollController = ScrollController();
  bool autovalidate = false;
  final Validations validations = Validations();
  String email;
  String password;
  String errorText = '';

  void _onPressed(String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() async {
    var form = formKey.currentState;
    if (!form.validate()) {
      autovalidate = true; // Start validating on every change.
      setState(() {
        errorText = Messages.of(context).formerror;
      });
      _showInSnackBar(errorText);
    } else {
      // Save the data and login.
      form.save();
      BlocProvider.of<AuthenticationBloc>(context).add(
          AuthenticationLoginAttempt(email: email.trim(), password: password));
    }
  }

  Widget _buildLoginForm() {
    print("Building login form");
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
                    autovalidateMode: autovalidate
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: <Widget>[
                        Text(errorText),
                        TextFormField(
                          key: Key('EMAIL'),
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
                          key: Key('PASSWORD'),
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
                    margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        onSurface: Theme.of(context).primaryColor,
                        primary: Colors.white,
                      ),
                      onPressed: _handleSubmitted,
                      key: Key('SUBMIT'),
                      child: Text(Messages.of(context).login),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).accentColor,
                        ),
                        key: Key('CREATEACCOUNT'),
                        onPressed: () => _onPressed('/Login/SignUp'),
                        child: Text(Messages.of(context).createaccount),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Theme.of(context).accentColor,
                        ),
                        key: Key('FORGOTPASSWORD'),
                        onPressed: () => _onPressed('/Login/ForgotPassword'),
                        child: Text(Messages.of(context).forgotPassword),
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
      body: BlocConsumer(
        cubit: BlocProvider.of<AuthenticationBloc>(context),
        listener: (context, state) {
          if (state is AuthenticationLoggedIn) {
            Navigator.pushNamedAndRemoveUntil(context, '/Home', (d) => false);
          }
          if (state is AuthenticationFailed) {
            errorText = Messages.of(context).passwordnotcorrect;
            _showInSnackBar(errorText);
          }
          if (state is AuthenticationLoggedInUnverified) {
            Navigator.popAndPushNamed(context, '/Login/Verify');
          }
        },
        builder: (context, state) {
          return SavingOverlay(
              saving: state is AuthenticationLoading, child: _buildLoginForm());
        },
      ),
    );
  }
}
