import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// Create a widget to display the apply play store link.
///
class ApplePlayStore extends StatelessWidget {
  final _url = 'https://apps.apple.com/us/app/team-fuse/id1374615208';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await canLaunch(_url)
            ? await launch(_url)
            : throw 'Could not launch $_url';
      },
      child: Image.asset(
        'assets/images/apple-store-badge.png',
        height: 54,
      ),
    );
  }
}
