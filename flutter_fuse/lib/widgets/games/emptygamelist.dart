import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';

class EmptyGameList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Column(
      children: <Widget>[
        new Center(
            child: new Image(
          image: new ExactAssetImage("assets/images/abstractsport.png"),
          width: screenSize.width < screenSize.height
              ? screenSize.width - 30.0
              : screenSize.height - 30.0,
          height: screenSize.width < screenSize.height
              ? screenSize.width - 30.0
              : screenSize.height - 30.0,
        )),
        new Text(Messages.of(context).nogames),
      ],
    );
  }
}
