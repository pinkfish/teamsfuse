import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fusemodel/fusemodel.dart';

///
/// Displays an image for the team.
///
class SportImage extends StatelessWidget {
  /// Constructor the team image display.  Must specify a team or teamUid or
  /// teamImage
  SportImage(
      {this.sport,
      Key key,
      this.width = 200.0,
      this.height = 200.0,
      this.color,
      this.showIcon = false,
      this.fit = BoxFit.cover,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.matchTextDirection = false})
      : super(
          key: key,
        );

  /// The enum of the sport to display.
  final Sport sport;

  /// Width of the image
  final double width;

  /// Height of the image.
  final double height;

  /// Background color.
  final Color color;

  /// How to fit the image in the space
  final BoxFit fit;

  /// How to align the image in the box.
  final AlignmentGeometry alignment;

  /// Should we repeatg in the background.
  final ImageRepeat repeat;

  /// The text direction.
  final bool matchTextDirection;

  /// If we should display an icon or not.
  final bool showIcon;

  Widget _getSportWidget() {
    switch (sport) {
      case Sport.Basketball:
        return Image.asset('assets/sports/Sport.Basketball.png');
      case Sport.Soccer:
        return Image.asset('assets/sports/Sport.Soccer.png');
      default:
        break;
    }
    return Image.asset('assets/images/defaultavatar2.png');
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: width < height ? width : height,
        height: width < height ? width : height,
        child: FittedBox(
          fit: fit,
          child: _getSportWidget(),
        ),
      ),
    );
  }
}
