import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addinvitetoleaguedialog.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addseasondialog.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdetails.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/blocs/singleleagueortournamentprovider.dart';

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
              bloc: bloc,
              builder:
                  (BuildContext context, SingleLeagueOrTournamentState state) {
                FloatingActionButton fab;
                List<Widget> actions = <Widget>[];
                if (state is SingleLeagueOrTournamentDeleted) {
                  Navigator.pop(context);
                } else {
                  print('league stuff ${state.leagueOrTournament}');
                  if (state.leagueOrTournament.isAdmin()) {
                    actions.add(
                      new PopupMenuButton<String>(
                        onSelected: (String str) =>
                            _doAction(context, str, bloc),
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuItem<String>>[
                            new PopupMenuItem<String>(
                              value: "season",
                              child: new Text(Messages.of(context).addseason),
                            ),
                            new PopupMenuItem<String>(
                              child: new Text(Messages.of(context).addadmin),
                              value: "admin",
                            ),
                            new PopupMenuItem<String>(
                              child: new Text(
                                  Messages.of(context).editimagebutton),
                              value: "image",
                            ),
                            new PopupMenuItem<String>(
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
                  appBar: new AppBar(
                    title: new LeagueOrTournamentName(leagueUid),
                    actions: actions,
                  ),
                  drawer: new FusedDrawer(DrawerMode.league),
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
