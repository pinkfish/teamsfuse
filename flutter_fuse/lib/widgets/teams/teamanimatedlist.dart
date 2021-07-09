import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/blocs.dart';
import '../../services/messages.dart';
import 'teamtile.dart';

///
/// The list of teams that animated teams in and out.  Nifty.
///
class TeamAnimatedList extends StatefulWidget {
  /// Construcot.
  TeamAnimatedList({this.archived});

  /// SHow archived teams or not.
  final bool archived;

  @override
  State createState() {
    return _TeamAnimatedListState();
  }
}

class _TeamAnimatedListState extends State<TeamAnimatedList> {
  List<Team> _currentData = [];
  final GlobalKey<AnimatedListState> _listState =
      GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: index >= _currentData.length
          ? SizedBox(height: 0)
          : TeamTile(
              _currentData[index].uid,
              popBeforeNavigate: true,
            ),
    );
  }

  void _updateTeams(List<Team> newTeams) {
    var oldList = _currentData;
    _currentData = newTeams;
    if (oldList == null || _listState.currentState == null) {
      //  Build the layout.
      return;
    }

    // Re-read the list and see what changed.
    var i = 0;
    var j = 0;
    while (i < _currentData.length && j < oldList.length) {
      if (_currentData[i].uid == oldList[j].uid) {
        i++;
        j++;
      } else {
        var same = _currentData[i] == oldList[j];
        if (!same) {
          i++;
          _listState.currentState.insertItem(i);
        } else {
          var myTeam = oldList[j];
          _listState.currentState.removeItem(j, (context, animation) {
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
    var pos = i;
    while (i < _currentData.length) {
      i++;
      _listState.currentState.insertItem(pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<TeamBloc>(context),
      builder: (context, state) {
        if (state is TeamUninitialized) {
          return CircularProgressIndicator();
        } else {
          var teamSorted = <Team>[];
          for (String uid in state.allTeamUids) {
            var t = state.getTeam(uid);
            if (t.archived == widget.archived) {
              teamSorted.add(t);
            }
          }
          if (teamSorted.isEmpty) {
            return Container(
              margin: EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
              child: Text(Messages.of(context).noTeams),
            );
          }
          teamSorted.sort((a, b) => a.name.compareTo(b.name));
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
