import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Nice round button to display on the screen.
///
class RoundButton extends StatelessWidget {
  /// The size of the button
  final double size;
  /// The widget to render inside the button
  final Widget child;
  /// What to do when the button is pressed.
  final Function onPressed;
  /// Color of the border of the button
  final Color borderColor;
  /// Padding aeround the button
  final double padding;
  /// Padding inside the button
  final double innerPadding;
  /// The max height of the button
  final double maxHeight;

  /// Create the round button.
  RoundButton(
      {this.size = 20.0,
        this.child,
        this.onPressed,
        this.borderColor,
        this.padding = 5.0,
        this.innerPadding = 2.0,
        this.maxHeight = 40.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: FlatButton(
          child: SizedBox(
            width: size - padding - innerPadding,
            height: min(size - padding - innerPadding, maxHeight),
            child: FittedBox(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    return child;
                  }),
            ),
          ),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular((size - padding) / 2),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }
}