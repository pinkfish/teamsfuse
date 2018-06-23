import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

class FilterHomeDialog extends StatefulWidget {
  final FilterDetails details;

  FilterHomeDialog(this.details);

  @override
  _FilterHomeDialogState createState() {
    return new _FilterHomeDialogState();
  }
}

class _FilterHomeDialogState extends State<FilterHomeDialog> {
  void _openTeamListWithCheckbox() {
    Messages messages = Messages.of(context);
    List<Widget> teams = <Widget>[];
    UserDatabaseData.instance.teams.forEach((String str, Team team) {
      bool isOn = widget.details.teamUids.contains(str);
      teams.add(
        new ListTile(
          leading: new Checkbox(
            value: isOn,
            onChanged: (bool val) => val
                ? widget.details.teamUids.add(str)
                : widget.details.teamUids.remove(str),
          ),
          title: new Text(team.name),
        ),
      );
    });
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text(messages.teamselect),
          children: teams,
        );
      },
    );
  }

  Widget _showTeamPicker() {
    Messages messages = Messages.of(context);
    String pickerText = "";
    if (widget.details.teamUids.length == 0) {
      pickerText = messages.allteams;
    } else {
      pickerText = widget.details.teamUids
          .map((String uid) => UserDatabaseData.instance.teams[uid].name)
          .join((", "));
    }
    return new InkWell(
      child: new Row(
        children: <Widget>[
          new Text(pickerText),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
      onTap: _openTeamListWithCheckbox,
    );
  }

  void _openPlayerListWithCheckbox() {
    Messages messages = Messages.of(context);
    List<Widget> teams = <Widget>[];
    UserDatabaseData.instance.players.forEach((String str, Player player) {
      bool isOn = widget.details.playerUids.contains(str);
      teams.add(
        new ListTile(
          leading: new Checkbox(
            value: isOn,
            onChanged: (bool val) => val
                ? widget.details.playerUids.add(str)
                : widget.details.playerUids.remove(str),
          ),
          title: new Text(player.name),
        ),
      );
    });
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text(messages.teamselect),
          children: teams,
        );
      },
    );
  }

  Widget _showPlayerPicker() {
    Messages messages = Messages.of(context);
    String pickerText = "";
    if (widget.details.playerUids.length == 0) {
      pickerText = messages.everyone;
    } else {
      pickerText = widget.details.playerUids
          .map((String uid) => UserDatabaseData.instance.players[uid].name)
          .join((", "));
    }
    return new InkWell(
      child: new Row(
        children: <Widget>[
          new Text(pickerText),
          const Icon(Icons.arrow_drop_down, color: Colors.black54),
        ],
      ),
      onTap: _openPlayerListWithCheckbox,
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(messages.title),
        actions: <Widget>[
          new FlatButton(
            child: new Text(messages.savebuttontext),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            // Open up a drop down with checkboxes for teams.
            new ListTile(
              leading: const Icon(Icons.people),
              title: _showTeamPicker(),
            ),
            new ListTile(
              leading: const Icon(Icons.person),
              title: _showPlayerPicker(),
            ),
            new ListTile(
              leading: const Icon(Icons.gamepad),
              title: new DropdownButton<GameResult>(
                value: widget.details.result,
                items: <DropdownMenuItem<GameResult>>[
                  new DropdownMenuItem<GameResult>(
                    child: new Text(messages.noresult),
                    value: null,
                  ),
                  new DropdownMenuItem<GameResult>(
                    child: new Text(messages.win),
                    value: GameResult.Win,
                  ),
                  new DropdownMenuItem<GameResult>(
                    child: new Text(messages.loss),
                    value: GameResult.Loss,
                  ),
                  new DropdownMenuItem<GameResult>(
                    child: new Text(messages.tie),
                    value: GameResult.Tie,
                  ),
                  new DropdownMenuItem<GameResult>(
                    child: new Text(messages.notfinished),
                    value: GameResult.Unknown,
                  ),
                ],
                onChanged: (GameResult res) {
                  setState(() {
                    widget.details.result = res;
                  });
                },
              ),
            ),
            new ListTile(
              leading: const Icon(CommunityIcons.tshirtCrew),
              title: new DropdownButton<EventType>(
                value: widget.details.eventType,
                items: <DropdownMenuItem<EventType>>[
                  new DropdownMenuItem<EventType>(
                    child: new Text(messages.noevent),
                    value: null,
                  ),
                  new DropdownMenuItem<EventType>(
                    child: new Text(messages.gametype),
                    value: EventType.Game,
                  ),
                  new DropdownMenuItem<EventType>(
                    child: new Text(messages.trainingtype),
                    value: EventType.Practice,
                  ),
                  new DropdownMenuItem<EventType>(
                    child: new Text(messages.eventtype),
                    value: EventType.Event,
                  ),
                ],
                onChanged: (EventType ev) {
                  setState(() {
                    widget.details.eventType = ev;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
