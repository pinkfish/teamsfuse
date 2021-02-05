import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import 'results/officalresultdetails.dart';

///
/// Dialog to show the offical results.
///
class OfficialResultDialog extends StatelessWidget {
  /// Constructor.
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
      resizeToAvoidBottomInset : true,
      body: OfficalScoreDetails(_game),
    );
  }
}
