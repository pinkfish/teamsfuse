import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/form/teampicker.dart';
import 'package:flutter_fuse/widgets/form/seasonformfield.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/ensurevisiblewhenfocused.dart';

class AddMessageScreen extends StatefulWidget {
  final String teamUid;
  final String seasonUid;
  final String playerUid;

  AddMessageScreen({this.teamUid, this.seasonUid, this.playerUid});

  @override
  AddMessageScreenState createState() {
    return new AddMessageScreenState();
  }
}

class AddMessageScreenState extends State<AddMessageScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Message _message;
  String _seasonUid;
  String _sendAs;
  List<String> _possiblePlayers = [];
  bool _allPlayers = true;
  bool _includeMyself = false;
  FocusNode _focusNodeSubject = new FocusNode();
  FocusNode _focusNodeBody = new FocusNode();

  void initState() {
    super.initState();
    _message = new Message();
    _message.teamUid = widget.teamUid;
    _message.subject = '';
    _message.message = '';
    _seasonUid = widget.seasonUid;
    if (widget.playerUid != null) {
      Map<String, MessageRecipient> recips = {};
      Season season =
          UserDatabaseData.instance.teams[_message.teamUid].seasons[_seasonUid];

      SeasonPlayer player = season.players.firstWhere(
          (SeasonPlayer player) => player.playerUid == widget.playerUid);
      if (player != null) {
        recips[widget.playerUid] = new MessageRecipient(
          playerId: widget.playerUid,
          name: player.displayName,
        );
      }
      _message.recipients = recips;
      _setupSendAs();
    } else {
      _message.recipients = {};
    }
  }

  void _setupSendAs() {
    _possiblePlayers = [];
    // Find the intersection of team and player.
    UserDatabaseData
        .instance.teams[_message.teamUid].seasons[_seasonUid].players
        .forEach((SeasonPlayer play) {
      if (UserDatabaseData.instance.players.containsKey(play.playerUid)) {
        _sendAs = play.playerUid;
        _possiblePlayers.add(play.playerUid);
      }
    });
  }

  void _changeTeam(String teamUid) {
    if (teamUid != _message.teamUid) {
      setState(() {
        _message.teamUid = teamUid;
        _seasonUid = UserDatabaseData.instance.teams[teamUid].currentSeason;
        _setupSendAs();
      });
    }
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _sendMessage() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_allPlayers) {
        // Add in everyone!
        UserDatabaseData
            .instance.teams[_message.teamUid].seasons[_seasonUid].players
            .forEach((SeasonPlayer play) {
          if (_includeMyself || play.playerUid != _sendAs) {
            _message.recipients[play.playerUid] = new MessageRecipient(
              playerId: play.playerUid,
              name: play.displayName,
              state: MessageState.Unread,
            );
          }
        });
      }
      if (_message.recipients.length > 0) {
        _message.fromName = UserDatabaseData.instance.players[_sendAs].name;
        _message.fromUid = _sendAs;
        _message.timeSent = new DateTime.now().millisecondsSinceEpoch;
        _message.updateFirestore();
        Navigator.pop(context);
      } else {
        _showInSnackBar("Need to specify some recipients");
      }
    } else {
      _showInSnackBar(Messages.of(context).formerror);
    }
  }

  List<Widget> _buildPlayerPicker() {
    List<Widget> ret = [];

    if (_message.teamUid != null) {
      // Build the rest of the form.
      ret.add(
        new SeasonFormField(
            teamUid: _message.teamUid,
            initialValue: _seasonUid,
            onSaved: (String seasonUid) => _seasonUid = seasonUid),
      );
      if (_seasonUid != null &&
          UserDatabaseData.instance.teams.containsKey(_message.teamUid) &&
          UserDatabaseData.instance.teams[_message.teamUid].seasons
              .containsKey(_seasonUid)) {
        // Show who we are sending as, drop down if there is more than one
        // option.
        if (_possiblePlayers.length > 1) {
          ret.add(
            new ListTile(
              leading: const Icon(Icons.person_outline),
              title: new DropdownButton<String>(
                  value: _sendAs,
                  items: _possiblePlayers.map((String str) {
                    return new DropdownMenuItem(
                        child: new Text(
                            UserDatabaseData.instance.players[str].name),
                        value: str);
                  }).toList(),
                  onChanged: (String str) {
                    _sendAs = str;
                  }),
            ),
          );
        } else {
          ret.add(
            new ListTile(
              leading: const Icon(Icons.person_outline),
              title: new Text(UserDatabaseData.instance.players[_sendAs].name),
            ),
          );
        }
        // Show the player selection details.
        ret.add(
          new CheckboxListTile(
            secondary: const Icon(Icons.people),
            controlAffinity: ListTileControlAffinity.trailing,
            value: _allPlayers,
            onChanged: (bool newVal) => setState(() => _allPlayers = newVal),
            title: new Text(Messages.of(context).everyone),
          ),
        );
        if (_allPlayers) {
          ret.add(
            new CheckboxListTile(
              secondary: const Icon(Icons.person),
              controlAffinity: ListTileControlAffinity.trailing,
              value: _includeMyself,
              onChanged: (bool newVal) =>
                  setState(() => _includeMyself = newVal),
              title: new Text(Messages.of(context).includemyself),
            ),
          );
        } else {
          // Show the list of players with checkboxes.
          Team team = UserDatabaseData.instance.teams[_message.teamUid];
          Season season = team.seasons[_seasonUid];

          season.players.forEach((SeasonPlayer player) {
            ret.add(
              new CheckboxListTile(
                title: new Text(player.displayName +
                    " (" +
                    Messages.of(context).roleingame(player.role) +
                    ")"),
                value: _message.recipients.containsKey(player.playerUid),
                onChanged: (bool toAdd) {
                  if (toAdd) {
                    _message.recipients[player.playerUid] =
                        new MessageRecipient(
                            playerId: player.playerUid,
                            name: player.displayName);
                  } else {
                    _message.recipients.remove(player.playerUid);
                  }
                },
              ),
            );
          });
        }
        // Add in the message box itself :)
        ret.add(
          new EnsureVisibleWhenFocused(
            child: new TextFormField(
              decoration: new InputDecoration(
                icon: const Icon(Icons.subject),
                labelText: Messages.of(context).subject,
              ),
              focusNode: _focusNodeSubject,
              initialValue: _message.subject,
              onSaved: (String val) => _message.subject = val,
            ),
            focusNode: _focusNodeSubject,
          ),
        );
        ret.add(
          new EnsureVisibleWhenFocused(
            focusNode: _focusNodeBody,
            child: new TextFormField(
              decoration: new InputDecoration(
                icon: const Icon(Icons.message),
                labelText: Messages.of(context).message,
              ),
              focusNode: _focusNodeBody,
              initialValue: _message.message,
              onSaved: (String val) => _message.message = val,
            ),
          ),
        );
      }
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(messages.title),
        actions: <Widget>[
          new FlatButton(
            onPressed: this._sendMessage,
            child: new Text(
              Messages.of(context).sendmessagebuttontext,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new DropdownButtonHideUnderline(
            child: new Form(
              key: _formKey,
              child: new Column(
                children: <Widget>[
                      new ListTile(
                        leading: const Icon(CommunityIcons.tshirtcrew),
                        title: new TeamPicker(
                          onChanged: _changeTeam,
                        ),
                      ),
                    ] +
                    _buildPlayerPicker(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
