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
      teams.add(_CheckboxDialogItem(
          initialValue: isOn,
          title: team.name,
          onChanged: (bool val) => val
              ? widget.details.teamUids.add(str)
              : widget.details.teamUids.remove(str)));
    });
    teams.add(ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ));
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text(messages.teamselect),
          children: teams,
        );
      },
    ).then((bool closed) {
      setState(() {});
    });
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
    List<Widget> players = <Widget>[];
    UserDatabaseData.instance.players.forEach((String str, Player player) {
      bool isOn = widget.details.playerUids.contains(str);
      players.add(_CheckboxDialogItem(
          initialValue: isOn,
          title: player.name,
          onChanged: (bool val) => val
              ? widget.details.playerUids.add(str)
              : widget.details.playerUids.remove(str)));
    });
    players.add(ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ));
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text(messages.playerselect),
          children: players,
        );
      },
    ).then((bool closed) {
      setState(() {});
    });
    ;
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
        actions: <Widget>[],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.check),
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

class _CheckboxDialogItem extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool initialValue;
  final String title;

  _CheckboxDialogItem({this.initialValue = false, this.onChanged, this.title});

  @override
  State createState() {
    return _CheckboxDialogItemState();
  }
}

class _CheckboxDialogItemState extends State<_CheckboxDialogItem> {
  bool _isOn;

  void initState() {
    super.initState();
    _isOn = widget.initialValue;
  }

  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Checkbox(
        value: _isOn,
        onChanged: (bool val) => setState(() {
              _isOn = val;
              widget.onChanged(val);
            }),
      ),
      title: Text(widget.title),
    );
  }
}
