import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
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
    if (action == 'season') {
      _addSeason(context, bloc);
    }
    if (action == 'admin') {
      await AddInviteToLeagueDialog.showAddLeagueOrTournamentInviteDialog(
          context, bloc);
    }
    if (action == 'image') {
      var imgFile = await RepositoryProvider.of<ImagePicker>(context).getImage(
          source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
      if (imgFile != null) {
        bloc.add(SingleLeagueOrTournamentUpdateImage(
            image: await imgFile.readAsBytes()));
      }
    }
    if (action == 'edit') {
      await Navigator.pushNamed(context, '/League/Edit/$leagueUid');
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
            } else if (state is SingleLeagueOrTournamentUninitialized) {
              return LoadingWidget();
            } else {
              if (state.league.isAdmin()) {
                actions.add(
                  PopupMenuButton<String>(
                    onSelected: (str) => _doAction(context, str, bloc),
                    itemBuilder: (context) {
                      return <PopupMenuItem<String>>[
                        PopupMenuItem<String>(
                          value: 'season',
                          child: Text(Messages.of(context).addSeason),
                        ),
                        PopupMenuItem<String>(
                          value: 'admin',
                          child: Text(Messages.of(context).addAdmin),
                        ),
                        PopupMenuItem<String>(
                          value: 'image',
                          child: Text(Messages.of(context).editimagebutton),
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
