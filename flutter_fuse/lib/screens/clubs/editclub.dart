import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubprovider.dart';
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

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(SingleClubBloc singleClubBloc) async {
    try {
      var club = _formKey.currentState.validateAndCreate();
      var imageFile = _formKey.currentState.getImageFile();
      if (club != null) {
        singleClubBloc
            .add(SingleClubUpdate(club: club.build(), image: imageFile));
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {}
  }

  Widget _buildBody(SingleClubState state) {
    return SavingOverlay(
      saving: state is SingleClubSaving || state is SingleClubUninitialized,
      child: state is SingleClubUninitialized
          ? SizedBox(height: 0, width: 0)
          : EditClubDetailsForm(state.club, _formKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleClubProvider(
      clubUid: widget.clubUid,
      builder: (context, singleClubBloc) => Scaffold(
        appBar: AppBar(
          title: Text(Messages.of(context).title),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _savePressed(singleClubBloc),
          child: Icon(Icons.check),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: BlocConsumer(
          bloc: singleClubBloc,
          listener: (context, state) {
            if (state is SingleClubDeleted) {
              Navigator.pop(context);
            } else if (state is SingleClubSaveDone) {
              // finished saving.
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
    );
  }
}
