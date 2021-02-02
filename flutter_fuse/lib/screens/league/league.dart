import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import 'package:image_picker/image_picker.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/blocs/singleleagueortournamentprovider.dart';
import '../../widgets/drawer/fuseddrawer.dart';
import '../../widgets/leagueortournament/addinvitetoleaguedialog.dart';
import '../../widgets/leagueortournament/addseasondialog.dart';
import '../../widgets/leagueortournament/leagueortournamentdetails.dart';
import '../../widgets/leagueortournament/leagueortournamentname.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// The details of the league.
///
class LeagueScreen extends StatelessWidget {
  /// Constructor.
  LeagueScreen(this.leagueUid);

  /// The league to display.
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
      var imgFile = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
      if (imgFile != null) {
        bloc.add(SingleLeagueOrTournamentUpdateImage(image: imgFile));
      }
    }
    if (action == "edit") {
      Navigator.pushNamed(context, "/League/Edit/$leagueUid");
    }
  }

  void _addSeason(BuildContext context, SingleLeagueOrTournamentBloc bloc) {
    AddSeasonDialog.showSeasonDialog(context, bloc);
  }

  @override
  Widget build(BuildContext context) {
    return SingleLeagueOrTournamentProvider(
      leagueUid: leagueUid,
      builder: (context, bloc) => BlocBuilder(
          cubit: bloc,
          builder: (context, state) {
            FloatingActionButton fab;
            var actions = <Widget>[];
            if (state is SingleLeagueOrTournamentDeleted) {
              Navigator.pop(context);
            } else {
              print('league stuff ${state.league}');
              if (state.league.isAdmin()) {
                actions.add(
                  PopupMenuButton<String>(
                    onSelected: (str) => _doAction(context, str, bloc),
                    itemBuilder: (context) {
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
