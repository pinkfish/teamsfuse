import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';

///
/// Shows an overlay over the main class when it is saving with some useful
/// information, does it as a semi-transparent overlay.
///
class SavingOverlay extends StatelessWidget {
  SavingOverlay({@required bool saving, @required this.child, int quoteId})
      : _saving = saving ?? false,
        quoteId = quoteId ?? randomNum.nextInt(20000);

  final bool _saving;
  final Widget child;
  final int quoteId;

  static Random randomNum = Random.secure();

  @override
  Widget build(BuildContext context) {
    var quote = Messages.of(context).quoteforsaving(quoteId);
    return Stack(
      children: <Widget>[
        child,
        AnimatedOpacity(
          opacity: _saving ? 0.8 : 0.0,
          duration: Duration(seconds: 1),
          child: Container(
            color: Colors.white,
            // Fill the whole page, drop it back when not saving to not
            // trap the gestures.
            constraints: _saving
                ? BoxConstraints.expand()
                : BoxConstraints.tight(const Size(0.0, 0.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: quote.quote,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                SizedBox(height: 10.0),
                Text(quote.author,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontStyle: FontStyle.italic)),
                SizedBox(height: 20.0),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
