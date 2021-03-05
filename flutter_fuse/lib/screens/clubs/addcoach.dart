import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/clubs/clubimage.dart';
import '../../widgets/clubs/clubname.dart';
import '../../widgets/clubs/coachimage.dart';
import '../../widgets/clubs/editcoachdetails.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Adds a coach to the system.
///
class AddCoachScreen extends StatefulWidget {
  /// The uid of the club to add the coach too.
  final String clubUid;

  /// Constructor for the screen.
  AddCoachScreen(this.clubUid);

  @override
  _AddCoachScreenState createState() {
    return _AddCoachScreenState();
  }
}

class _AddCoachScreenState extends State<AddCoachScreen> {
  final GlobalKey<EditCoachDetailsFormState> _formKey =
      GlobalKey<EditCoachDetailsFormState>();
  int _currentStep = 0;
  StepState _detailsStepState = StepState.editing;
  StepState _createStepStage = StepState.disabled;
  Coach _coachToAdd;
  AddCoachBloc _coachBloc;
  Uint8List _imageFileToAdd;

  @override
  void initState() {
    super.initState();
    _coachBloc = AddCoachBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context));
    _coachToAdd = Coach((b) => b
      ..name = ''
      ..uid = ''
      ..clubUid = widget.clubUid
      ..about = '');
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed() async {
    if (_coachToAdd != null) {
      _coachBloc.add(
          AddCoachEventCommit(coach: _coachToAdd, imageFile: _imageFileToAdd));
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
        _coachToAdd = _formKey.currentState.validateAndCreate().build();
        if (_coachToAdd == null) {
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
      return CoachImage(
        clubUid: widget.clubUid,
        coachUid: _coachToAdd.uid,
        width: 100,
        height: 100,
      );
    }
    return Image.memory(_imageFileToAdd);
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: ClubImage(
              clubUid: widget.clubUid,
            ),
            title: ClubName(clubUid: widget.clubUid),
          ),
          _buildImage(),
          ListTile(
            leading: Icon(Icons.text_snippet_outlined),
            title: Text(_coachToAdd.name),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(_coachToAdd.about),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    var messages = Messages.of(context);
    return SingleClubProvider(
      clubUid: widget.clubUid,
      builder: (context, singleClubBloc) => BlocBuilder(
        cubit: _coachBloc,
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
                content: BlocBuilder(
                    cubit: singleClubBloc,
                    builder: (context, singleClubState) {
                      if (singleClubState is SingleClubUninitialized) {
                        return Text(Messages.of(context).loading);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          EditCoachDetailsForm(
                              singleClubState.club, _coachToAdd, _formKey),
                        ],
                      );
                    }),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: _coachBloc,
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
