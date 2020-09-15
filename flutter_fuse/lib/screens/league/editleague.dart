import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamenteditform.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../widgets/blocs/singleleagueortournamentprovider.dart';

class EditLeagueScreen extends StatefulWidget {
  EditLeagueScreen(this.leagueOrTournamentUid);

  final String leagueOrTournamentUid;

  @override
  State createState() {
    return _EditLeagueScreenState();
  }
}

class _EditLeagueScreenState extends State<EditLeagueScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<LeagueOrTournamentEditFormState> _formState =
      new GlobalKey<LeagueOrTournamentEditFormState>();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _savePressed(
      BuildContext context, SingleLeagueOrTournamentBloc bloc) async {
    if (!_formState.currentState.validate()) {
      _formState.currentState.autovalidate = true;
      setState(() {});
      _showInSnackBar(Messages.of(context).formerror);
      return;
    }
    _formState.currentState.save();
    LeagueOrTournamentBuilder league =
        _formState.currentState.finalLeagueOrTournamentResult;

    if (league != null) {
      File imageFile = _formState.currentState.imageFile;
      _saving = true;
      bloc.add(SingleLeagueOrTournamentUpdate(
          leagueOrTournament: league.build(), includeMembers: false));
      if (imageFile != null) {
        bloc.add(SingleLeagueOrTournamentUpdateImage(image: imageFile));
      }
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return SingleLeagueOrTournamentProvider(
      leagueUid: widget.leagueOrTournamentUid,
      builder: (BuildContext context, SingleLeagueOrTournamentBloc bloc) =>
          Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(messages.title),
        ),
        body: BlocListener(
          cubit: bloc,
          listener:
              (BuildContext context, SingleLeagueOrTournamentState state) {
            if (state is SingleLeagueOrTournamentDeleted) {
              Navigator.pop(context);
            } else if (_saving && state is SingleLeagueOrTournamentLoaded) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder(
            cubit: bloc,
            builder:
                (BuildContext context, SingleLeagueOrTournamentState state) {
              return SavingOverlay(
                saving: state is SingleLeagueOrTournamentSaving,
                child: new Container(
                  padding: new EdgeInsets.all(5.0),
                  child: new SavingOverlay(
                    saving: state is SingleLeagueOrTournamentSaving,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: new LeagueOrTournamentEditForm(
                          leagueOrTournament: bloc.state.league,
                          key: _formState,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => _savePressed(context, bloc),
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
