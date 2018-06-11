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
    return new EditTeamScreenState();
  }
}

class EditTeamScreenState extends State<EditTeamScreen> {
  Team _team;
  final GlobalKey<TeamEditFormState> _formKey =
      new GlobalKey<TeamEditFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (UserDatabaseData.instance.teams.containsKey(widget.teamUid)) {
      _team = new Team.copy(UserDatabaseData.instance.teams[widget.teamUid]);
      print('Existing team uid ${_team.toJSON()}');
    } else {
      _team = new Team();
      _team.uid = widget.teamUid;
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
        Navigator.of(context).pop(_formKey.currentState.widget.team.uid);
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
      ),
      body: new Container(
        padding: new EdgeInsets.all(16.0),
        child: new SavingOverlay(
          saving: saving,
          child: _buildForm(context),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(context),
        child: const Icon(Icons.check),
      ),
    );
  }
}
