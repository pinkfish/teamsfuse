import 'package:flutter/material.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'dart:async';
import 'package:flutter_fuse/widgets/util/communityicons.dart';

// Shows the current invites pending for this user.
class InviteCard extends StatefulWidget {
  @override
  InviteCardState createState() {
    return new InviteCardState();
  }
}

class InviteCardState extends State<InviteCard> {
  StreamSubscription<UpdateReason> _stream;

  @override
  void initState() {
    _stream = UserDatabaseData.instance.inviteStream.listen(onInviteUpdate);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stream.cancel();
    _stream = null;
  }

  void onInviteUpdate(UpdateReason reason) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (UserDatabaseData.instance.invites.length > 0) {
      Widget card = new Card(
        color: Colors.limeAccent,
        child: new ListTile(
          leading: const Icon(CommunityIcons.emailopen),
          title: new Text(
            Messages
                .of(context)
                .invitedpeople(UserDatabaseData.instance.invites.length),
          ),
        ),
      );
      return card;
    }

    return new Container(
      child: new Text("Fluff"),
    );
  }
}
