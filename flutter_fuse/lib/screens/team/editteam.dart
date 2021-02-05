import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/blocs/singleteamprovider.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/teams/teameditform.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Editing the team, showing the pieces to edit and updates.
///
class EditTeamScreen extends StatefulWidget {
  /// Constructor.
  EditTeamScreen(this.teamUid);

  /// The teamUid to edit for the team.
  final String teamUid;

  @override
  _EditTeamScreenState createState() {
    return _EditTeamScreenState();
  }
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final GlobalKey<TeamEditFormState> _formKey = GlobalKey<TeamEditFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _buildForm(BuildContext context, SingleTeamState state) {
    if (state is SingleTeamUninitialized) {
      return CircularProgressIndicator();
    }
    return TeamEditForm(state.team, state.club, _formKey);
  }

  void _savePressed(BuildContext context, SingleTeamBloc singleTeamBloc) async {
    var team = _formKey.currentState.validateAndCreate();
    if (team != null) {
      var imageFile = _formKey.currentState.getImageFile();
      singleTeamBloc.add(SingleTeamUpdate(team: team, image: imageFile));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (context, singleTeamBloc) => BlocListener(
        cubit: singleTeamBloc,
        listener: (context, state) {
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
          builder: (context, teamState) => Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                Messages.of(context).titlewith(
                    teamState.team?.name ?? Messages.of(context).unknown),
              ),
              actions: [
                TextButton.icon(
                  icon: Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                  label: Text(Messages.of(context).saveButtonText,
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Colors.white)),
                  onPressed: () => _savePressed(context, singleTeamBloc),
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(16.0),
              child: SavingOverlay(
                saving: teamState is SingleTeamSaving ||
                    teamState is SingleTeamUninitialized,
                child: _buildForm(context, teamState),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
