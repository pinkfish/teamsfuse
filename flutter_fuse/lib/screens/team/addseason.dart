import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/form/switchformfield.dart';
import 'package:flutter_fuse/services/validations.dart';

class AddSeasonScreen extends StatefulWidget {
  final String teamUid;

  AddSeasonScreen(this.teamUid);

  @override
  AddSeasonScreenState createState() {
    return new AddSeasonScreenState();
  }
}

class AddSeasonScreenState extends State<AddSeasonScreen> {
  Season _seasonSelect;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _seasonName;
  Team _team;
  bool _importPlayers;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Validations _validations = new Validations();

  void initState() {
    super.initState();
    _team = UserDatabaseData.instance.teams[widget.teamUid];
    _seasonSelect = _team.seasons[_team.currentSeason];
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(value),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Make a new season.
      Season season = new Season(teamUid: widget.teamUid, name: _seasonName);
      if (_importPlayers) {
        season.players = new List.from(_seasonSelect.players);
      } else {
        season.players = [
          new SeasonPlayer(
              playerUid: UserDatabaseData.instance.mePlayer.uid,
              displayName: UserDatabaseData.instance.mePlayer.name,
              photoUrl: UserDatabaseData.instance.mePlayer.photoUrl,
              role: RoleInTeam.NonPlayer)
        ];
      }
      season.record = new WinRecord();
      print(season.toJSON(includePlayers: true));
      await season.updateFirestore(includePlayers: true);
      Navigator.pop(context);
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  Widget _buildResults(BuildContext context) {
     return new Form(
      key: _formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new SeasonFormField(
            decoration: new InputDecoration(
              icon: const Icon(CommunityIcons.tshirtcrew),
              labelText: Messages.of(context).season,
            ),
            teamUid: widget.teamUid,
            initialValue: _team.currentSeason,
            onSaved: (String seasonUid) {
              _seasonSelect = _team.seasons[seasonUid];
            },
          ),
          new SwitchFormField(
            initialValue: false,
            icon: Icons.import_contacts,
            onSaved: (bool b) => _importPlayers = b,
            label: Messages.of(context).importplayers,
          ),
          new TextFormField(
            decoration: new InputDecoration(
              icon: const Icon(Icons.event_note),
              hintText: Messages.of(context).season,
              labelText: Messages.of(context).seasonhint,
            ),
            validator: (String s) =>
                _validations.validateDisplayName(context, s),
            initialValue: '',
            keyboardType: TextInputType.text,
            obscureText: false,
            onSaved: (String value) {
              _seasonName = value;
            },
          ),
          new FlatButton(
            onPressed: _handleSubmit,
            child: new Text(Messages.of(context).addseason),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(Messages.of(context).addseason),
      ),
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomPadding: true,
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          new Flexible(
            fit: FlexFit.tight,
            flex: 0,
            child: this._buildResults(context),
          )
        ],
      ),
    );
  }
}
