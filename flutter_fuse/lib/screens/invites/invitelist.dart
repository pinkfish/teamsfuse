import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/invites/deleteinvitedialog.dart';

// Shows the current invites pending for this user.
class InviteListScreen extends StatefulWidget {
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
    bool result = await deleteInviteDialog(this.context, invite);
    if (result) {
      if (invite is InviteToTeam) {
        Navigator.pop(context);
      }
    }
  }

  void _addInviteToTeam(Invite invite) {
    Navigator.pushNamed(context, "AddInviteToTeam/" + invite.uid);
  }

  void _addInviteToPlayer(Invite invite) {
    Navigator.pushNamed(context, "AddInviteToPlayer/" + invite.uid);
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
            messages.teamandseason(invite.teamName, invite.seasonName)),
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
  
  Card _buildInviteToPlayer(InviteToPlayer invite) {
    ThemeData theme = Theme.of(context);
    return new Card(
      child: new ListTile(
        leading: new IconButton(
          icon: const Icon(Icons.add),
          color: theme.accentColor,
          onPressed: () {
            _addInviteToPlayer(invite);
          },
        ),
        title: new Text(invite.playerName),
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
    List<Widget> invites = new List<Widget>();
    UserDatabaseData.instance.invites.forEach((String key, Invite invite) {
      if (invite is InviteToTeam) {
        invites.add(_buildInviteToTeam(invite));
      }
      if (invite is InviteToPlayer) {
        invites.add(_buildInviteToPlayer(invite));
      }
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
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
