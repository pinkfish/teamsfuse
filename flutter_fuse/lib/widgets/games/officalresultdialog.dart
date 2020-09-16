import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:fusemodel/fusemodel.dart';

import 'results/officalresultdetails.dart';

class OfficialResultDialog extends StatelessWidget {
  OfficialResultDialog(this._game);

  final GameSharedData _game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
