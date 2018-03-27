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
        actions: <Widget>[
          new FlatButton(
            onPressed: () => this._newMessage(context),
            child: new Text(
              Messages.of(context).newbuttontext,
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new MessageList(),
    );
  }
}
