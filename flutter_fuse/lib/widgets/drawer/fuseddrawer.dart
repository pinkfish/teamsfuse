import 'package:flutter/material.dart';

import 'fuseddrawercontent.dart';

class FusedDrawer extends StatefulWidget {
  FusedDrawer();

  @override
  _FusedDrawerState createState() => new _FusedDrawerState();
}

class _FusedDrawerState extends State<FusedDrawer> {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
        child: new FusedDrawerContent()
      );
  }
}