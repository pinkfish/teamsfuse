import 'package:flutter/material.dart';

import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslistcalendar.dart';
import 'package:flutter_fuse/widgets/invites/invitecard.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/util/fabdialer.dart';
import 'package:flutter_fuse/widgets/util/fabminimenuitem.dart';
import 'package:flutter_fuse/widgets/util/communityicons.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:flutter_fuse/widgets/home/filterhomedialog.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:sliver_calendar/sliver_calendar.dart';
import 'package:timezone/timezone.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() {
    return new _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<UpdateReason> _teamSubscription;
  StreamSubscription<UpdateReason> _messagaesSubscription;
  StreamSubscription<UpdateReason> _calendarSub;
  FilterDetails _details = new FilterDetails();
  GlobalKey<CalendarWidgetState> _calendarState =
      new GlobalKey<CalendarWidgetState>();
  int quoteId = SavingOverlay.randomNum.nextInt(20000);
  GameListCalendarState _calendarEvents;

  void _showFilterDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return new FilterHomeDialog(_details);
      },
    );

    await _calendarEvents.loadGames(_details);
    setState(() {});
  }


  @override
  void didChangeDependencies() {
    _calendarEvents.state = _calendarState;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);
    IconData badge;
    TZDateTime nowTime = new TZDateTime.now(local);

    switch (UserDatabaseData.instance.unreadMessageCount) {
      case 0:
        badge = null;
        break;
      case 1:
        badge = CommunityIcons.numeric1Box;
        break;
      case 2:
        badge = CommunityIcons.numeric2Box;
        break;
      case 3:
        badge = CommunityIcons.numeric3Box;
        break;
      case 4:
        badge = CommunityIcons.numeric4Box;
        break;
      case 5:
        badge = CommunityIcons.numeric5Box;
        break;
      case 6:
        badge = CommunityIcons.numeric6Box;
        break;
      case 7:
        badge = CommunityIcons.numeric7Box;
        break;
      case 8:
        badge = CommunityIcons.numeric8Box;
        break;
      default:
        badge = CommunityIcons.numeric9PlusBox;
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
    List<Widget> actions = <Widget>[
      new IconButton(
        icon: const Icon(Icons.tune),
        onPressed: _showFilterDialog,
      ),
      new Stack(
        alignment: new Alignment(0.0, 0.0),
        children: <Widget>[
          new IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _calendarState.currentState
                .scrollToDay(new TZDateTime.now(local)),
          ),
          new Positioned(
            top: 22.0,
            right: 17.0,
            child: new Text(
              nowTime.day.toString(),
              style: theme.textTheme.button
                  .copyWith(color: Colors.white, fontSize: 11.5),
            ),
          ),
        ],
      ),
      new IconButton(
        onPressed: () => Navigator.pushNamed(context, "Messages"),
        icon: messagesIcon,
      ),
    ];
    if (!UserDatabaseData.instance.loadedDatabase &&
        !UserDatabaseData.instance.loadedFromSQL) {
      actions.add(
        new SizedBox(
          width: 15.0,
          height: 15.0,
          child: new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      );
    }

    return new Scaffold(
      drawer: new FusedDrawer(DrawerMode.GameList),
      appBar: new AppBar(
        title: new Text(messages.title),
        actions: actions,
      ),
      body: new SavingOverlay(
        quoteId: quoteId,
        saving: !UserDatabaseData.instance.loadedFromSQL &&
            !UserDatabaseData.instance.loadedDatabase,
        child: new Column(
          children: <Widget>[
            new GestureDetector(
              child: new InviteCard(),
              onTap: () => Navigator.pushNamed(context, "Invites"),
            ),
            new Expanded(
              child: new CalendarWidget(
                initialDate: new TZDateTime.now(local),
                key: _calendarState,
                getEvents: _calendarEvents.getEvents,
                buildItem: _calendarEvents.buildWidget,
                bannerHeader:
                    new AssetImage("assets/images/calendarheader.png"),
                monthHeader: new AssetImage("assets/images/calendarbanner.jpg"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new FabDialer(
        disabled: UserDatabaseData.instance.teams.length == 0,
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
        color: UserDatabaseData.instance.teams.length == 0
            ? theme.disabledColor
            : theme.accentColor,
        icon: new Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _teamSubscription = UserDatabaseData.instance.teamStream
        .listen((UpdateReason reason) => setState(() {}));
    _messagaesSubscription = UserDatabaseData.instance.messagesStream
        .listen((UpdateReason reason) => setState(() {}));
    _calendarEvents =
        new GameListCalendarState(_details, _calendarState);
    _calendarEvents.loadGames(_details).then((void d) {
      setState(() {});
    });
    _calendarSub = _calendarEvents.stream.listen((UpdateReason readon) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _teamSubscription?.cancel();
    _teamSubscription = null;
    _messagaesSubscription?.cancel();
    _messagaesSubscription = null;
    _calendarSub?.cancel();
    _calendarSub = null;
  }
}

class HeaderInviteDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      constraints:
          new BoxConstraints(minHeight: minExtent, maxHeight: maxExtent),
      child: new GestureDetector(
        child: new InviteCard(),
        onTap: () => Navigator.pushNamed(context, "Invites"),
      ),
    );
  }

  @override
  bool shouldRebuild(HeaderInviteDelegate oldDelegate) => false;
}
