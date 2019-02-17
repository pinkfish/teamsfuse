import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubSettings extends StatefulWidget {
  ClubSettings(this._teamUid);

  final String _teamUid;

  @override
  ClubSettingsState createState() {
    return new ClubSettingsState();
  }
}

class ClubSettingsState extends State<ClubSettings> {
  Team _team;
  Club _club;
  StreamSubscription<UpdateReason> _updateStream;

  @override
  void initState() {
    super.initState();
    _team = UserDatabaseData.instance.teams[widget._teamUid];
    _updateStream = _team.thisTeamStream.listen((UpdateReason upd) {
      setState(() {
        _team = UserDatabaseData.instance.teams[widget._teamUid];
      });
    });
    if (_team.clubUid != null) {
      _updateClub(_team.clubUid);
    }
  }

  @override
  void deactivate() {
    _updateStream?.cancel();
    _updateStream = null;
    super.deactivate();
  }

  @override
  void dispose() {
    _updateStream?.cancel();
    _updateStream = null;
    super.dispose();
  }

  void _addClub() {
    Navigator.pushNamed(context, "AddClub");
  }

  void _setClub() async {
    if (UserDatabaseData.instance.clubs.length == 0) {
      showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: new Text(Messages.of(context).selectclub),
              content: new Text(Messages.of(context).noclub),
              actions: <Widget>[
                new FlatButton(
                  child:
                      new Text(MaterialLocalizations.of(context).okButtonLabel),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
    } else {
      // Show a dialog to let people select one of their clubs.
      String str = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return new SimpleDialog(
              title: new Text(Messages.of(context).selectclub),
              children: UserDatabaseData.instance.clubs.values
                  .where((Club c) => c.isAdmin())
                  .map((Club c) {
                return new SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, c.uid),
                    child: new Text(c.name));
              }).toList(),
            );
          });
      if (str != null) {
        // Update the club settings.
        _team.clubUid = str;
        _team.updateFirestore();
      }
    }
  }

  void _updateClub(String clubUid) {
    _club = UserDatabaseData.instance.clubs[clubUid];
    if (_club == null) {
      // Load it.
      UserDatabaseData.instance.getClub(clubUid).then((Club club) {
        setState(() {
          _club = club;
        });
      });
    }
  }

  List<Widget> _buildBody() {
    List<Widget> ret = <Widget>[];
    if (_team.clubUid == null) {
      ret.add(new Text(
        Messages.of(context).clubsettingdescription,
        softWrap: true,
        style: Theme.of(context).textTheme.body1.copyWith(fontSize: 20.0),
      ));
      ret.add(
        new SizedBox(
          height: 20.0,
        ),
      );
      ret.add(
        new Row(
          children: <Widget>[
            new FlatButton(
              onPressed: _setClub,
              child: new Text(
                Messages.of(context).setclub,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Theme.of(context).accentColor),
              ),
            ),
            new FlatButton(
              onPressed: _addClub,
              child: new Text(
                Messages.of(context).addclub,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Theme.of(context).accentColor),
              ),
            ),
          ],
        ),
      );
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return new Column(
      children: <Widget>[
        new Expanded(
          child: new Container(
            constraints: new BoxConstraints(),
            margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
            decoration: new BoxDecoration(color: theme.cardColor),
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildBody(),
              ),
            ),
          ),
        )
      ],
    );
  }
}
