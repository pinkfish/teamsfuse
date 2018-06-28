import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

class ClubTeamPicker extends StatefulWidget {
  final ValueChanged<Team> onChanged;
  final String clubUid;
  final Team team;

  ClubTeamPicker({@required this.onChanged, this.clubUid, this.team});

  @override
  ClubTeamPickerState createState() {
    return new ClubTeamPickerState();
  }
}

class ClubTeamPickerState extends State<ClubTeamPicker> {
  StreamSubscription<Iterable<Team>> _teamStream;
  Club _club;

  ClubTeamPickerState();

  @override
  void dispose() {
    super.dispose();
    _teamStream?.cancel();
    _teamStream = null;
  }

  @override
  void initState() {
    super.initState();
    _refreshClub();
  }

  void _refreshClub() {
    _club = UserDatabaseData.instance.clubs[widget.clubUid];
    print('Club $_club ${widget.clubUid}');
    _teamStream?.cancel();
    _teamStream = _club?.teamStream?.listen((Iterable<Team> data) {
      print('new teams!');
      setState(() {});
      return data;
    });
  }

  @override
  void didUpdateWidget(ClubTeamPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshClub();
  }

  List<DropdownMenuItem<Team>> _buildItems() {
    List<DropdownMenuItem<Team>> ret = <DropdownMenuItem<Team>>[];
    if (_club != null && _club?.cachedTeams != null) {
      print('Teams..');
      List<Team> sorted = _club.cachedTeams.toList();
      sorted.sort();
      _club.cachedTeams.forEach((Team teamDrop) {
        ret.add(new DropdownMenuItem<Team>(
          child: new Text(teamDrop.name),
          value: teamDrop,
        ));
      });
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (_club == null) {
      inner = new ListTile(
        //trailing: const Icon(CommunityIcons.update),
        title: new Text(
          Messages.of(context).selectclub,
          style: Theme
              .of(context)
              .textTheme
              .body1
              .copyWith(color: Theme.of(context).disabledColor),
        ),
      );
    } else if (_club.cachedTeams == null) {
      inner = new ListTile(
        leading: new CircularProgressIndicator(),
        title: new Text(
          Messages.of(context).loading,
          style: Theme.of(context).textTheme.body1,
        ),
      );
    } else {
      inner = new DropdownButton<Team>(
        hint: new Text(Messages.of(context).teamselect),
        items: _buildItems(),
        value: widget.team,
        onChanged: widget.clubUid != null
            ? (Team val) {
                widget.onChanged(val);
                return val;
              }
            : null,
      );
    }
    return new InputDecorator(
      decoration: new InputDecoration(
        labelText: Messages.of(context).team,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(flex: 1, child: inner),
        ],
      ),
    );
  }
}