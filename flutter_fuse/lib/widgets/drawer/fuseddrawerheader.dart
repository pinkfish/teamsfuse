import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/authentication.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';

class FusedDrawerHeader extends StatefulWidget {
  @override
  FusedDrawerHeaderState createState() {
    return new FusedDrawerHeaderState();
  }
}

class FusedDrawerHeaderState extends State<FusedDrawerHeader> {
  UserData user;
  StreamSubscription<UserData> streamListen;

  FusedDrawerHeaderState() {
    streamListen = UserAuth.instance.onAuthChanged().listen((UserData data) {
      setState(() {
        this.user = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose header');
    if (streamListen != null) {
      streamListen.cancel();
    }
  }

  void _showProfile() {
    Navigator.pushNamed(context, "Profile");
  }

  @override
  Widget build(BuildContext context) {
    return new UserAccountsDrawerHeader(
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new AssetImage('assets/images/banner.jpg'),
            fit: BoxFit.cover),
      ),
      currentAccountPicture: const CircleAvatar(
        backgroundImage: const AssetImage(
          "assets/images/defaultavatar2.png",
        ),
      ),
      onDetailsPressed: _showProfile,
      accountName: new Text(
          user != null ? user.profile.displayName : Messages.of(context).unknown),
      accountEmail:
          new Text(user != null ? user.email : Messages.of(context).unknown),
    );
  }
}
