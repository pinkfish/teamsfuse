import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/util/teamimage.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';
import 'dart:async';

class MessageList extends StatefulWidget {
  @override
  MessageListState createState() {
    return new MessageListState();
  }
}

class MessageListState extends State<MessageList> {
  String _myUid = UserDatabaseData.instance.userUid;
  DateTime _dayCutoff = new DateTime.now().subtract(const Duration(days: 1));
  List<Message> _sortedList = <Message>[];

  StreamSubscription<UpdateReason> _messageStream;

  @override
  void initState() {
    super.initState();
    _sortedList = UserDatabaseData.instance.messages.values.toList();
    _sortedList.sort(
        (Message m1, Message m2) => m1.timeSent.toInt() - m2.timeSent.toInt());

    _messageStream = UserDatabaseData.instance.messagesStream
        .listen((UpdateReason reason) => setState(() {
              _sortedList = UserDatabaseData.instance.messages.values.toList();
              _sortedList.sort((Message m1, Message m2) =>
                  m1.timeSent.toInt() - m2.timeSent.toInt());
            }));
  }

  @override
  void dispose() {
    super.dispose();
    _messageStream.cancel();
  }

  Widget _buildMessage(Message mess) {
    String timeMess;
    ThemeData theme = Theme.of(context);

    if (mess.timeSent < _dayCutoff.millisecondsSinceEpoch) {
      timeMess = MaterialLocalizations
          .of(context)
          .formatTimeOfDay(new TimeOfDay.fromDateTime(mess.tzTimeSent));
    } else {
      timeMess =
          MaterialLocalizations.of(context).formatMediumDate(mess.tzTimeSent);
    }
    print('rec ${mess.recipients} $_myUid ${mess.uid}');

    return new ListTile(
      onTap: () => Navigator.pushNamed(context, "/ShowMessage/" + mess.uid),
      leading: new TeamImage(mess.teamUid, width: 30.0),
      subtitle: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Expanded(
            child: new Container(
              margin: new EdgeInsets.only(top: 3.0),
              alignment: AlignmentDirectional.centerStart,
              child: new Text(
                mess.fromName,
                style: mess.recipients[_myUid].state == MessageState.Unread
                    ? theme.textTheme.subhead
                        .copyWith(fontWeight: FontWeight.bold)
                    : theme.textTheme.subhead,
              ),
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(top: 3.0),
            alignment: AlignmentDirectional.centerEnd,
            child: new Text(
              timeMess,
            ),
          ),
        ],
      ),
      title: new Text(
        mess.subject,
        overflow: TextOverflow.clip,
        style: mess.recipients[_myUid].state == MessageState.Unread
            ? theme.textTheme.subhead.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: theme.textTheme.subhead.fontSize * 1.25)
            : theme.textTheme.subhead,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> messages = <Widget>[];
    if (_sortedList.length == 0) {
      // No messages
      return new Center(
        child: new Text(Messages.of(context).nomessages),
      );
    }
    _sortedList.forEach((Message mess) {
      messages.add(_buildMessage(mess));
    });
    return new SingleChildScrollView(
      child: new Column(
        children: messages,
      ),
    );
  }
}
