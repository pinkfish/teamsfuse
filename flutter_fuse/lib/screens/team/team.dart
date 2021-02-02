import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/teams/stats/teamstats.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import '../../services/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/teams/teamdetails.dart';
import '../../widgets/teams/teamopponents.dart';
import '../../widgets/teams/teamplayers.dart';

///
/// Shows all the details about a single team.
///
class TeamScreen extends StatefulWidget {
  /// Constructor.
  TeamScreen(this.teamUid);

  /// The teamUid for the team.
  final String teamUid;

  @override
  _TeamScreenState createState() {
    return _TeamScreenState();
  }
}

class _TeamScreenState extends State<TeamScreen> {
  int _tabIndex = 0;

  Widget _buildBody(SingleTeamState singleTeamState) {
    if (_tabIndex == 0) {
      return Scrollbar(
        child: SingleChildScrollView(
          child: TeamDetails(widget.teamUid),
        ),
      );
    } else if (_tabIndex == 2) {
      if (singleTeamState.team.sport == Sport.Basketball) {
        return TeamStatsWidget(
          teamUid: widget.teamUid,
        );
      }
      return TeamOpponents(widget.teamUid);
    } else if (_tabIndex == 3) {
      print("Opponentts");
      return TeamOpponents(widget.teamUid);
    }
    print("$_tabIndex");
    return TeamPlayers(widget.teamUid);
  }

  void _onEditTeam(BuildContext context) {
    Navigator.pushNamed(context, "EditTeam/${widget.teamUid}");
  }

  void _select(String choice, SingleTeamBloc singleTeamBloc) async {
    // Causes the app to rebuild with the _selectedChoice.
    setState(() {});
    if (choice == 'settings') {
      Navigator.pushNamed(context, "TeamSettings/${widget.teamUid}");
    }
    if (choice == "club") {
      Navigator.pushNamed(context, "TeamClub/${widget.teamUid}");
    }
    if (choice == 'archive') {
      singleTeamBloc
          .add(SingleTeamArchive(archive: !singleTeamBloc.state.team.archived));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleTeamProvider(
      teamUid: widget.teamUid,
      builder: (contextl, singleTeamBloc) => BlocBuilder(
        cubit: singleTeamBloc,
        builder: (context, state) {
          if (state is SingleTeamDeleted) {
            Navigator.pop(context);
            return Text(Messages.of(context).teamdeleted);
          }
          if (state is SingleTeamUninitialized) {
            return LoadingWidget();
          }
          var actions = <Widget>[];
          if (state.isAdmin() && _tabIndex == 0) {
            actions.add(
              PopupMenuButton<String>(
                onSelected: (str) => _select(str, singleTeamBloc),
                itemBuilder: (context) {
                  return <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: "edit",
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text(Messages.of(context).editbuttontext),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "settings",
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text(Messages.of(context).settings),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: "club",
                      child: ListTile(
                        leading: Icon(MdiIcons.cardsClub),
                        title: Text(Messages.of(context).club),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: ListTile(
                        leading: Icon(Icons.archive),
                        title: Text(Messages.of(context).archiveteam),
                      ),
                    )
                  ];
                },
              ),
            );
          }
          var bottomNavItems = <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.gamepad),
              label: Messages.of(context).details,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: Messages.of(context).players,
            ),
          ];
          if (state.team.sport == Sport.Basketball) {
            bottomNavItems.add(BottomNavigationBarItem(
              icon: const Icon(MdiIcons.graph),
              label: Messages.of(context).stats,
            ));
          }
          bottomNavItems.add(BottomNavigationBarItem(
            icon: const Icon(Icons.flag),
            label: Messages.of(context).opponent,
          ));
          return Scaffold(
            appBar: AppBar(
              title: Text(
                Messages.of(context).titlewith(singleTeamBloc.state.team.name),
              ),
              actions: actions,
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Theme.of(context).accentColor,
              unselectedItemColor: Colors.black,
              onTap: (index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              currentIndex: _tabIndex,
              items: bottomNavItems,
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }
}
