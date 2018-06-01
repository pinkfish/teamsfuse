import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';

class SettingsScreen extends StatefulWidget {
  @override
  SettingsScreenState createState() {
    return new SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formState = new GlobalKey<FormState>();
  bool _saving;

  bool emailOnUpdate;
  bool emailOnUpcoming;

  @override
  void initState() {
    super.initState();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _onSave() async {
    if (formState.currentState.validate()) {
      formState.currentState.save();
      setState(() {
        _saving = true;
      });
      UserData user = await UserAuth.instance.currentUser();
      FusedUserProfile profile = user.profile.copyWith(
          emailUpcomingGames: emailOnUpcoming, emailNewEvents: emailOnUpdate);
      UserAuth.instance.updateProfile(user.uid, profile);
      setState(() {
        _saving = false;
      });
      Navigator.pop(context);
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new FutureBuilder(
          future: UserAuth.instance.currentUser().then((UserData data) {
            return UserAuth.instance.getProfile(data.uid);
          }),
          builder:
              (BuildContext context, AsyncSnapshot<FusedUserProfile> data) {
            if (data.hasData) {
              return new SavingOverlay(
                saving: _saving,
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
                          initialValue: data.data.emailOnUpdates,
                          onSaved: (bool val) => emailOnUpdate = val,
                        ),
                        new SwitchFormField(
                          label: Messages.of(context).emailonupcoming,
                          icon: Icons.calendar_today,
                          initialValue: data.data.emailUpcomingGame,
                          onSaved: (bool val) => emailOnUpcoming = val,
                        ),
                        new ButtonBar(
                          children: <Widget>[
                            new FlatButton(
                              child: new Text(MaterialLocalizations
                                  .of(context)
                                  .okButtonLabel),
                              onPressed: _onSave,
                              textColor: Colors.white,
                              color: Theme.of(context).primaryColor,
                            ),
                            new FlatButton(
                              child: new Text(MaterialLocalizations
                                  .of(context)
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
            } else {
              return new SavingOverlay(
                saving: true,
                child: new Text(Messages.of(context).title),
              );
            }
          }),
    );
  }
}
