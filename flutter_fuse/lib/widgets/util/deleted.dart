import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuse/widgets/games/gametitle.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Shows a nifty deleted message for bits of the app.
///
class DeletedWidget extends StatelessWidget {
  final bool showAppBar;
  final Game game;

  DeletedWidget({this.showAppBar = false, this.game});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      showAppBar
          ? AppBar(
              title: game != null
                  ? GameTitle(game, null)
                  : Text(Messages.of(context).title),
            )
          : SizedBox(
              height: 0,
            ),
      Text(Messages.of(context).unknown,
          style: Theme.of(context).textTheme.headline4),
      Icon(Icons.error, size: 40.0, color: Theme.of(context).errorColor),
    ]);
  }
}
