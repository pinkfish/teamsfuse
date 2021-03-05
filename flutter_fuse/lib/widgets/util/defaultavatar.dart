import 'package:flutter/material.dart';

///
/// Image to display the hands and trophy asset.
///
class DefaultAvatar extends Image {
  /// Create a new default avatar image.
  DefaultAvatar({double width, double height})
      : super.asset('assets/images/defaultavatar2.png',
            height: height, width: width);
}
