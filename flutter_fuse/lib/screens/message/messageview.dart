import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';

class ShowMessageScreen extends StatelessWidget {
  final String messageUid;

  ShowMessageScreen({this.messageUid});

  void _archiveMessage(Context context) {

  }

  Widget _showMessage(BuildContext context) {
    Messages messages = Messages.of(context);
    Message mess = UserDatabaseData.instance.messages[messageUid];
    List<Widget> kids = [];
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

    List<Widget> players = [];
    mess.recipients.forEach((String id, MessageRecipient rec) {
      players.add(
        new ListTile(
          leading: const Icon(Icons.person),
          title: new Text(rec.name),
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
            onPressed: _archiveMessage,
            child: new Text(messages.archivemessage),
            textColor: Theme.of(context).accentColor,
          ),
          new FlatButton(
            onPressed: _deleteMessage,
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

    return new SingleChildScrollView(
      child: new Column(
        children: kids,
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
