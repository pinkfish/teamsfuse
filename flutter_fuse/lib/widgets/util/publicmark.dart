import 'package:flutter/material.dart';

import '../../services/messages.dart';

///
/// Create a small mark on a box/widget to make it as public.
///
class PublicMark extends StatelessWidget {
  /// To show the public label, or not.
  final bool isPublic;

  /// The child widget.
  final Widget child;

  /// The location of the banner.
  final BannerLocation location;

  /// Clipper to use for the clip rect.
  final CustomClipper<Rect> clipper;

  /// How the clipping should happen.
  final Clip clipBehavior;

  /// Create the public mark.
  PublicMark({
    @required this.isPublic,
    @required this.child,
    this.clipper,
    this.clipBehavior = Clip.hardEdge,
    this.location = BannerLocation.topStart,
  });

  @override
  Widget build(BuildContext context) {
    if (isPublic) {
      return ClipRect(
        clipper: clipper,
        clipBehavior: clipBehavior,
        child: Banner(
          message: Messages.of(context).public,
          location: location,
          color: Colors.blue,
          child: child,
        ),
      );
    }
    return child;
  }
}

class OverflowClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, 100, 100);
  }

  @override
  bool shouldReclip(OverflowClipper oldClipper) => false;
}
