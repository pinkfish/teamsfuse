import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import '../../widgets/clubs/clubdetails.dart';
import '../../widgets/clubs/clubmembers.dart';
import '../../widgets/clubs/clubteams.dart';

///
/// The screen showing all the details of the club.
///
class ClubDetailsScreen extends StatefulWidget {
  /// Constructor.
  ClubDetailsScreen(this.clubUid);

  /// Club id to show the details for.
  final String clubUid;

  @override
  _ClubDetailsScreenState createState() {
    return _ClubDetailsScreenState();
  }
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen> {
  int _tabIndex = 1;
  SingleClubBloc _singleClubBloc;

  @override
  void initState() {
    // If not logged in default to the tabIndex of 0.
    var bloc = BlocProvider.of<AuthenticationBloc>(context);
    if (bloc.currentUser == null) {
      _tabIndex = 0;
    }
    super.initState();
    _singleClubBloc = SingleClubBloc(
        clubBloc: BlocProvider.of<ClubBloc>(context), clubUid: widget.clubUid);
  }

  @override
  void dispose() {
    super.dispose();
    _singleClubBloc.close();
  }

  Widget _buildBody(Club club) {
    if (_tabIndex == 0) {
      return Scrollbar(
        child: SingleChildScrollView(
          child: ClubDetails(club),
        ),
      );
    } else if (_tabIndex == 1) {
      return ClubTeams(_singleClubBloc);
    }
    print("$_tabIndex");
    return ClubMembers(club);
  }

  void _select(String value) {
    if (value == "addadmin") {
      Navigator.pushNamed(context, "AddClubMember/${widget.clubUid}");
    } else if (value == "addteam") {
      Navigator.pushNamed(context, "AddClubTeam/${widget.clubUid}");
    } else if (value == "editclub") {
      Navigator.pushNamed(context, "EditClub/${widget.clubUid}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: _singleClubBloc,
      listener: (context, state) {
        if (state is SingleClubDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
          cubit: _singleClubBloc,
          builder: (context, state) {
            String title;
            if (state is SingleClubDeleted) {
              title = Messages.of(context).loading;
            } else {
              title = state.club.name;
            }
            var actions = <Widget>[];
            bool admin = state?.club?.isAdmin() ?? false;
            if (admin) {
              actions.add(
                PopupMenuButton<String>(
                  onSelected: _select,
                  itemBuilder: (context) {
                    return <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                        value: "editclub",
                        child: Text(Messages.of(context).editbuttontext),
                      ),
                      PopupMenuItem<String>(
                        value: "addteam",
                        child: Text(Messages.of(context).addteam),
                      ),
                      PopupMenuItem<String>(
                        value: 'addadmin',
                        child: Text(Messages.of(context).addadmin),
                      )
                    ];
                  },
                ),
              );
            }
            Widget theBody;
            if (state is SingleClubDeleted) {
              theBody = Center(child: CircularProgressIndicator());
            } else {
              theBody = _buildBody(state.club);
            }

            // Setup the navigation items.
            var navItems = <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.gamepad),
                label: Messages.of(context).clubdetails,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: Messages.of(context).teams,
              ),
            ];

            var bloc = BlocProvider.of<AuthenticationBloc>(context);
            if (bloc.currentUser != null) {
              navItems.add(BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                label: Messages.of(context).members,
              ));
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: actions,
              ),
              bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
                currentIndex: _tabIndex,
                items: navItems,
              ),
              body: theBody,
            );
          }),
    );
  }
}
