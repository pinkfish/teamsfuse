import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/clubs/editclubdetails.dart';
import '../../widgets/util/clubimage.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Adds a club to the system.
///
class AddClubScreen extends StatefulWidget {
  @override
  _AddClubScreenState createState() {
    return _AddClubScreenState();
  }
}

class _AddClubScreenState extends State<AddClubScreen> {
  final GlobalKey<EditClubDetailsFormState> _formKey =
      GlobalKey<EditClubDetailsFormState>();
  int _currentStep = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    _clubToAdd = Club((b) => b
      ..name = ""
      ..arriveBeforeGame = 0
      ..trackAttendence = Tristate.Unset);
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
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
      return ClubImage(
        clubUid: _clubToAdd.uid,
      );
    }
    return Image.file(_imageFileToAdd);
  }

  Widget _buildSummary() {
    print('$_clubToAdd');
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildImage(),
          ListTile(
            leading: Icon(Icons.title),
            title: Text(_clubToAdd.name),
          ),
          ListTile(
            leading: Icon(Icons.timer),
            title: Text(
                Messages.of(context).arrivebefore(_clubToAdd.arriveBeforeGame)),
          ),
          ListTile(
            leading: Icon(Icons.check),
            title: Text(Messages.of(context)
                .trackattendence(_clubToAdd.trackAttendence)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    var messages = Messages.of(context);
    return BlocBuilder(
      cubit: clubBloc,
      builder: (context, state) => SavingOverlay(
        saving: state is AddItemSaving,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            _onStepperContinue(context);
          },
          onStepCancel: () {
            // Go back
            Navigator.of(context).pop();
          },
          onStepTapped: (step) {
            _onStepTapped(step);
          },
          steps: <Step>[
            Step(
              title: Text(messages.details),
              state: _detailsStepState,
              isActive: true,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  EditClubDetailsForm(_clubToAdd, _formKey),
                ],
              ),
            ),
            Step(
              title: Text(messages.create),
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
      listener: (context, state) {
        if (state is AddItemDone) {
          Navigator.pop(context);
        } else if (state is AddItemSaveFailed) {
          _showInSnackBar(Messages.of(context).formerror);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Messages.of(context).title),
        ),
        floatingActionButton: _currentStep == 1
            ? FloatingActionButton(
                onPressed: _savePressed,
                child: const Icon(Icons.check),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _buildBody(),
      ),
    );
  }
}
