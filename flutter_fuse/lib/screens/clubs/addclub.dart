import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/editclubdetails.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class AddClubScreen extends StatefulWidget {
  @override
  AddClubScreenState createState() {
    return new AddClubScreenState();
  }
}

class AddClubScreenState extends State<AddClubScreen> {
  final GlobalKey<EditClubDetailsFormState> _formKey =
      new GlobalKey<EditClubDetailsFormState>();
  int _currentStep = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StepState _detailsStepState = StepState.editing;
  StepState _createStepStage = StepState.disabled;
  Club _clubToAdd;
  AddClubBloc clubBloc;
  File _imageFileToAdd;

  @override
  void initState() {
    super.initState();
    clubBloc = AddClubBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
    _clubToAdd = new Club((b) => b
      ..name = ""
      ..arriveBeforeGame = 0
      ..trackAttendence = Tristate.Unset);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed() async {
    if (_clubToAdd != null) {
      clubBloc.add(
          AddClubEventCommit(club: _clubToAdd, imageFile: _imageFileToAdd));
    } else {
      _showInSnackBar(Messages.of(context).formerror);
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
          setState(() {
            _detailsStepState = StepState.error;
            _createStepStage = StepState.disabled;
          });
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _clubToAdd = _formKey.currentState.validateAndCreate().build();
        if (_clubToAdd == null) {
          setState(() {
            _detailsStepState = StepState.error;
            _createStepStage = StepState.disabled;
          });
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _imageFileToAdd = _formKey.currentState.getImageFile();
        setState(() {
          _detailsStepState = StepState.complete;
        });
        break;
      case 2:
        setState(() {
          _createStepStage = StepState.disabled;
        });
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
        clubUid: _clubToAdd.uid,
      );
    }
    return new Image.file(_imageFileToAdd);
  }

  Widget _buildSummary() {
    print('$_clubToAdd');
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
            title: new Text(Messages.of(context)
                .trackattendence(_clubToAdd.trackAttendence)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    Messages messages = Messages.of(context);
    return BlocBuilder(
      cubit: clubBloc,
      builder: (BuildContext context, AddItemState state) => SavingOverlay(
        saving: state is AddItemSaving,
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
              title: new Text(messages.details),
              state: _detailsStepState,
              isActive: true,
              content: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new EditClubDetailsForm(_clubToAdd, _formKey),
                ],
              ),
            ),
            new Step(
              title: new Text(messages.create),
              state: _createStepStage,
              isActive: true,
              content: _buildSummary(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: clubBloc,
      listener: (BuildContext context, AddItemState state) {
        if (state is AddItemDone) {
          Navigator.pop(context);
        } else if (state is AddItemSaveFailed) {
          _showInSnackBar(Messages.of(context).formerror);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
