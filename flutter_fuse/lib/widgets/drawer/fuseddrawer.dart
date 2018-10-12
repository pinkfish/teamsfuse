import 'package:flutter/material.dart';

import 'fuseddrawercontent.dart';

enum DrawerMode {
  gameList,
  league,
}


///
/// The drawer to display in the ux.
///
class FusedDrawer extends StatelessWidget {
  final DrawerMode mode;
  FusedDrawer(this.mode);

  @override
  Widget build(BuildContext context) {
    return new Drawer(child: new FusedDrawerContent(mode: mode));
  }
}
