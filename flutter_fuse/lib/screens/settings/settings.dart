import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleprofileprovider.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() {
    return new SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  bool emailOnUpdate;
  bool emailOnUpcoming;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _onSave(
      SingleProfileBloc bloc, SingleProfileState singleProfileState) async {
    if (formState.currentState.validate()) {
      formState.currentState.save();

      FusedUserProfile profile = singleProfileState.profile.rebuild((b) => b
        ..emailUpcomingGame = emailOnUpcoming
        ..emailOnUpdates = emailOnUpdate);
      bloc.dispatch(SingleProfileUpdate(profile: profile));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: SingleProfileProvider(
        userUid: authenticationBloc.currentUser.uid,
        builder: (BuildContext context, SingleProfileBloc singleProfileBloc) =>
            BlocListener(
          bloc: singleProfileBloc,
          listener:
              (BuildContext context, SingleProfileState singleProfileState) {
            if (singleProfileState is SingleProfileSaveDone ||
                singleProfileState is SingleProfileDeleted) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder(
            bloc: singleProfileBloc,
            builder:
                (BuildContext vontext, SingleProfileState singleProfileState) {
              if (singleProfileState is SingleProfileUnitialized) {
                return new SavingOverlay(
                  saving: true,
                  child: new Text(Messages.of(context).title),
                );
              }
              return new SavingOverlay(
                saving: singleProfileState is SingleProfileSaving,
                child: new SingleChildScrollView(
                  child: new Container(
                    padding: new EdgeInsets.all(10.0),
                    child: new Form(
                      key: formState,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            Messages.of(context).emailheader,
                            style: Theme.of(context).textTheme.title,
                          ),
                          new SwitchFormField(
                            label: Messages.of(context).emailonupdates,
                            icon: Icons.update,
                            initialValue:
                                singleProfileState.profile.emailOnUpdates,
                            onSaved: (bool val) => emailOnUpdate = val,
                          ),
                          new SwitchFormField(
                            label: Messages.of(context).emailonupcoming,
                            icon: Icons.calendar_today,
                            initialValue:
                                singleProfileState.profile.emailUpcomingGame,
                            onSaved: (bool val) => emailOnUpcoming = val,
                          ),
                          new ButtonBar(
                            children: <Widget>[
                              new FlatButton(
                                child: new Text(
                                    MaterialLocalizations.of(context)
                                        .okButtonLabel),
                                onPressed: () => _onSave(
                                    singleProfileBloc, singleProfileState),
                                textColor: Colors.white,
                                color: Theme.of(context).primaryColor,
                              ),
                              new FlatButton(
                                child: new Text(
                                    MaterialLocalizations.of(context)
                                        .cancelButtonLabel),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
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
