import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/messages.dart';

///
/// Shows a nifty loading message for bits of the app.
///
class LoadingWidget extends StatelessWidget {
  LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(Messages.of(context).loading,
          style: Theme.of(context).textTheme.headline4),
      CircularProgressIndicator(),
    ]);
  }
}
