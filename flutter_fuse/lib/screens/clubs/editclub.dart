import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/editclubdetails.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class EditClubScreen extends StatefulWidget {
  EditClubScreen(this.clubUid);

  final String clubUid;

  @override
  EditClubScreenState createState() {
    return new EditClubScreenState();
  }
}

class EditClubScreenState extends State<EditClubScreen> {
  final GlobalKey<EditClubDetailsFormState> _formKey =
      new GlobalKey<EditClubDetailsFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SingleClubBloc _singleClubState;
  bool _doingSave = false;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    try {
      Club club = _formKey.currentState.validateAndCreate();
      File imageFile = _formKey.currentState.getImageFile();
      if (club != null) {
        _doingSave = true;
        _singleClubState
            .dispatch(SingleClubUpdate(club: club, image: imageFile));
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {}
  }

  Widget _buildBody(SingleClubState state) {
    return new SavingOverlay(
      saving: state is SingleClubSaving,
      child: new EditClubDetailsForm(state.club, _formKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _savePressed(),
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocListener(
        bloc: _singleClubState,
        listener: (BuildContext context, SingleClubState state) {
          if (state is SingleClubDeleted) {
            Navigator.pop(context);
          } else if (state is SingleClubLoaded) {
            // finished saving.
            if (_doingSave) {
              Navigator.pop(context);
            }
          }
        },
        child: BlocBuilder(
          bloc: _singleClubState,
          builder: (BuildContext context, SingleClubState state) {
            if (state is SingleClubDeleted) {
            } else {
              return _buildBody(state);
            }
          },
        ),
      ),
    );
  }
}
