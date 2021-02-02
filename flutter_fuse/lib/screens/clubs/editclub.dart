import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/clubs/editclubdetails.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// The screen to edit the club.
///
class EditClubScreen extends StatefulWidget {
  /// Constructor.
  EditClubScreen(this.clubUid);

  /// Club uid to edit the club for.
  final String clubUid;

  @override
  _EditClubScreenState createState() {
    return _EditClubScreenState();
  }
}

class _EditClubScreenState extends State<EditClubScreen> {
  final GlobalKey<EditClubDetailsFormState> _formKey =
      GlobalKey<EditClubDetailsFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SingleClubBloc _singleClubState;
  bool _doingSave = false;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed() async {
    try {
      var club = _formKey.currentState.validateAndCreate();
      var imageFile = _formKey.currentState.getImageFile();
      if (club != null) {
        _doingSave = true;
        _singleClubState
            .add(SingleClubUpdate(club: club.build(), image: imageFile));
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {}
  }

  Widget _buildBody(SingleClubState state) {
    return SavingOverlay(
      saving: state is SingleClubSaving,
      child: EditClubDetailsForm(state.club, _formKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Messages.of(context).title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePressed,
        child: Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocListener(
        cubit: _singleClubState,
        listener: (context, state) {
          if (state is SingleClubDeleted) {
            Navigator.pop(context);
          } else if (state is SingleClubLoaded) {
            // finished saving.
            if (_doingSave) {
              Navigator.pop(context);
            }
          }
        },
        child: BlocListener(
          cubit: _singleClubState,
          listener: (context, state) {
            if (state is SingleClubDeleted) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder(
            cubit: _singleClubState,
            builder: (context, state) {
              return _buildBody(state);
            },
          ),
        ),
      ),
    );
  }
}
