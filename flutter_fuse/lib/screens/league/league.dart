import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentprovider.dart';
import '../../widgets/drawer/fuseddrawer.dart';
import '../../widgets/leagueortournament/addinvitetoleaguedialog.dart';
import '../../widgets/leagueortournament/addseasondialog.dart';
import '../../widgets/leagueortournament/leagueortournamentdetails.dart';
import '../../widgets/leagueortournament/leagueortournamentname.dart';
import '../../widgets/util/savingoverlay.dart';

class LeagueScreen extends StatelessWidget {
  LeagueScreen(this.leagueUid);

  final String leagueUid;

  void _doAction(BuildContext context, String action,
      SingleLeagueOrTournamentBloc bloc) async {
    if (action == "season") {
      _addSeason(context, bloc);
    }
    if (action == "admin") {
      AddInviteToLeagueDialog.showAddLeagueOrTournamentInviteDialog(
          context, bloc);
    }
    if (action == "image") {
      File imgFile = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
      if (imgFile != null) {
        bloc.add(SingleLeagueOrTournamentUpdateImage(image: imgFile));
      }
    }
    if (action == "edit") {
      Navigator.pushNamed(context, "/League/Edit/" + leagueUid);
    }
  }

  void _addSeason(BuildContext context, SingleLeagueOrTournamentBloc bloc) {
    AddSeasonDialog.showSeasonDialog(context, bloc);
  }

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentProvider(
      leagueUid: leagueUid,
      builder: (BuildContext context, SingleLeagueOrTournamentBloc bloc) =>
          BlocBuilder(
              cubit: bloc,
              builder:
                  (BuildContext context, SingleLeagueOrTournamentState state) {
                FloatingActionButton fab;
                List<Widget> actions = <Widget>[];
                if (state is SingleLeagueOrTournamentDeleted) {
                  Navigator.pop(context);
                } else {
                  print('league stuff ${state.league}');
                  if (state.league.isAdmin()) {
                    actions.add(
                      PopupMenuButton<String>(
                        onSelected: (String str) =>
                            _doAction(context, str, bloc),
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              value: "season",
                              child: Text(Messages.of(context).addseason),
                            ),
                            PopupMenuItem<String>(
                              child: Text(Messages.of(context).addadmin),
                              value: "admin",
                            ),
                            PopupMenuItem<String>(
                              child: Text(Messages.of(context).editimagebutton),
                              value: "image",
                            ),
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text(Messages.of(context).editbuttontext),
                            )
                          ];
                        },
                      ),
                    );
                  }
                }

                return Scaffold(
                  appBar: AppBar(
                    title: LeagueOrTournamentName(leagueUid),
                    actions: actions,
                  ),
                  drawer: FusedDrawer(DrawerMode.league),
                  floatingActionButton: fab,
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endFloat,
                  body: SavingOverlay(
                    saving: state is SingleLeagueOrTournamentSaving,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: LeagueOrTournamentDetails(leagueUid),
                      ),
                    ),
                  ),
                );
              }),
    );
  }
}
