import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

// Shows the current invites pending for this user.
class InviteListScreen extends StatefulWidget {
  @override
  InviteListScreenState createState() {
    return new InviteListScreenState();
  }
}

class InviteListScreenState extends State<InviteListScreen> {
  StreamSubscription<UpdateReason> _stream;
  List<Invite> _invites;

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
    Messages mess = Messages.of(context);

    bool result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: new AlertDialog(
        title: new Text(mess.deleteinvite),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text(mess.confirmdelete(invite)),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              // Do the delete.
              Navigator.of(context).pop(true);
            },
          ),
          new FlatButton(
            child:
                new Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    );
    if (result) {
      await invite.firestoreDelete();
      Navigator.pop(context);
    }
  }

  void _addInvite(Invite invite) {
    Navigator.pushNamed(context, "AddInvite/" + invite.uid);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> invites = new List<Widget>();
    ThemeData theme = Theme.of(context);
    UserDatabaseData.instance.invites.forEach((String key, Invite invite) {
      invites.add(
        new Card(
          child: new ListTile(
            leading: new IconButton(
              icon: const Icon(Icons.add),
              color: theme.accentColor,
              onPressed: () {
                _addInvite(invite);
              },
            ),
            title: new Text(invite.teamName + ' ' + invite.seasonName),
            subtitle: new Row(
              children: invite.playerName.map((String name) {
                return new Chip(
                    backgroundColor: Colors.lightBlueAccent,
                    label: new Text(name));
              }).toList(),
            ),
            trailing: new IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deleteInvite(invite);
              },
            ),
          ),
        ),
      );
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: invites,
        ),
      ),
    );
  }
}
