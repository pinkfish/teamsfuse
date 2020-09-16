import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'teamtile.dart';

///
/// The list of teams that animated teams in and out.  Nifty.
///
class TeamAnimatedList extends StatefulWidget {
  TeamAnimatedList({this.archived});

  final bool archived;

  @override
  State createState() {
    return _TeamAnimatedListState();
  }
}

class _TeamAnimatedListState extends State<TeamAnimatedList> {
  List<Team> _currentData = [];
  GlobalKey<AnimatedListState> _listState = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: TeamTile(
        _currentData[index].uid,
        popBeforeNavigate: true,
      ),
    );
  }

  void _updateTeams(List<Team> newTeams) {
    List<Team> oldList = _currentData;
    _currentData = newTeams;
    if (oldList == null || _listState.currentState == null) {
      //  Build the layout.
      return;
    }

    // Re-read the list and see what changed.
    int i = 0;
    int j = 0;
    while (i < _currentData.length && j < oldList.length) {
      if (_currentData[i].uid == oldList[j].uid) {
        i++;
        j++;
      } else {
        bool same = _currentData[i] == oldList[j];
        if (!same) {
          i++;
          _listState.currentState.insertItem(i);
        } else {
          print("${_listState.currentState}");
          Team myTeam = oldList[j];
          _listState.currentState.removeItem(j,
              (BuildContext context, Animation<double> animation) {
            // Nailed it.
            return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: TeamTile(
                myTeam.uid,
                popBeforeNavigate: true,
              ),
            );
          });
          oldList.removeAt(j);
        }
      }
    }
    int pos = i;
    while (i < _currentData.length) {
      i++;
      _listState.currentState.insertItem(pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      cubit: BlocProvider.of<TeamBloc>(context),
      builder: (BuildContext context, TeamState state) {
        if (state is TeamUninitialized) {
          return CircularProgressIndicator();
        } else {
          List<Team> teamSorted = state.allTeamUids
              .map((String uid) => state.getTeam(uid))
              .where((Team t) => t.archived == widget.archived)
              .toList();
          if (teamSorted.length == 0) {
            return Container(
              margin: EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
              child: Text(Messages.of(context).noteams),
            );
          }
          teamSorted.sort((Team a, Team b) => a.name.compareTo(b.name));
          _updateTeams(teamSorted);
          return AnimatedList(
            key: _listState,
            itemBuilder: _buildItem,
            initialItemCount: teamSorted.length,
            shrinkWrap: true,
          );
        }
      },
    );
  }
}
