import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// Create a widget to display the apply play store link.
///
class GooglePlayStore extends StatelessWidget {
  final _url =
      'https://play.google.com/store/apps/details?id=com.teamfuse.flutterfuse';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          await canLaunch(_url)
              ? await launch(_url)
              : throw 'Could not launch $_url';
        },
        child: Image.asset(
          'assets/images/google-play-badge.png',
          height: 54,
        ),
      ),
    );
  }
}
