import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/invites/deleteinvitedialog.dart';

// Shows the current invites pending for this user.
class InviteListScreen extends StatefulWidget {
  static void deletePressed(BuildContext context, Invite invite) async {
    Messages mess = Messages.of(context);

    bool result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(mess.deleteinvite),
            content: new Scrollbar(
              child: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(mess.confirmdelete(invite)),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child:
                    new Text(MaterialLocalizations.of(context).okButtonLabel),
                onPressed: () {
                  // Do the delete.
                  Navigator.of(context).pop(true);
                },
              ),
              new FlatButton(
                child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
    if (result) {
      await invite.firestoreDelete();
      Navigator.pop(context);
    }
  }

  @override
  InviteListScreenState createState() {
    return new InviteListScreenState();
  }
}

class InviteListScreenState extends State<InviteListScreen> {
  StreamSubscription<UpdateReason> _stream;

  @override
  void initState() {
    _stream = UserDatabaseData.instance.inviteStream.listen(onInviteUpdate);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stream.cancel();
    _stream = null;
  }

  void onInviteUpdate(UpdateReason reason) {
    setState(() {});
  }

  void _deleteInvite(Invite invite) async {
    bool result = await deleteInviteDialog(context, invite);
    if (result) {
      if (invite is InviteToTeam) {
        Navigator.pop(context);
      }
    }
  }

  void _addInviteToTeam(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToTeam/" + invite.uid);
  }

  void _addInviteToPlayer(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToPlayer/" + invite.uid);
  }

  void _addInviteAsAdmin(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteAsAdmin/" + invite.uid);
  }

  void _addInviteToLeague(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToLeague/" + invite.uid);
  }

  void _addInviteToLeagueTeam(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToLeagueTeam/" + invite.uid);
  }

  void _addInviteToClub(Invite invite) {
    Navigator.pushNamed(context, "AcceptInviteToClub/" + invite.uid);
  }

  Card _buildInviteToTeam(InviteToTeam invite) {
    Messages messages = Messages.of(context);
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToTeam(invite);
          },
        ),
        title: new Text(
          messages.teamandseason(invite.teamName, invite.seasonName),
        ),
        subtitle: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 5.0),
            new Text(Messages.of(context).roleingame(invite.role)),
            const SizedBox(height: 5.0),
            new Row(
              children: invite.playerName.map((String name) {
                return new Chip(
                    backgroundColor: Colors.lightBlueAccent,
                    label: new Text(name));
              }).toList(),
            ),
          ],
        ),
        trailing: new IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteAsAdmin(InviteAsAdmin invite) {
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteAsAdmin(invite);
          },
        ),
        title: new Text(invite.teamName),
        subtitle: new Text(Messages.of(context).administrator),
        trailing: new IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteToClub(InviteToClub invite) {
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToClub(invite);
          },
        ),
        title: new Text(invite.clubName),
        trailing: new IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteToPlayer(InviteToPlayer invite) {
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () => _addInviteToPlayer(invite),
        ),
        onTap: () => _addInviteToPlayer(invite),
        title: new Text(Messages.of(context).followplayer(invite.playerName)),
        trailing: new IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteInvite(invite),
        ),
      ),
    );
  }

  Card _buildInviteToLeague(InviteToLeagueAsAdmin invite) {
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToLeague(invite);
          },
        ),
        title: new Text(invite.leagueName),
        subtitle: Text(Messages.of(context).leaguetournament),
        trailing: new IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  Card _buildInviteToLeagueTeam(InviteToLeagueTeam invite) {
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToLeagueTeam(invite);
          },
        ),
        title: new Text(invite.leagueTeamName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(invite.leagueName),
            Text(Messages.of(context).leaguetournament),
          ],
        ),
        trailing: new IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _deleteInvite(invite);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> invites = <Widget>[];
    if (UserDatabaseData.instance.invites.length == 0) {
      invites.add(new SizedBox(height: 50.0));
      invites.add(
        new Center(
          child: new Text(
            Messages.of(context).noinvites,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      );
    } else {
      UserDatabaseData.instance.invites.forEach((String key, Invite invite) {
        if (invite is InviteToTeam) {
          invites.add(_buildInviteToTeam(invite));
        }
        if (invite is InviteToPlayer) {
          invites.add(_buildInviteToPlayer(invite));
        }
        if (invite is InviteAsAdmin) {
          invites.add(_buildInviteAsAdmin(invite));
        }
        if (invite is InviteToClub) {
          invites.add(_buildInviteToClub(invite));
        }
        if (invite is InviteToLeagueAsAdmin) {
          invites.add(_buildInviteToLeague(invite));
        }
        if (invite is InviteToLeagueTeam) {
          invites.add(_buildInviteToLeagueTeam(invite));
        }
      });
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).invite),
      ),
      body: new Scrollbar(
        child: new SingleChildScrollView(
          child: new Column(
            children: invites,
          ),
        ),
      ),
    );
  }
}
