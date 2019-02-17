import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/editclubdetails.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
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
  bool _saving = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    setState(() {
      _saving = true;
    });
    try {
      Club club = _formKey.currentState.validateAndCreate();
      File imageFile = _formKey.currentState.getImageFile();
      if (club != null) {
        if (imageFile != null) {
          Uri uri = await UserDatabaseData.instance.updateModel
              .updateClubImage(club, imageFile);
          club.photoUrl = uri.toString();
        }
        await club.updateFirestore();
        Navigator.pop(context);
      } else {
        _showInSnackBar(Messages.of(context).formerror);
      }
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Widget _buildBody() {
    return new SavingOverlay(
      saving: _saving,
      child: new EditClubDetailsForm(
          UserDatabaseData.instance.clubs[widget.clubUid], _formKey),
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
      body: _buildBody(),
    );
  }
}
