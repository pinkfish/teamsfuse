import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/clubs/editclubdetails.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';
import 'dart:io';

class AddClubScreen extends StatefulWidget {
  @override
  AddClubScreenState createState() {
    return new AddClubScreenState();
  }
}

class AddClubScreenState extends State<AddClubScreen> {
  final GlobalKey<EditClubDetailsFormState> _formKey =
      new GlobalKey<EditClubDetailsFormState>();
  bool _saving = false;
  int _currentStep = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StepState _detailsStepState = StepState.editing;
  StepState _createStepStage = StepState.disabled;
  Club _clubToAdd;
  File _imageFileToAdd;

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    setState(() {
      _saving = true;
    });
    try {
      if (_clubToAdd != null) {
        if (_imageFileToAdd != null) {
          Uri uri = await DatabaseUpdateModel.instance
              .updateClubImage(_clubToAdd, _imageFileToAdd);
          _clubToAdd.photoUrl = uri.toString();
        }
        await _clubToAdd.updateFirestore();
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

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      // Check to make sure a team is picked.
      case 0:
        // Verify the form is correct.
        if (backwards) {
          // Can always leave this step.
          _detailsStepState = StepState.editing;
          return true;
        }
        if (!_formKey.currentState.validate()) {
          _detailsStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _clubToAdd = _formKey.currentState.validateAndCreate();
        if (_clubToAdd == null) {
          _detailsStepState = StepState.error;
          _createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _imageFileToAdd = _formKey.currentState.getImageFile();
        _detailsStepState = StepState.complete;
        break;
      case 2:
        _createStepStage = StepState.disabled;
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        } else {
          // Write the game out.
          _savePressed();
        }
      });
    }
  }

  void _onStepTapped(int step) {
    if (_leaveCurrentState(step < _currentStep)) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  Widget _buildImage() {
    if (_imageFileToAdd == null) {
      return new ClubImage(
        _clubToAdd,
      );
    }
    return new Image.file(_imageFileToAdd);
  }

  Widget _buildSummary() {
    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          _buildImage(),
          new ListTile(
            leading: const Icon(Icons.title),
            title: new Text(_clubToAdd.name),
          ),
          new ListTile(
            leading: const Icon(Icons.timer),
            title: new Text(
                Messages.of(context).arrivebefore(_clubToAdd.arriveBeforeGame)),
          ),
          new ListTile(
            leading: const Icon(Icons.check),
            title: new Text(Messages
                .of(context)
                .trackattendence(_clubToAdd.trackAttendence)),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    Messages messages = Messages.of(context);
    return new SavingOverlay(
      saving: _saving,
      child: new Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          _onStepperContinue(context);
        },
        onStepCancel: () {
          // Go back
          Navigator.of(context).pop();
        },
        onStepTapped: (int step) {
          _onStepTapped(step);
        },
        steps: <Step>[
          new Step(
            title: new Text(messages.gamedetails),
            state: _detailsStepState,
            isActive: true,
            content: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new EditClubDetailsForm(new Club(), _formKey),
              ],
            ),
          ),
          new Step(
            title: new Text(messages.gamecreate),
            state: _createStepStage,
            isActive: true,
            content: _buildSummary(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      floatingActionButton: _currentStep == 1
          ? new FloatingActionButton(
              onPressed: () => _savePressed(),
              child: const Icon(Icons.check),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}
