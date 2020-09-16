import 'package:flutter/material.dart';

import '../../services/messages.dart';
import '../../widgets/messages/messagelist.dart';

class MessagesScreen extends StatelessWidget {
  void _newMessage(BuildContext context) {
    Navigator.pushNamed(context, "AddMessage");
  }

  @override
  Widget build(BuildContext context) {
    Messages messages = Messages.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(messages.message),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _newMessage(context),
        child: const Icon(Icons.message),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: MessageList(),
    );
  }
}
