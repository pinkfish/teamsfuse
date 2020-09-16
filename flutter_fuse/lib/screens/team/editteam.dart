import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/teams/teameditform.dart';
import '../../widgets/util/savingoverlay.dart';

class EditTeamScreen extends StatefulWidget {
  EditTeamScreen(this.teamUid);

  final String teamUid;

  @override
  EditTeamScreenState createState() {
    return EditTeamScreenState();
  }
}

class EditTeamScreenState extends State<EditTeamScreen> {
  Team _team;
  final GlobalKey<TeamEditFormState> _formKey = GlobalKey<TeamEditFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SingleTeamBloc singleTeamBloc;

  @override
  void initState() {
    super.initState();
    singleTeamBloc = SingleTeamBloc(
      db: RepositoryProvider.of<DatabaseUpdateModel>(context),
      teamUid: widget.teamUid,
    );
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return TeamEditForm(_team, _formKey);
  }

  void _savePressed(BuildContext context) async {
    TeamBuilder team = _formKey.currentState.validateAndCreate();
    if (team != null) {
      File imageFile = _formKey.currentState.getImageFile();
      singleTeamBloc.add(SingleTeamUpdate(team: team, image: imageFile));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: singleTeamBloc,
      listener: (BuildContext context, SingleTeamState state) {
        if (state is SingleTeamDeleted) {
          Navigator.pop(context, widget.teamUid);
        }
        if (state is SingleTeamSaveDone) {
          Navigator.pop(context, widget.teamUid);
        }
        if (state is SingleTeamSaveFailed) {
          _showInSnackBar(Messages.of(context).formerror);
        }
      },
      child: BlocBuilder(
        cubit: singleTeamBloc,
        builder: (BuildContext context, SingleTeamState teamState) => Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              Messages.of(context).titlewith(
                  teamState.team?.name ?? Messages.of(context).unknown),
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            child: SavingOverlay(
              saving: teamState is SingleTeamSaving,
              child: _buildForm(context),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _savePressed(context),
            child: const Icon(Icons.check),
          ),
        ),
      ),
    );
  }
}
