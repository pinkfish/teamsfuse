import 'package:flutter/material.dart';

///
/// Image to display the hands and trophy asset.
///
class HandsAndTrophy extends Image {
  /// Create a new hands and trophy image.
  HandsAndTrophy({double width, double height})
      : super.asset("assets/images/hands_and_trophy.png",
            height: height, width: width);
}
