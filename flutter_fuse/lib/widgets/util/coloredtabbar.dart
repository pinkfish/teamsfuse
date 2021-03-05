import 'package:flutter/material.dart';

///
/// Creates a tab bar with a specific background.
///
class ColoredTabBar extends Container implements PreferredSizeWidget {
  /// The constructor for making the tab bar.
  ColoredTabBar({this.color, this.tabBar});

  /// The color for the background.
  @override
  final Color color;

  /// The tab bar to display.
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}
