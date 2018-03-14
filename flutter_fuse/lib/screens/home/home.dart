import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslist.dart';
import 'package:flutter_fuse/widgets/invites/invitecard.dart';
import 'package:flutter_fuse/services/messages.dart';

class HomeScreen extends StatelessWidget {
  void _onPressed(BuildContext context) {
    Navigator.popAndPushNamed(context, "AddGame");
  }

  void _showInvites(BuildContext context) {
    print("showing invites");
    Navigator.pushNamed(context, "Invites");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      drawer: new FusedDrawer(),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new SingleChildScrollView(child: new GameList()),
          ),
          new GestureDetector(
            onTap: () { _showInvites(context); },
            child: new InviteCard(),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _onPressed(context);
        },
        tooltip: Messages.of(context).addgame,
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
