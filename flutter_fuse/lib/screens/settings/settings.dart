import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';

class SettingsScreen extends StatefulWidget {

  @override
  SettingsScreenState createState() {
    return new SettingsScreenState();
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Messages.of(context).title),
      ),
      body: new Center(
          child: new Text('fluffy')
      ),
    );
  }
}