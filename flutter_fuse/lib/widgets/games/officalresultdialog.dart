import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'results/officalresultdetails.dart';

class OfficialResultDialog extends StatelessWidget {
  final GameSharedData _game;

  OfficialResultDialog(this._game);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          Messages.of(context).gameend,
          overflow: TextOverflow.clip,
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomPadding: true,
      body: OfficalScoreDetails(_game),
    );
  }
}
