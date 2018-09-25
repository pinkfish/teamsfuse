import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'teamtile.dart';

///
/// The list of teams that animated teams in and out.  Nifty.
///
class TeamAnimatedList extends StatefulWidget {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final bool archived;

  TeamAnimatedList({this.archived});

  @override
  State createState() {
    return _TeamAnimatedListState();
  }
}

class _TeamAnimatedListState extends State<TeamAnimatedList> {
  List<Team> _currentData;
  GlobalKey<AnimatedListState> _listState = new GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _currentData = UserDatabaseData.instance.teams.values.toList();
    _currentData.sort((Team a, Team b) => a.compareTo(b));
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: TeamTile(
        _currentData[index],
        popBeforeNavigate: true,
      ),
    );
  }

  void _updateTeams(List<Team> newTeams) {
    List<Team> oldList = _currentData;
    _currentData = newTeams;
    if (oldList == null || _listState.currentState == null) {
      //  Build the new layout.
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
        int diff = _currentData[i].compareTo(oldList[j]);
        if (diff < 0) {
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
                myTeam,
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
    return StreamBuilder<UpdateReason>(
      stream: UserDatabaseData.instance.teamStream,
      builder: (BuildContext context, AsyncSnapshot<UpdateReason> reason) {
        List<Team> teamSorted = UserDatabaseData.instance.teams.values
            .where((Team t) => t.archived == widget.archived)
            .toList();
        if (teamSorted.length == 0) {
          return Container(
            margin: EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
            child: Text(Messages.of(context).noteams),
          );
        }
        _updateTeams(teamSorted);
        teamSorted.sort((Team a, Team b) => a.compareTo(b));
        return AnimatedList(
          key: _listState,
          itemBuilder: _buildItem,
          initialItemCount: teamSorted.length,
          shrinkWrap: true,
        );
      },
    );
  }
}
