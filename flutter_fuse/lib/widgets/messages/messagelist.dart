import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';

class MessageList extends StatefulWidget {
  @override
  MessageListState createState() {
    return new MessageListState();
  }
}

class MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new SingleChildScrollView(
      child: new Column(
        children: <Widget>[],
      ),
    );
  }
}
