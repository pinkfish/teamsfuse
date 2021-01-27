import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/widgets/util/loading.dart';
import 'package:fusemodel/blocs.dart';

import '../../services/messages.dart';
import '../../widgets/blocs/singleteamprovider.dart';
import '../../widgets/teams/teamdetails.dart';
import '../../widgets/teams/teamopponents.dart';
import '../../widgets/teams/teamplayers.dart';
import '../../widgets/teams/teamsettings.dart';

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

  Widget _buildBody(SingleTeamBloc singleTeamBloc) {
    if (_tabIndex == 0) {
      return Scrollbar(
        child: SingleChildScrollView(
          child: TeamDetails(widget.teamUid),
        ),
      );
    } else if (_tabIndex == 2) {
      return TeamOpponents(singleTeamBloc);
    } else if (_tabIndex == 3) {
      return TeamSettings(widget.teamUid);
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
      // Show a dialog and then delete it!
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
    FloatingActionButton fab;
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
                      value: "settings",
                      child: Text(Messages.of(context).settings),
                    ),
                    PopupMenuItem<String>(
                      value: "club",
                      child: Text(Messages.of(context).club),
                    ),
                    PopupMenuItem<String>(
                      value: 'archive',
                      child: Text(Messages.of(context).archiveteam),
                    )
                  ];
                },
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                Messages.of(context).titlewith(singleTeamBloc.state.team.name),
              ),
              actions: actions,
            ),
            bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
                currentIndex: _tabIndex,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.gamepad),
                    title: Text(Messages.of(context).details),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.people),
                    title: Text(Messages.of(context).players),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.flag),
                    title: Text(Messages.of(context).opponent),
                  ),
                ]),
            floatingActionButton: BlocBuilder(
              cubit: singleTeamBloc,
              builder: (context, state) {
                if (state.isAdmin() && _tabIndex == 0) {
                  fab = FloatingActionButton(
                    onPressed: () => _onEditTeam(context),
                    child: Icon(Icons.edit),
                  );
                  return fab;
                }
                return Text("");
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: _buildBody(singleTeamBloc),
          );
        },
      ),
    );
  }
}
