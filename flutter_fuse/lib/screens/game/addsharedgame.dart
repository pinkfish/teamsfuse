import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/blocs/singleleagueortournamentdivisonprovider.dart';
import 'package:flutter_fuse/widgets/form/leagueteampicker.dart';
import 'package:flutter_fuse/widgets/games/gameshareddetails.dart';
import 'package:flutter_fuse/widgets/games/sharedgameeditform.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Screen to display when doing a game add sequence.
///
class AddSharedGameScreen extends StatefulWidget {
  AddSharedGameScreen(this.leagueUid, this.leagueDivisonUid);

  final String leagueDivisonUid;
  final String leagueUid;

  @override
  _AddSharedGameScreenState createState() {
    return new _AddSharedGameScreenState();
  }
}

class _AddSharedGameScreenState extends State<AddSharedGameScreen> {
  _AddSharedGameScreenState();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<SharedGameEditFormState> _gameFormKey =
      new GlobalKey<SharedGameEditFormState>();
  StepState homeAwayStepState = StepState.editing;
  StepState detailsStepState = StepState.disabled;
  StepState createStepStage = StepState.disabled;
  int _currentStep = 0;
  GameSharedData _initGame;
  String _homeTeamUid;
  String _awayTeamUid;
  AddSharedGameBloc addSharedGameBloc;

  void initState() {
    super.initState();
    addSharedGameBloc = AddSharedGameBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildForm(BuildContext context) {
    return new SharedGameEditForm(game: _initGame, key: _gameFormKey);
  }

  Widget _buildSummary(BuildContext context) {
    return new GameSharedDetails(
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
        print('Saved game $_initGame');
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
              .dispatch(AddSharedGameEventCommit(newSharedData: _initGame));
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
      leagueOrTournamentDivisonUid: widget.leagueDivisonUid,
      builder: (BuildContext context,
              SingleLeagueOrTournamentDivisonBloc divisonBloc) =>
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            Messages.of(context).home,
            style: Theme.of(context).textTheme.subhead,
          ),
          TournamentOrLeagueTeamPicker(
            leagueOrTournamentDivisonBloc: divisonBloc,
            //tournamentOrLeagueDivisonUid: widget.leagueDivisonUid,
            initialTeamUid: _homeTeamUid,
            onChanged: (String str) => _homeTeamUid = str,
          ),
          Text(
            Messages.of(context).away,
            style: Theme.of(context).textTheme.subhead,
          ),
          TournamentOrLeagueTeamPicker(
            leagueOrTournamentDivisonBloc: divisonBloc,
            //tournamentOrLeagueDivisonUid: widget.leagueDivisonUid,
            initialTeamUid: _awayTeamUid,
            onChanged: (String str) => _awayTeamUid = str,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.title),
      ),
      body: BlocProvider(
        builder: (BuildContext context) => addSharedGameBloc,
        child: BlocListener(
          bloc: addSharedGameBloc,
          listener: (BuildContext conetext, AddItemState addState) {
            if (addState is AddItemDone) {
              Navigator.pop(context);
            }
            if (addState is AddItemSaveFailed) {
              showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text("Error"),
                      content: new Text("Error saving the game"),
                    );
                  });
            }
          },
          child: BlocBuilder(
            bloc: addSharedGameBloc,
            builder: (BuildContext context, AddItemState addState) =>
                SavingOverlay(
              saving: addState is AddItemSaving,
              child: new Container(
                padding: new EdgeInsets.all(5.0),
                child: new StepperAlwaysVisible(
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
                      title: new Text(messages.homeaway),
                      state: homeAwayStepState,
                      isActive: false,
                      content: _buildHomeAwayChooser(),
                    ),
                    new Step(
                      title: new Text(messages.details),
                      state: detailsStepState,
                      isActive: _homeTeamUid != null && _awayTeamUid != null,
                      content: _buildForm(context),
                    ),
                    new Step(
                      title: new Text(messages.create),
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
