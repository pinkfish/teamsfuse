import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamenteditform.dart';
import 'package:flutter_fuse/widgets/util/leagueimage.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:flutter_fuse/widgets/util/stepperalwaysvisible.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class AddLeagueScreen extends StatefulWidget {
  AddLeagueScreen(this.type);

  final LeagueOrTournamentType type;

  @override
  State createState() {
    return _AddLeagueScreenState();
  }
}

class _AddLeagueScreenState extends State<AddLeagueScreen> {
  int _currentStep = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<LeagueOrTournamentEditFormState> _formState =
      new GlobalKey<LeagueOrTournamentEditFormState>();
  StepState leagueStepState = StepState.editing;
  StepState createStepStage = StepState.disabled;

  LeagueOrTournamentBuilder _league;
  File _leagueImage;
  AddLeagueOrTournamentBloc addBloc;

  @override
  void initState() {
    AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);
    super.initState();
    SetBuilder<String> set = SetBuilder<String>();
    set.add(authenticationBloc.currentUser.uid);
    _league = LeagueOrTournamentBuilder()
      ..type = widget.type
      ..name = ""
      ..shortDescription = ""
      ..longDescription = ""
      ..adminsUids = set;
    addBloc = AddLeagueOrTournamentBloc(
        coordinationBloc: BlocProvider.of<CoordinationBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    addBloc.close();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  bool _leaveCurrentState(bool backwards) {
    switch (_currentStep) {
      case 0:
        leagueStepState = StepState.editing;
        createStepStage = StepState.disabled;

        if (!_formState.currentState.validate()) {
          _formState.currentState.autovalidate = true;
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
          ClubBloc clubBloc = BlocProvider.of<ClubBloc>(context);
          if (clubBloc.state.clubs.values.any((Club club) => club.isAdmin())) {
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
    Messages messages = Messages.of(context);

    return BlocProvider(
      create: (BuildContext context) => addBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(messages.title),
        ),
        body: Builder(
          builder: (BuildContext context) => BlocListener(
            cubit: BlocProvider.of<AddLeagueOrTournamentBloc>(context),
            listener: (BuildContext context, AddItemState state) {
              if (state is AddItemSaveFailed) {
                showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        title: new Text("Error"),
                        content: new Text("Error saving the league"),
                      );
                    });
              }
              if (state is AddItemDone) {
                Navigator.pop(context);
              }
            },
            child: BlocBuilder(
              cubit: BlocProvider.of<AddLeagueOrTournamentBloc>(context),
              builder: (BuildContext context, AddItemState state) {
                return SavingOverlay(
                  saving: state is AddItemSaving,
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
                          title: new Text(messages.league),
                          state: leagueStepState,
                          isActive: true,
                          content: new LeagueOrTournamentEditForm(
                            leagueOrTournament: _league.build(),
                            key: _formState,
                          ),
                        ),
                        new Step(
                          title: new Text(messages.create),
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
