import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/handsandtrophy.dart';

///
/// Create a nifty display with a search box.
///
class PublicHomeScreen extends StatelessWidget {
  final String query;

  PublicHomeScreen(this.query);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: HandsAndTrophy(),
        title: Text(Messages.of(context).loading),
      ),
    );
  }
}
