import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentname.dart';
import 'package:flutter_fuse/widgets/leagueortournament/leagueortournamentdetails.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addseasondialog.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/leagueortournament/addinvitetoleaguedialog.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LeagueScreen extends StatelessWidget {
  final String leagueUid;

  LeagueScreen(this.leagueUid);

  void _doAction(BuildContext context, String action) async {
    if (action == "season") {
      _addSeason(context);
    }
    if (action == "admin") {
      AddInviteToLeagueDialog.showAddLeagueOrTournamentInviteDialog(
          context, UserDatabaseData.instance.leagueOrTournments[leagueUid]);
    }
    if (action == "image") {
      File imgFile = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
      if (imgFile != null) {
        LeagueOrTournament league =
            await UserDatabaseData.instance.getLegueOrTournament(leagueUid);
        UserDatabaseData.instance.updateModel
            .updateLeagueImage(league, imgFile);
      }
    }
    if (action == "edit") {
      Navigator.pushNamed(context, "/League/Edit/" + leagueUid);
    }
  }

  void _addSeason(BuildContext context) {
    AddSeasonDialog.showSeasonDialog(context, leagueUid);
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton fab;
    List<Widget> actions = <Widget>[];
    if (UserDatabaseData.instance.leagueOrTournments.containsKey(leagueUid)) {
      print(
          'league stuff ${UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()}');
      if (UserDatabaseData.instance.leagueOrTournments[leagueUid].isAdmin()) {
        actions.add(
          new PopupMenuButton<String>(
            onSelected: (String str) => _doAction(context, str),
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
                  child: new Text(Messages.of(context).editimagebutton),
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
    return new Scaffold(
      appBar: new AppBar(
        title: new LeagueOrTournamentName(leagueUid),
        actions: actions,
    ),
      drawer: new FusedDrawer(DrawerMode.league),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: LeagueOrTournamentDetails(leagueUid),
        ),
      ),
    );
  }
}
