import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

import '../../services/messages.dart';

///
/// Shows a nifty deleted message for bits of the app.
///
class DeletedWidget extends StatelessWidget {

  /// Creates the deleted widget with stuff.
  DeletedWidget();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(Messages.of(context).deleted,
          style: Theme.of(context).textTheme.headline4),
      Icon(Icons.error, size: 40.0, color: Theme.of(context).errorColor),
    ]);
  }
}
