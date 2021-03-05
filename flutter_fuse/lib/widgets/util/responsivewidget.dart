import 'package:flutter/material.dart';

/// The responsive builder function for the widget.
typedef ResponsiveBuilder = Widget Function(BuildContext context);

///
/// The responsivewidget checks the widgets to build the one that works
/// for the specific resolution.
///
class ResponsiveWidget extends StatelessWidget {
  /// Large screen is any screen whose width is more than 1200 pixels
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1200;
  }

  /// Small screen is any screen whose width is less than 800 pixels
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }

  /// Medium screen is any screen whose width is less than 1200 pixels,
  /// and more than 800 pixels
  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800 &&
        MediaQuery.of(context).size.width < 1200;
  }

  ///
  /// The responsive widget builder.
  ///
  ResponsiveWidget({this.smallScreen, this.mediumScreen, this.largeScreen});

  /// The small screen builder for the widget.
  final ResponsiveBuilder smallScreen;

  /// The medium screen builder for the widget.
  final ResponsiveBuilder mediumScreen;

  /// The large screen builder for the widget.
  final ResponsiveBuilder largeScreen;

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (isLargeScreen(context) && largeScreen != null) {
      inner = largeScreen(context);
    } else if (isMediumScreen(context) && mediumScreen != null) {
      inner = mediumScreen(context);
    } else {
      inner = smallScreen(context);
    }
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: inner,
    );
  }
}
