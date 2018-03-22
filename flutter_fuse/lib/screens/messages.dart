import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/messages/messagelist.dart';

class MessagesScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(messages.message),
      ),
      body: new MessageList(),
    );
  }
}