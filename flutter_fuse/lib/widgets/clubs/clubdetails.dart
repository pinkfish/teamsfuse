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

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: ClubImage(
              clubUid: club.uid,
              width: (screenSize.width < 500)
                  ? 120.0
                  : (screenSize.width / 4) + 12.0,
              height: screenSize.height / 4 + 20,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.title),
            title: Text(club.name),
          ),
          ListTile(
            leading: const Icon(Icons.check),
            title: Text(
                Messages.of(context).trackattendence(club.trackAttendence)),
          )
        ],
      ),
    );
  }
}
