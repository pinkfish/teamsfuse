import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentprovider.dart';
import '../../widgets/leagueortournament/leagueortournamenteditform.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// Edit the league and change the details.
///
class EditLeagueScreen extends StatefulWidget {
  /// Constructor.
  EditLeagueScreen(this.leagueOrTournamentUid);

  /// The league or tournament to edit.
  final String leagueOrTournamentUid;

  @override
  State createState() {
    return _EditLeagueScreenState();
  }
}

class _EditLeagueScreenState extends State<EditLeagueScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LeagueOrTournamentEditFormState> _formState =
      GlobalKey<LeagueOrTournamentEditFormState>();

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _savePressed(
      BuildContext context, SingleLeagueOrTournamentBloc bloc) async {
    if (!_formState.currentState.validate()) {
      setState(() {});
      _showInSnackBar(Messages.of(context).formError);
      return;
    }
    _formState.currentState.save();
    var league = _formState.currentState.finalLeagueOrTournamentResult;

    if (league != null) {
      var imageFile = _formState.currentState.imageFile;
      _saving = true;
      bloc.add(SingleLeagueOrTournamentUpdate(
          leagueOrTournament: league.build(), includeMembers: false));
      if (imageFile != null) {
        bloc.add(SingleLeagueOrTournamentUpdateImage(image: imageFile));
      }
    } else {
      _showInSnackBar(Messages.of(context).formError);
    }
  }

  @override
  Widget build(BuildContext context) {
    var messages = Messages.of(context);

    return SingleLeagueOrTournamentProvider(
      leagueUid: widget.leagueOrTournamentUid,
      builder: (context, bloc) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(messages.title),
        ),
        body: BlocListener(
          bloc: bloc,
          listener: (context, state) {
            if (state is SingleLeagueOrTournamentDeleted) {
              Navigator.pop(context);
            } else if (_saving && state is SingleLeagueOrTournamentLoaded) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) {
              return SavingOverlay(
                saving: state is SingleLeagueOrTournamentSaving,
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: SavingOverlay(
                    saving: state is SingleLeagueOrTournamentSaving,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: LeagueOrTournamentEditForm(
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => _savePressed(context, bloc),
          child: const Icon(Icons.check),
        ),
      ),
    );
  }
}
