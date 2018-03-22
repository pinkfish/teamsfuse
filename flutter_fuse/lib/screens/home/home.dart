import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslist.dart';
import 'package:flutter_fuse/widgets/invites/invitecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/fabdialer.dart';
import 'package:flutter_fuse/widgets/util/fabminimenuitem.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/widgets/home/filterhomedialog.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() {
    return new _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<UpdateReason> _subscription;
  FilterDetails _details = new FilterDetails();

  void _showInvites(BuildContext context) {
    print("showing invites");
    Navigator.pushNamed(context, "Invites");
  }

  void _showFilterDialog() async {
    await showDialog(
      context: context,
      child: new FilterHomeDialog(_details),
    );
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(messages.title),
          leading: UserDatabaseData.instance.loading
              ? new CircularProgressIndicator()
              : null,
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFilterDialog,
            )
          ],
        ),
        drawer: new FusedDrawer(),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: new SingleChildScrollView(child: new GameList(_details)),
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
              icon: const Icon(Icons.calendar_today),
              fabColor: Colors.blueAccent,
              text: messages.addevent,
              onPressed: () => Navigator.pushNamed(context, "AddEvent"),
            ),
            new FabMiniMenuItemWidget(
              icon: const Icon(Icons.people),
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

  @override
  void initState() {
    super.initState();
    _subscription = UserDatabaseData.instance.gameStream
        .listen((UpdateReason reason) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}
