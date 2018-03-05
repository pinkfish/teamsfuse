import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslist.dart';

class HomeScreen extends StatelessWidget {
  _onPressed(BuildContext context) {
    Navigator.popAndPushNamed(context, "EditGame/add");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return
      new Scaffold(
        appBar: new AppBar(
          title: new Text('Team Fuse'),
        ),
        drawer: new FusedDrawer(),
        body: new Center(
            child: new GameList()
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () { _onPressed(context); },
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
  }
}

