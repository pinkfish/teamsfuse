import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleclubprovider.dart';
import '../../widgets/clubs/clubimage.dart';
import '../../widgets/clubs/clubname.dart';
import '../../widgets/clubs/editnewsitemdetails.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Adds a newsItem to the system.
///
class AddNewsItemScreen extends StatefulWidget {
  /// The uid of the club to add the newsItem too.
  final String clubUid;

  /// Constructor for the screen.
  AddNewsItemScreen(this.clubUid);

  @override
  _AddNewsItemScreenState createState() {
    return _AddNewsItemScreenState();
  }
}

class _AddNewsItemScreenState extends State<AddNewsItemScreen> {
  final GlobalKey<EditNewsItemDetailsFormState> _formKey =
      GlobalKey<EditNewsItemDetailsFormState>();
  int _currentStep = 0;
  StepState _detailsStepState = StepState.editing;
  StepState _createStepStage = StepState.disabled;
  NewsItem _newsItemToAdd;
  AddNewsItemBloc _newsItemBloc;

  @override
  void initState() {
    super.initState();
    _newsItemBloc = AddNewsItemBloc(
        db: RepositoryProvider.of<DatabaseUpdateModel>(context),
        crashes: RepositoryProvider.of<AnalyticsSubsystem>(context));
    _newsItemToAdd = NewsItem((b) => b
      ..subject = ''
      ..uid = ''
      ..clubUid = widget.clubUid
      ..body = ''
      ..postedByName = ''
      ..postedByUid = '');
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed() async {
    if (_newsItemToAdd != null) {
      _newsItemBloc.add(AddNewsItemEventCommit(newsItem: _newsItemToAdd));
    } else {
      _showInSnackBar(Messages.of(context).formError);
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
          _showInSnackBar(Messages.of(context).formError);
          return false;
        }
        _newsItemToAdd = _formKey.currentState.validateAndCreate().build();
        if (_newsItemToAdd == null) {
          setState(() {
            _detailsStepState = StepState.error;
            _createStepStage = StepState.disabled;
          });
          _showInSnackBar(Messages.of(context).formError);
          return false;
        }
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
          ListTile(
            leading: Icon(Icons.subject),
            title: Text(_newsItemToAdd.subject),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(_newsItemToAdd.body),
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
        bloc: _newsItemBloc,
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
                    bloc: singleClubBloc,
                    builder: (context, singleClubState) {
                      if (singleClubState is SingleClubUninitialized) {
                        return Text(Messages.of(context).loading);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          EditNewsItemDetailsForm(
                              singleClubState.club, _newsItemToAdd, _formKey),
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
      bloc: _newsItemBloc,
      listener: (context, state) {
        if (state is AddItemDone) {
          Navigator.pop(context);
        } else if (state is AddItemSaveFailed) {
          _showInSnackBar(Messages.of(context).formError);
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
