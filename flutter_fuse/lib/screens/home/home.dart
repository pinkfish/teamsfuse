import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslist.dart';
import 'package:flutter_fuse/widgets/invites/invitecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/fabdialer.dart';
import 'package:flutter_fuse/widgets/util/fabminimenuitem.dart';

class HomeScreen extends StatelessWidget {
  void _showInvites(BuildContext context) {
    print("showing invites");
    Navigator.pushNamed(context, "Invites");
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(Messages.of(context).title),
        ),
        drawer: new FusedDrawer(),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new SingleChildScrollView(child: new GameList()),
            ),
            new GestureDetector(
              onTap: () {
                _showInvites(context);
              },
              child: new InviteCard(),
            ),
          ],
        ),
        floatingActionButton: new FabDialer(
          menu: <FabMiniMenuItemWidget>[
            new FabMiniMenuItemWidget(
              icon:  const Icon(Icons.calendar_today),
              fabColor: Colors.blueAccent,
              text: messages.addevent,
              onPressed: () => Navigator.pushNamed(context, "AddEvent"),
            ),
            new FabMiniMenuItemWidget(
              icon:  const Icon(Icons.people),
              fabColor: Colors.blueGrey,
              text: messages.addtraining,
              onPressed: () => Navigator.pushNamed(context, "AddTraining"),
            ),
            new FabMiniMenuItemWidget(
              icon: const Icon(Icons.gamepad),
              fabColor: theme.accentColor,
              text: messages.addgame,
              onPressed: () => Navigator.pushNamed(context, "AddGame"),
            ),
          ],
          color: theme.accentColor,
          icon: new Icon(Icons.add),
        ));
  }
}
