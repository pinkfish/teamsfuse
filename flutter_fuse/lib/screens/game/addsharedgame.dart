import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentdivisonprovider.dart';
import '../../widgets/form/leagueteampicker.dart';
import '../../widgets/games/gameshareddetails.dart';
import '../../widgets/games/sharedgameeditform.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/stepperalwaysvisible.dart';

///
/// Screen to display when doing a game add sequence.
///
class AddSharedGameScreen extends StatefulWidget {
  /// Constructor.
  AddSharedGameScreen(this.leagueUid, this.leagueDivisonUid);

  /// The league divison to add the game to.
  final String leagueDivisonUid;

  /// The league to add the game to.
  final String leagueUid;

  @override
  _AddSharedGameScreenState createState() {
    return _AddSharedGameScreenState();
  }
}

class _AddSharedGameScreenState extends State<AddSharedGameScreen> {
  _AddSharedGameScreenState();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<SharedGameEditFormState> _gameFormKey =
      GlobalKey<SharedGameEditFormState>();
  StepState homeAwayStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  int _currentStep = 0;
  GameSharedData _initGame;
  String _homeTeamUid;
  String _awayTeamUid;
  AddSharedGameBloc addSharedGameBloc;

  @override
  void initState() {
    super.initState();
    addSharedGameBloc = AddSharedGameBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return SharedGameEditForm(game: _initGame, key: _gameFormKey);
  }

  Widget _buildSummary(BuildContext context) {
    return GameSharedDetails(
      _initGame,
      adding: true,
    );
  }

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      case 0:
        if (_homeTeamUid == null || _awayTeamUid == null) {
          setState(() {
            homeAwayStepState = StepState.error;
            detailsStepState = StepState.disabled;
          });
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        if (_homeTeamUid == _awayTeamUid) {
          setState(() {
            homeAwayStepState = StepState.error;
            detailsStepState = StepState.disabled;
          });
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        homeAwayStepState = StepState.complete;
        detailsStepState = StepState.editing;
        break;
      case 1:
        // Verify the form is correct.
        if (backwards) {
          // Can always leave this step.
          detailsStepState = StepState.editing;
          return true;
        }
        if (!_gameFormKey.currentState.validate()) {
          detailsStepState = StepState.error;
          createStepStage = StepState.disabled;
          _showInSnackBar(Messages.of(context).formerror);
          _gameFormKey.currentState.autovalidate = true;
          return false;
        }
        _gameFormKey.currentState.save();
        _initGame = _gameFormKey.currentState.finalGameResult.build();
        detailsStepState = StepState.complete;
        createStepStage = StepState.complete;
        break;
      case 2:
        createStepStage = StepState.disabled;
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
          addSharedGameBloc
              .add(AddSharedGameEventCommit(newSharedData: _initGame));
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

  Widget _buildHomeAwayChooser() {
    return SingleLeagueOrTournamentDivisonProvider(
      leagueDivisonUid: widget.leagueDivisonUid,
      builder: (context, divisonBloc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            Messages.of(context).home,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          TournamentOrLeagueTeamPicker(
            leagueOrTournamentDivisonBloc: divisonBloc,
            //tournamentOrLeagueDivisonUid: widget.leagueDivisonUid,
            initialTeamUid: _homeTeamUid,
            onChanged: (str) => _homeTeamUid = str,
          ),
          Text(
            Messages.of(context).away,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          TournamentOrLeagueTeamPicker(
            leagueOrTournamentDivisonBloc: divisonBloc,
            //tournamentOrLeagueDivisonUid: widget.leagueDivisonUid,
            initialTeamUid: _awayTeamUid,
            onChanged: (str) => _awayTeamUid = str,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(messages.title),
      ),
      body: BlocProvider(
        create: (context) => addSharedGameBloc,
        child: BlocListener(
          bloc: addSharedGameBloc,
          listener: (conetext, addState) {
            if (addState is AddItemDone) {
              Navigator.pop(context);
            }
            if (addState is AddItemSaveFailed) {
              showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Error saving the game'),
                    );
                  });
            }
          },
          child: BlocBuilder(
            bloc: addSharedGameBloc,
            builder: (context, addState) => SavingOverlay(
              saving: addState is AddItemSaving,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: StepperAlwaysVisible(
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
                      title: Text(messages.homeaway),
                      state: homeAwayStepState,
                      isActive: false,
                      content: _buildHomeAwayChooser(),
                    ),
                    Step(
                      title: Text(messages.details),
                      state: detailsStepState,
                      isActive: _homeTeamUid != null && _awayTeamUid != null,
                      content: _buildForm(context),
                    ),
                    Step(
                      title: Text(messages.create),
                      state: createStepStage,
                      isActive: _gameFormKey != null &&
                          _gameFormKey.currentState != null &&
                          _gameFormKey.currentState.validate(),
                      content: _buildSummary(context),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
