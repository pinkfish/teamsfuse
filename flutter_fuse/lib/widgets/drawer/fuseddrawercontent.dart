import 'package:flutter/material.dart';

import 'fuseddrawerheader.dart';

class FusedDrawerContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      new FusedDrawerHeader(),
    ];
    return new ListView(children: children);
  }
}