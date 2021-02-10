import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../../widgets/leagueortournament/leagueimage.dart';
import '../../widgets/leagueortournament/leagueortournamenteditform.dart';
import '../../widgets/util/savingoverlay.dart';
import '../../widgets/util/stepperalwaysvisible.dart';

///
/// Adds a league to the system.
///
class AddLeagueScreen extends StatefulWidget {
  /// Constructor.
  AddLeagueScreen(this.type);

  /// The type of league.
  final LeagueOrTournamentType type;

  @override
  State createState() {
    return _AddLeagueScreenState();
  }
}

class _AddLeagueScreenState extends State<AddLeagueScreen> {
  int _currentStep = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LeagueOrTournamentEditFormState> _formState =
      GlobalKey<LeagueOrTournamentEditFormState>();
  StepState leagueStepState = StepState.editing;
  StepState createStepStage = StepState.disabled;

  LeagueOrTournamentBuilder _league;
  File _leagueImage;
  AddLeagueOrTournamentBloc addBloc;

  @override
  void initState() {
    var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    super.initState();
    _league = LeagueOrTournamentBuilder()
      ..type = widget.type
      ..name = ""
      ..shortDescription = ""
      ..longDescription = "";
    _league.membersData[authenticationBloc.currentUser.uid] =
        AddedOrAdmin((b) => b
          ..admin = true
          ..added = true);

    addBloc = AddLeagueOrTournamentBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    addBloc.close();
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      case 0:
        leagueStepState = StepState.editing;
        createStepStage = StepState.disabled;

        if (!_formState.currentState.validate()) {
          setState(() {
            leagueStepState = StepState.error;
            createStepStage = StepState.disabled;
          });
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        _formState.currentState.save();
        _league = _formState.currentState.finalLeagueOrTournamentResult;
        _leagueImage = _formState.currentState.imageFile;
        if (_league == null) {
          setState(() {
            leagueStepState = StepState.error;
          });
          return false;
        }
        setState(() {
          leagueStepState = StepState.complete;
          createStepStage = StepState.editing;
        });
        break;
      // Check to make sure a team is picked.
      case 1:
        if (backwards) {
          var clubBloc = BlocProvider.of<ClubBloc>(context);
          if (clubBloc.state.clubs.values.any((club) => club.isAdmin())) {
            return true;
          }
          _showInSnackBar(Messages.of(context).formerror);
          return false;
        }
        break;
    }
    return true;
  }

  void _onStepperContinue(BuildContext context) {
    if (_leaveCurrentState(false)) {
      setState(() {
        if (_currentStep < 1) {
          _currentStep++;
        } else {
          // Write the game out.

          addBloc.add(AddLeagueOrTournamentEventCommit(
              leagueOrTournament: _league.build(), imageFile: _leagueImage));
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

  Widget _buildSummary(BuildContext context) {
    return Card(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: _leagueImage != null
                  ? Image.file(
                      _leagueImage,
                      width: 50.0,
                      height: 50.0,
                    )
                  : LeagueImage(
                      leagueOrTournament: _league.build(),
                      width: 50.0,
                      height: 50.0,
                    ),
              title: Text(_league.name),
              subtitle: Text(_league.shortDescription),
            ),
            RichText(text: TextSpan(text: _league.longDescription))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return BlocProvider(
      create: (context) => addBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(messages.title),
        ),
        body: Builder(
          builder: (context) => BlocListener(
            cubit: BlocProvider.of<AddLeagueOrTournamentBloc>(context),
            listener: (context, state) {
              if (state is AddItemSaveFailed) {
                showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Error saving the league"),
                      );
                    });
              }
              if (state is AddItemDone) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              cubit: BlocProvider.of<AddLeagueOrTournamentBloc>(context),
              builder: (context, state) {
                return SavingOverlay(
                  saving: state is AddItemSaving,
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
                          title: Text(messages.league),
                          state: leagueStepState,
                          isActive: true,
                          content: LeagueOrTournamentEditForm(
                            leagueOrTournament: _league.build(),
                            key: _formState,
                          ),
                        ),
                        Step(
                          title: Text(messages.create),
                          state: createStepStage,
                          isActive: leagueStepState == StepState.complete,
                          content: _buildSummary(context),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
