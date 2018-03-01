import 'package:flutter/material.dart';

class FusedDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new UserAccountsDrawerHeader(
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new AssetImage('assets/images/banner.jpg'),
            fit: BoxFit.cover
          ),
        ),
        accountName: new Text('Fluffy'),
        accountEmail: new Text('pinkfishfrog@gmail.com'),
    );
  }
}