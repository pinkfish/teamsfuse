import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/widgets/util/playername.dart';

class ShowMessageScreen extends StatelessWidget {
  final String messageUid;

  ShowMessageScreen({this.messageUid});

  void _archiveMessage(BuildContext context) {
    if (UserDatabaseData.instance.messages.containsKey(messageUid)) {
      if (UserDatabaseData.instance.messages[messageUid].recipients
          .containsKey(UserDatabaseData.instance.userUid)) {
        UserDatabaseData.instance.messages[messageUid]
            .recipients[UserDatabaseData.instance.userUid]
            .updateState(MessageState.Archived);
        Navigator.pop(context);
      }
    }
  }

  void _deleteMessage(BuildContext context) {
    if (UserDatabaseData.instance.messages.containsKey(messageUid)) {
      if (UserDatabaseData.instance.messages[messageUid].recipients
          .containsKey(UserDatabaseData.instance.userUid)) {
        UserDatabaseData.instance.messages[messageUid]
            .recipients[UserDatabaseData.instance.userUid]
            .firestoreDelete();
        Navigator.pop(context);
      }
    }
  }

  void _readMessage(BuildContext context) {
    if (UserDatabaseData.instance.messages.containsKey(messageUid)) {
      if (UserDatabaseData.instance.messages[messageUid].recipients
          .containsKey(UserDatabaseData.instance.userUid)) {
        if (UserDatabaseData.instance.messages[messageUid]
                .recipients[UserDatabaseData.instance.userUid].state ==
            MessageState.Unread) {
          UserDatabaseData.instance.messages[messageUid]
              .recipients[UserDatabaseData.instance.userUid]
              .updateState(MessageState.Read);
        }
      }
    }
  }

  Widget _showMessage(BuildContext context) {
    Messages messages = Messages.of(context);
    Message mess = UserDatabaseData.instance.messages[messageUid];
    List<Widget> kids = <Widget>[];
    _readMessage(context);
    kids.add(
      new ListTile(
        leading: const Icon(Icons.subject),
        title: new Text(mess.subject),
      ),
    );

    kids.add(
      new ListTile(
        leading: new TeamImage(mess.teamUid, width: 30.0),
        title: new Text(
          UserDatabaseData.instance.teams[mess.teamUid].name,
        ),
      ),
    );

    List<Widget> players = <Widget>[];
    mess.recipients.forEach((String id, MessageRecipient rec) {
      players.add(
        new ListTile(
          leading: const Icon(Icons.person),
          title: new PlayerName(playerUid: rec.playerId),
        ),
      );
    });
    kids.add(
      new ExpansionTile(
        leading: const Icon(Icons.people),
        title: new Text(messages.players),
        children: players,
      ),
    );

    kids.add(
      new ListTile(
        leading: const Icon(Icons.calendar_today),
        title: new Text(
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent) +
              " " +
              MaterialLocalizations.of(context).formatTimeOfDay(
                    new TimeOfDay.fromDateTime(mess.tzTimeSent),
                  ),
        ),
      ),
    );
    kids.add(
      new Row(
        children: <Widget>[
          new FlatButton(
            onPressed: () => _archiveMessage(context),
            child: new Text(messages.archivemessage),
            textColor: Theme.of(context).accentColor,
          ),
          new FlatButton(
            onPressed: () => _deleteMessage(context),
            child: new Text(messages.deletemessage),
            textColor: Theme.of(context).accentColor,
          ),
        ],
      ),
    );

    kids.add(
      new Divider(
        color: Colors.grey.shade700,
      ),
    );

    kids.add(
      new Container(
        alignment: Alignment.topLeft,
        margin: new EdgeInsets.only(left: 15.0),
        child: new Text(mess.message),
      ),
    );

    return new Scrollbar(child:new SingleChildScrollView(
      child: new Column(
        children: kids,
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(messages.message),
      ),
      body: _showMessage(context),
    );
  }
}
