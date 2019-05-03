import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/clubs/clubdetails.dart';
import 'package:flutter_fuse/widgets/clubs/clubmembers.dart';
import 'package:flutter_fuse/widgets/clubs/clubteams.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubDetailsScreen extends StatefulWidget {
  ClubDetailsScreen(this.clubUid);

  final String clubUid;

  @override
  ClubDetailsScreenState createState() {
    return new ClubDetailsScreenState();
  }
}

class ClubDetailsScreenState extends State<ClubDetailsScreen> {
  ClubDetailsScreenState();

  int _tabIndex = 1;
  SingleClubBloc _singleClubBloc;

  @override
  void initState() {
    super.initState();
    _singleClubBloc = SingleClubBloc(
        clubBloc: BlocProvider.of<ClubBloc>(context), clubUid: widget.clubUid);
  }

  @override
  void dispose() {
    super.dispose();
    _singleClubBloc.dispose();
  }

  Widget _buildBody(Club club) {
    if (_tabIndex == 0) {
      return new Scrollbar(
        child: new SingleChildScrollView(
          child: new ClubDetails(club),
        ),
      );
    } else if (_tabIndex == 1) {
      return new ClubTeams(club);
    }
    print("$_tabIndex");
    return new ClubMembers(club);
  }

  void _select(String value) {
    if (value == "addadmin") {
      Navigator.pushNamed(context, "AddClubMember/" + widget.clubUid);
    } else if (value == "addteam") {
      Navigator.pushNamed(context, "AddClubTeam/" + widget.clubUid);
    } else if (value == "editclub") {
      Navigator.pushNamed(context, "EditClub/" + widget.clubUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _singleClubBloc,
      listener: (BuildContext context, SingleClubState state) {
        if (state is SingleClubDeleted) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder(
          bloc: _singleClubBloc,
          builder: (BuildContext context, SingleClubState state) {
            String title;
            if (state is SingleClubDeleted) {
              title = Messages.of(context).loading;
            } else {
              title = state.club.name;
            }
            List<Widget> actions = [];
            if (state.club.isAdmin()) {
              actions.add(
                new PopupMenuButton<String>(
                  onSelected: _select,
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                        value: "editclub",
                        child: new Text(Messages.of(context).editbuttontext),
                      ),
                      new PopupMenuItem<String>(
                        value: "addteam",
                        child: new Text(Messages.of(context).addteam),
                      ),
                      new PopupMenuItem<String>(
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

            return Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: actions,
              ),
              bottomNavigationBar: new BottomNavigationBar(
                onTap: (int index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
                currentIndex: _tabIndex,
                items: <BottomNavigationBarItem>[
                  new BottomNavigationBarItem(
                    icon: const Icon(Icons.gamepad),
                    title: new Text(Messages.of(context).clubdetails),
                  ),
                  new BottomNavigationBarItem(
                    icon: const Icon(Icons.people),
                    title: new Text(Messages.of(context).teams),
                  ),
                  new BottomNavigationBarItem(
                    icon: const Icon(Icons.flag),
                    title: new Text(Messages.of(context).members),
                  ),
                ],
              ),
              body: theBody,
            );
          }),
    );
  }
}
