import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/byusername.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';

import 'dialog/deleteinvite.dart';

///
/// Shows the invite the team screen.
///
class AcceptInviteToTeamScreen extends StatefulWidget {
  AcceptInviteToTeamScreen(this._inviteUid);

  final String _inviteUid;

  @override
  _AcceptInviteToTeamScreenState createState() {
    return new _AcceptInviteToTeamScreenState();
  }
}

class _AcceptInviteToTeamScreenState extends State<AcceptInviteToTeamScreen> {
  Set<String> _checked;
  Map<String, String> _data;
  Map<String, String> _original = <String, String>{};
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Map<String, String> _current = <String, String>{};
  Map<String, Relationship> _relationship = <String, Relationship>{};
  Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  SingleInviteBloc _singleInviteBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Default to empty.
    _checked = new Set<String>();
    _data = <String, String>{};
    _singleInviteBloc = SingleInviteBloc(
        inviteBloc: BlocProvider.of<InviteBloc>(context),
        inviteUid: widget._inviteUid,
        teamBloc: BlocProvider.of<TeamBloc>(context));
  }

  @override
  void dispose() {
    super.dispose();
    _singleInviteBloc.dispose();
  }

  void _showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _onChangedPlayer(String name, String uid) {
    setState(() {
      if (uid.compareTo(SingleInviteBloc.createNew) == 0) {
        _current[name] = SingleInviteBloc.createNew;
        _data[name] = _original[name];
        if (_relationship[name] == Relationship.Me) {
          _relationship[name] = Relationship.Friend;
        }
      } else {
        AuthenticationBloc authenticationBloc =
            BlocProvider.of<AuthenticationBloc>(context);
        PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
        _current[name] = uid;
        _data[name] = authenticationBloc.currentUser.profile.displayName;
        _relationship[name] = playerBloc.currentState.players[uid]
            .users[authenticationBloc.currentUser.uid].relationship;
      }
    });
  }

  Widget _showPlayerDropdown(String name) {
    List<DropdownMenuItem<String>> dropdowns = <DropdownMenuItem<String>>[];

    String found;
    String lowerName = name.toLowerCase().trim();
    UserDatabaseData.instance.players.forEach((String uid, Player play) {
      if (play.name.toLowerCase().trim().compareTo(lowerName) == 0) {
        found = uid;
      }
      dropdowns.add(
        new DropdownMenuItem<String>(
            child: new Text(play.name), value: play.uid),
      );
    });
    dropdowns.add(
      new DropdownMenuItem<String>(
          child: new Text(Messages.of(context).createnew),
          value: SingleInviteBloc.createNew),
    );
    if (found == null) {
      found = SingleInviteBloc.createNew;
    }
    if (!_current.containsKey(name)) {
      _current[name] = found;
      AuthenticationBloc authenticationBloc =
          BlocProvider.of<AuthenticationBloc>(context);
      PlayerBloc playerBloc = BlocProvider.of<PlayerBloc>(context);
      String myUid = authenticationBloc.currentUser.uid;
      if (playerBloc.currentState.players.containsKey(found)) {
        _relationship[name] =
            playerBloc.currentState.players[found].users[myUid].relationship;
      } else {
        _relationship[name] = Relationship.Friend;
      }
    }
    return new Container(
        child: new DropdownButton<String>(
      items: dropdowns,
      onChanged: (String val) {
        _onChangedPlayer(name, val);
      },
      value: _current[name],
    ));
  }

  void _savePressed() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String, String> currentCopy = Map<String, String>.from(_current);

      currentCopy
          .removeWhere((String name, String uid) => _checked.contains(name));
      _singleInviteBloc.dispatch(SingleInviteEventAcceptInviteToTeam(
        relationship: _relationship,
        playerNameToUid: currentCopy,
      ));
      await for (SingleInviteState state in _singleInviteBloc.state) {
        if (state is SingleInviteSaveFailed) {
          _showInSnackBar(Messages.of(context).formerror);
          return;
        }
        if (state is SingleInviteLoaded) {
          break;
        }
      }
    }
  }

  Widget _buildRelationshopDropDown(String name, bool disabled) {
    List<DropdownMenuItem<Relationship>> dropdowns =
        <DropdownMenuItem<Relationship>>[];
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    Relationship.values.forEach((Relationship rel) {
      if (rel != Relationship.Me || disabled) {
        dropdowns.add(
          new DropdownMenuItem<Relationship>(
              child: new Text(messages.relationships(rel)), value: rel),
        );
      }
    });
    TextStyle textStyle = theme.textTheme.subhead;
    if (disabled) {
      textStyle = textStyle.copyWith(
        color: theme.disabledColor,
      );
    }
    print("${_relationship[name]} $_relationship");
    return new DropdownButton<Relationship>(
      items: dropdowns,
      style: textStyle,
      onChanged: disabled
          ? null
          : (Relationship val) {
              _relationship[name] = val;
            },
      value: _relationship[name],
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    List<Widget> players = <Widget>[];
    ThemeData theme = Theme.of(context);
    InviteToTeam invite = _singleInviteBloc.currentState.invite as InviteToTeam;
    invite.playerName.forEach(
      (String name) {
        if (!_controllers.containsKey(name)) {
          _controllers[name] = new TextEditingController();
        }

        players.add(
          new ListTile(
            leading: new Checkbox(
              value: _checked.contains(name),
              onChanged: (bool value) {
                setState(
                  () {
                    if (value) {
                      _checked.add(name);
                    } else {
                      _checked.remove(name);
                    }
                  },
                );
              },
            ),
            title: _showPlayerDropdown(name),
            subtitle: _current[name].compareTo(SingleInviteBloc.createNew) == 0
                ? new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildRelationshopDropDown(name, false),
                      new TextFormField(
                        controller: _controllers[name],
                        decoration: new InputDecoration(
                          labelText: messages.newplayername,
                          hintText: messages.newplayernamehint,
                        ),
                        initialValue: name,
                        onSaved: (String newName) {
                          _data[name] = newName;
                        },
                      ),
                      new ByUserNameComponent(userId: invite.sentByUid),
                    ],
                  )
                : new FocusScope(
                    node: new FocusScopeNode(),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildRelationshopDropDown(name, true),
                        new TextFormField(
                          controller: _controllers[name],
                          style: theme.textTheme.subhead.copyWith(
                            color: theme.disabledColor,
                          ),
                          decoration: new InputDecoration(
                            labelText: messages.newplayername,
                            hintText: messages.newplayernamehint,
                          ),
                          initialValue: name,
                          onSaved: (String newName) {
                            _data[name] = newName;
                          },
                        ),
                        new ByUserNameComponent(userId: invite.sentByUid),
                      ],
                    ),
                  ),
          ),
        );
      },
    );

    players.add(
      new Row(
        children: <Widget>[
          new RaisedButton(
            onPressed: _savePressed,
            child: new Text(messages.addinvite),
            color: theme.accentColor,
            textColor: Colors.white,
          ),
          new FlatButton(
            onPressed: () => showDeleteInvite(context, _singleInviteBloc),
            child: new Text(messages.deleteinvite),
          ),
        ],
      ),
    );

    return BlocProvider<SingleInviteBloc>(
      bloc: _singleInviteBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                _savePressed();
              },
              child: new Text(
                Messages.of(context).savebuttontext,
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        body: new Scrollbar(
          child: new SingleChildScrollView(
            child: BlocBuilder<SingleInviteEvent, SingleInviteState>(
              bloc: _singleInviteBloc,
              builder: (BuildContext context, SingleInviteState state) {
                if (state is SingleInviteUninitialized) {
                  // Loading.
                  return Center(child: CircularProgressIndicator());
                } else if (state is SingleInviteDeleted) {
                  // Go back!
                  Navigator.pop(context);
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (state is SingleInviteSaveFailed) {
                    _showInSnackBar(Messages.of(context).formerror);
                  }
                  InviteToTeam invite = state.invite as InviteToTeam;
                  return SavingOverlay(
                    saving: !(state is SingleInviteLoaded),
                    child: Form(
                      key: _formKey,
                      child: new Column(
                        children: <Widget>[
                              new ListTile(
                                leading: const Icon(CommunityIcons.tshirtCrew),
                                title: new Text(invite.teamName),
                                subtitle: new Text(invite.seasonName),
                              )
                            ] +
                            players,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
