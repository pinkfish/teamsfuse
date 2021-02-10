import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';
import '../games/gametitle.dart';

///
/// Shows a nifty deleted message for bits of the app.
///
class DeletedWidget extends StatelessWidget {
  /// If we should show the app bar in the deleted widget.
  final bool showAppBar;

  /// The game to display, if we have an app bar.
  final Game game;

  /// Creates the deleted widget with stuff.
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
