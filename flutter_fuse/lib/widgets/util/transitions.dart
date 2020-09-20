import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

///
/// Creates a slide transition for use in the app.
///
SlideTransition makeSlideTransition(Animation<double> animation,
    {bool fromLeft = false}) {
  var topLeft = Offset(0.0, 0.0);
  var topRight = Offset(1.0, 0.0);
  var bottomLeft = Offset(0.0, 1.0);
  var startOffset = bottomLeft;
  var endOffset = topLeft;
  if (fromLeft) {
    startOffset = const Offset(-1.0, 0.0);
    endOffset = topLeft;
  } else {
    startOffset = topRight;
    endOffset = topLeft;
  }

  return SlideTransition(
      position:
          Tween<Offset>(begin: startOffset, end: endOffset).animate(animation));
}
