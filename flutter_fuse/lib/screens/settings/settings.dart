import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleprofileprovider.dart';
import '../../widgets/form/switchformfield.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Display the settings screen for the app.
///
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  bool emailOnUpdate;
  bool emailOnUpcoming;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _onSave(
      SingleProfileBloc bloc, SingleProfileState singleProfileState) async {
    if (formState.currentState.validate()) {
      formState.currentState.save();

      var profile = singleProfileState.profile.rebuild((b) => b
        ..emailUpcomingGame = emailOnUpcoming
        ..emailOnUpdates = emailOnUpdate);
      bloc.add(SingleProfileUpdate(profile: profile));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      body: SingleProfileProvider(
        userUid: authenticationBloc.currentUser.uid,
        builder: (context, singleProfileBloc) => BlocListener(
          bloc: singleProfileBloc,
          listener: (context, singleProfileState) {
            if (singleProfileState is SingleProfileSaveDone ||
                singleProfileState is SingleProfileDeleted) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder(
            bloc: singleProfileBloc,
            builder: (vontext, singleProfileState) {
              if (singleProfileState is SingleProfileUninitialized) {
                return SavingOverlay(
                  saving: true,
                  child: Text(Messages.of(context).title),
                );
              }
              return SavingOverlay(
                saving: singleProfileState is SingleProfileSaving,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Form(
                      key: formState,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Messages.of(context).emailheader,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SwitchFormField(
                            label: Messages.of(context).emailonupdates,
                            icon: Icons.update,
                            initialValue:
                                singleProfileState.profile.emailOnUpdates,
                            onSaved: (val) => emailOnUpdate = val,
                          ),
                          SwitchFormField(
                            label: Messages.of(context).emailonupcoming,
                            icon: Icons.calendar_today,
                            initialValue:
                                singleProfileState.profile.emailUpcomingGame,
                            onSaved: (val) => emailOnUpcoming = val,
                          ),
                          ButtonBar(
                            children: <Widget>[
                              FlatButton(
                                onPressed: () => _onSave(
                                    singleProfileBloc, singleProfileState),
                                textColor: Colors.white,
                                color: Theme.of(context).primaryColor,
                                child: Text(MaterialLocalizations.of(context)
                                    .okButtonLabel),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(MaterialLocalizations.of(context)
                                    .cancelButtonLabel),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
