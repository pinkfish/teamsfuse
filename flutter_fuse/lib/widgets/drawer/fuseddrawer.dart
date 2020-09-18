import 'package:flutter/material.dart';

import 'fuseddrawercontent.dart';

///
/// The mode for the drawer and how to display it.
///
enum DrawerMode {
  /// Show the game list in the drawer
  gameList,

  /// Show the league in the drawer.
  league,
}

///
/// The drawer to display in the ux.
///
class FusedDrawer extends StatelessWidget {
  /// Constructor.
  FusedDrawer(this.mode);

  /// The mode the drawer displays in.
  final DrawerMode mode;

  @override
  Widget build(BuildContext context) {
    return Drawer(child: FusedDrawerContent(mode: mode));
  }
}
