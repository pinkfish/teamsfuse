import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';

class HomeScreen extends StatelessWidget {
  _onPressed() {
    print("button clicked");
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
            child: new Text('fluff')
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _onPressed,
          tooltip: 'Increment',
          child: new Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
  }
}

