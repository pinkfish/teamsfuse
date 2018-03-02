import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';

class FusedDrawerHeader extends StatefulWidget {
  @override
  FusedDrawerHeaderState createState() {
    return new FusedDrawerHeaderState();
  }
}

class FusedDrawerHeaderState extends State<FusedDrawerHeader> {
  UserData user;

  FusedDrawerHeaderState() {
    UserAuth.instance.onAuthChanged().listen((UserData data) {
      setState(() {
        this.user = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new UserAccountsDrawerHeader(
        decoration: new BoxDecoration(
          image: new DecorationImage(image: new AssetImage('assets/images/banner.jpg'),
            fit: BoxFit.cover
          ),
        ),
        accountName: new Text(user.displayName),
        accountEmail: new Text(user.email),
    );
  }
}