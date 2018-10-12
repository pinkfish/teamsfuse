import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamenteditform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'dart:io';

class EditLeagueScreen extends StatefulWidget {
  final String leagueOrTournamentUid;

  EditLeagueScreen(this.leagueOrTournamentUid);

  @override
  State createState() {
    return _EditLeagueScreenState();
  }
}

class _EditLeagueScreenState extends State<EditLeagueScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<LeagueOrTournamentEditFormState> _formState =
      new GlobalKey<LeagueOrTournamentEditFormState>();

  LeagueOrTournament _league;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _league = new LeagueOrTournament.copy(UserDatabaseData
        .instance.leagueOrTournments[widget.leagueOrTournamentUid]);
  }

  @override
  void dispose() {
    super.dispose();
    _league.dispose();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(BuildContext context) async {
    _saving = true;
    try {
      if (!_formState.currentState.validate()) {
        _formState.currentState.autovalidate = true;
        setState(() {});
        _showInSnackBar(Messages.of(context).formerror);
        return;
      }
      _formState.currentState.save();
      LeagueOrTournament league =
          _formState.currentState.finalLeagueOrTournamentResult;

      if (league != null) {
        File imageFile = _formState.currentState.imageFile;
        if (imageFile != null) {
          await league.updateImage(imageFile);
        }
        await league.updateFirestore();
        Navigator.of(context).pop(widget.leagueOrTournamentUid);
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.title),
      ),
      body: new SavingOverlay(
        saving: _saving,
        child: new Container(
          padding: new EdgeInsets.all(5.0),
          child: new SavingOverlay(
            saving: _saving,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: new LeagueOrTournamentEditForm(
                  leagueOrTournament: _league,
                  key: _formState,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(context),
        child: const Icon(Icons.check),
      ),
    );
  }
}
