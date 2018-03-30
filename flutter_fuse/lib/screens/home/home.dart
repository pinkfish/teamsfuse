import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslist.dart';
import 'package:flutter_fuse/widgets/invites/invitecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/fabdialer.dart';
import 'package:flutter_fuse/widgets/util/fabminimenuitem.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:flutter_fuse/services/databasedetails.dart';
import 'package:flutter_fuse/services/map.dart';
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
  StreamSubscription<UpdateReason> _teamSubscription;
  StreamSubscription<UpdateReason> _messagaesSubscription;
  FilterDetails _details = new FilterDetails();
  ScrollController _scrollController = new ScrollController();

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
    IconData badge;

    switch (UserDatabaseData.instance.unreadMessageCount) {
      case 0:
        badge = null;
        break;
      case 1:
        badge = CommunityIcons.numeric1box;
        break;
      case 2:
        badge = CommunityIcons.numeric2box;
        break;
      case 3:
        badge = CommunityIcons.numeric3box;
        break;
      case 4:
        badge = CommunityIcons.numeric4box;
        break;
      case 5:
        badge = CommunityIcons.numeric5box;
        break;
      case 6:
        badge = CommunityIcons.numeric6box;
        break;
      case 7:
        badge = CommunityIcons.numeric7box;
        break;
      case 8:
        badge = CommunityIcons.numeric8box;
        break;
      default:
        badge = CommunityIcons.numeric9plusbox;
        break;
    }
    Widget messagesIcon;
    if (badge != null) {
      messagesIcon = new Stack(
        children: <Widget>[
          const Icon(
            Icons.mail,
            color: Colors.white,
          ),
          new Positioned(
            // draw a red marble
            top: 0.0,
            right: 0.0,
            child: new Icon(
              badge,
              size: 15.0,
              color: Colors.redAccent,
            ),
          ),
        ],
      );
    } else {
      messagesIcon = const Icon(
        Icons.mail,
        color: Colors.white,
      );
    }
    List<Widget> actions = [
      new IconButton(
        icon: const Icon(Icons.tune),
        onPressed: _showFilterDialog,
      ),
      new FlatButton(
        onPressed: () => Navigator.pushNamed(context, "Messages"),
        child: messagesIcon,
      ),
    ];
    if (!UserDatabaseData.instance.loadedDatabase) {
      actions.add(
        new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.redAccent),
        ),
      );
    }

    return new Scaffold(
        drawer: new FusedDrawer(),
        body: new CustomScrollView(
          shrinkWrap: false,
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: 150.0,
              title: new Text(messages.title),
              actions: actions,
              flexibleSpace: new GestureDetector(
                onTap: () {
                  _showInvites(context);
                },
                child: new InviteCard(),
              ),
              primary: true,
            ),
            new GameList(_details),
          ],
        ),
        floatingActionButton: new FabDialer(
          menu: <FabMiniMenuItemWidget>[
            new FabMiniMenuItemWidget(
              icon: const Icon(Icons.mail),
              fabColor: Colors.lightBlueAccent,
              text: messages.newmail,
              onPressed: () => Navigator.pushNamed(context, "AddMessage"),
            ),
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
    _teamSubscription = UserDatabaseData.instance.teamStream
        .listen((UpdateReason reason) => setState(() {}));
    _messagaesSubscription = UserDatabaseData.instance.messagesStream
        .listen((UpdateReason reason) => setState(() {}));
    _scrollController.addListener(() {
      print('Scroll controller listener');
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    if (_teamSubscription != null) {
      _teamSubscription.cancel();
      _teamSubscription = null;
    }
    if (_messagaesSubscription != null) {
      _messagaesSubscription.cancel();
      _messagaesSubscription = null;
    }
  }
}
