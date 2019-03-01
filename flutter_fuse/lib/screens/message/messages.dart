import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/messages/messagelist.dart';

class MessagesScreen extends StatelessWidget {
  void _newMessage(BuildContext context) {
    Navigator.pushNamed(context, "AddMessage");
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(messages.message),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _newMessage(context),
        child: const Icon(Icons.message),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: new MessageList(),
    );
  }
}
