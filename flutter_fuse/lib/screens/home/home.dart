import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuse/services/messages.dart';
import 'package:flutter_fuse/widgets/drawer/fuseddrawer.dart';
import 'package:flutter_fuse/widgets/games/gameslistcalendar.dart';
import 'package:flutter_fuse/widgets/home/filterhomedialog.dart';
import 'package:flutter_fuse/widgets/invites/invitecard.dart';
import 'package:flutter_fuse/widgets/util/fabdialer.dart';
import 'package:flutter_fuse/widgets/util/fabminimenuitem.dart';
import 'package:flutter_fuse/widgets/util/savingoverlay.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:sliver_calendar/sliver_calendar.dart';
import 'package:timezone/timezone.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() {
    return new _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
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
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Messages messages = Messages.of(context);
    TZDateTime nowTime = new TZDateTime.now(local);

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
      BlocBuilder(
          bloc: BlocProvider.of<MessagesBloc>(context),
          builder: (BuildContext context, MessagesState state) {
            return Badge(
                badgeContent: Text(
                  state.unreadMessages.isEmpty
                      ? ''
                      : state.unreadMessages.length.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () => Navigator.pushNamed(context, "Messages"),
                ));
          }),
    ];

    actions.add(BlocBuilder(
      bloc: BlocProvider.of<LoadedStateBloc>(context),
      builder: (BuildContext context, LoadedState state) {
        switch (state) {
          case LoadedState.Logout:
          case LoadedState.Loading:
          case LoadedState.SqlLoaded:
            return SizedBox(
              width: 15.0,
              height: 15.0,
              child: new CircularProgressIndicator(
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
            );
          case LoadedState.AllLoaded:
            return SizedBox(height: 0);
          default:
            return SizedBox(height: 0);
        }
      },
    ));

    return new Scaffold(
      drawer: new FusedDrawer(DrawerMode.gameList),
      appBar: new AppBar(
        title: new Text(messages.title),
        actions: actions,
      ),
      body: BlocBuilder(
        bloc: BlocProvider.of<LoadedStateBloc>(context),
        builder: (BuildContext context, LoadedState state) {
          bool loading = false;
          switch (state) {
            case LoadedState.Logout:
            case LoadedState.Loading:
              loading = true;
              break;
            case LoadedState.SqlLoaded:
            case LoadedState.AllLoaded:
              loading = false;
              break;
          }
          return SavingOverlay(
            quoteId: quoteId,
            saving: loading,
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
                    monthHeader:
                        new AssetImage("assets/images/calendarbanner.jpg"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder(
          bloc: BlocProvider.of<TeamBloc>(context),
          builder: (BuildContext context, TeamState state) {
            return FabDialer(
              disabled: state.allTeamUids.length == 0,
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
              color: state.allTeamUids.length == 0
                  ? theme.disabledColor
                  : theme.accentColor,
              icon: new Icon(Icons.add),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    _calendarEvents = new GameListCalendarState(
        _details, _calendarState, BlocProvider.of<GameBloc>(context));
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
