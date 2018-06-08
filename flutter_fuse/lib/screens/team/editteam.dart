import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/teams/teameditform.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';

class EditTeamScreen extends StatefulWidget {
  final String teamUid;

  EditTeamScreen(this.teamUid);

  @override
  EditTeamScreenState createState() {
    return new EditTeamScreenState(this.teamUid);
  }
}

class EditTeamScreenState extends State<EditTeamScreen> {
  Team _team;
  final GlobalKey<TeamEditFormState> _formKey =
      new GlobalKey<TeamEditFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool saving = false;

  EditTeamScreenState(String teamuid) {
    print('team uid $teamuid');
    if (UserDatabaseData.instance.teams.containsKey(teamuid)) {
      this._team = new Team.copy(UserDatabaseData.instance.teams[teamuid]);
      print('Existing team uid ${_team.toJSON()}');
    } else {
      this._team = new Team();
      this._team.uid = teamuid;
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new TeamEditForm(_team, _formKey);
  }

  void _savePressed(BuildContext context) async {
    saving = true;
    try {
      if (await _formKey.currentState.validateAndSaveToFirebase()) {
        Navigator.of(context).pop(_formKey.currentState.team.uid);
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {
      saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
        actions: <Widget>[],
      ),
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        child: new SavingOverlay(
          saving: saving,
          child: this._buildForm(context),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(context),
        child: const Icon(Icons.check),
      ),
    );
  }
}
