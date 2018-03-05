import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/messages.dart';

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
        accountName: new Text(user != null ? user.displayName : Messages.of(context).unknown),
        accountEmail: new Text(user != null ? user.email : Messages.of(context).unknown),
    );
  }
}