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

  /// Create the public mark.
  PublicMark({
    @required this.isPublic,
    @required this.child,
    this.location = BannerLocation.topStart,
  });

  @override
  Widget build(BuildContext context) {
    if (isPublic) {
      return Banner(
        message: Messages.of(context).public,
        location: location,
        child: child,
      );
    }
    return child;
  }
}
