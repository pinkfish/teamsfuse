import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/clubimage.dart';
import 'package:fusemodel/fusemodel.dart';

class ClubDetails extends StatelessWidget {
  ClubDetails(this.club);

  final Club club;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new SingleChildScrollView(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Center(
            child: new ClubImage(
              clubUid: club.uid,
              width: (screenSize.width < 500)
                  ? 120.0
                  : (screenSize.width / 4) + 12.0,
              height: screenSize.height / 4 + 20,
            ),
          ),
          new ListTile(
            leading: const Icon(Icons.title),
            title: new Text(club.name),
          ),
          new ListTile(
            leading: const Icon(Icons.check),
            title: new Text(
                Messages.of(context).trackattendence(club.trackAttendence)),
          )
        ],
      ),
    );
  }
}
