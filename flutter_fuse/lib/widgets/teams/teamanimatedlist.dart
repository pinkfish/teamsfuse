import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'teamtile.dart';

class TeamAnimatedList extends StatefulWidget {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  State createState() {
    return _TeamAnimatedListState();
  }
}

class _TeamAnimatedListState extends State<TeamAnimatedList> {
  List<Team> _currentData;
  GlobalKey<AnimatedListState> _listState = new GlobalKey<AnimatedListState>();

  void initState() {
    super.initState();
    _currentData = UserDatabaseData.instance.teams.values.toList();
    _currentData.sort((Team a, Team b) => a.compareTo(b));
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return new TeamTile(
      _currentData[index],
      popBeforeNavigate: true,
    );
  }

  void updateList(List<Team> newList) {
    List<Team> oldList = _currentData;
    _currentData = newList;

    // Re-read the list and see what changed.
    int i = 0;
    int j = 0;
    while (i < newList.length && j < oldList.length) {
      if (newList[i].uid == oldList[i].uid) {
        i++;
        j++;
      } else {
        int diff = newList[i].compareTo(oldList[i]);
        if (diff < 0) {
          i++;
          _listState.currentState.insertItem(i);
        } else {
          j++;
          _listState.currentState.removeItem(i,
              (BuildContext context, Animation<double> animation) {
            // Nailed it.
            return _AnimatedListItem(
              item: TeamTile(oldList[j]),
            );
          });
        }
      }
    }
    while (i < newList.length) {
      i++;
      _listState.currentState.insertItem(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserDatabaseData.instance.teamStream,
      builder: (BuildContext context, AsyncSnapshot<UpdateReason> reason) {
        if (UserDatabaseData.instance.teams.length == 0) {
          return Text(Messages.of(context).noteams);
        }
        List<Team> teamSorted = UserDatabaseData.instance.teams.values.toList();
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

class _AnimatedListItem extends StatelessWidget {
  const _AnimatedListItem(
      {Key key, @required this.animation, @required this.item})
      : assert(animation != null),
        assert(item != null),
        super(key: key);

  final Animation<double> animation;
  final Widget item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: item,
      ),
    );
  }
}
