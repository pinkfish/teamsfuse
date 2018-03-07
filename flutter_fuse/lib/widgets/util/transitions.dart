import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

SlideTransition makeSlideTransition(
    bool fromLeft, Animation<double> animation) {
  const Offset topLeft = const Offset(0.0, 0.0);
  const Offset topRight = const Offset(1.0, 0.0);
  const Offset bottomLeft = const Offset(0.0, 1.0);
  Offset startOffset = bottomLeft;
  Offset endOffset = topLeft;
  if (fromLeft) {
    startOffset = const Offset(-1.0, 0.0);
    endOffset = topLeft;
  } else {
    startOffset = topRight;
    endOffset = topLeft;
  }

  return new SlideTransition(
      position: new Tween<Offset>(begin: startOffset, end: endOffset)
          .animate(animation));
}
