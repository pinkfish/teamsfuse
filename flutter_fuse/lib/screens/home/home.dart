import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusemodel/blocs.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:sliver_calendar/sliver_calendar.dart';
import 'package:timezone/timezone.dart';

import '../../services/messages.dart';
import '../../widgets/drawer/fuseddrawer.dart';
import '../../widgets/games/gameslistcalendar.dart';
import '../../widgets/home/filterhomedialog.dart';
import '../../widgets/invites/invitecard.dart';
import '../../widgets/util/fabdialer.dart';
import '../../widgets/util/fabminimenuitem.dart';
import '../../widgets/util/savingoverlay.dart';

///
/// The main home screen for the app, once the user is loaded.  Co-ordinates
/// the controls and the loading state of the app currently.
///
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<UpdateReason> _calendarSub;
  final FilterDetails _details = FilterDetails();
  final GlobalKey<CalendarWidgetState> _calendarState =
      GlobalKey<CalendarWidgetState>();
  int quoteId = SavingOverlay.randomNum.nextInt(20000);
  GameListCalendarState _calendarEvents;

  void _showFilterDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return FilterHomeDialog(_details);
      },
    );

    await _calendarEvents.loadGames(_details);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var messages = Messages.of(context);
    var nowTime = TZDateTime.now(local);

    var actions = <Widget>[
      IconButton(
        icon: const Icon(Icons.tune),
        onPressed: _showFilterDialog,
      ),
      Stack(
        alignment: Alignment(0.0, 0.0),
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () =>
                _calendarState.currentState.scrollToDay(TZDateTime.now(local)),
          ),
          Positioned(
            top: 22.0,
            right: 17.0,
            child: Text(
              nowTime.day.toString(),
              style: theme.textTheme.button
                  .copyWith(color: Colors.white, fontSize: 11.5),
            ),
          ),
        ],
      ),
      BlocBuilder(
          cubit: BlocProvider.of<MessagesBloc>(context),
          builder: (context, state) {
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
      cubit: BlocProvider.of<LoadedStateBloc>(context),
      builder: (context, state) {
        switch (state) {
          case LoadedState.Logout:
            return SizedBox(
              width: 15.0,
              height: 15.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
            );
          case LoadedState.Loading:
          case LoadedState.AllLoaded:
            return SizedBox(height: 0);
          default:
            return SizedBox(height: 0);
        }
      },
    ));

    return Scaffold(
      drawer: FusedDrawer(DrawerMode.gameList),
      appBar: AppBar(
        title: Text(messages.title),
        actions: actions,
      ),
      body: BlocBuilder(
        cubit: BlocProvider.of<LoadedStateBloc>(context),
        builder: (context, state) {
          var loading = false;
          switch (state) {
            case LoadedState.Logout:
              loading = true;
              break;
            case LoadedState.Loading:
            case LoadedState.AllLoaded:
              loading = false;
              break;
          }
          return SavingOverlay(
            quoteId: quoteId,
            saving: loading,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: InviteCard(),
                  onTap: () => Navigator.pushNamed(context, "Invites"),
                ),
                Expanded(
                  child: CalendarWidget(
                    initialDate: TZDateTime.now(local),
                    key: _calendarState,
                    getEvents: _calendarEvents.getEvents,
                    buildItem: _calendarEvents.buildWidget,
                    bannerHeader:
                        AssetImage("assets/images/calendarheader.png"),
                    monthHeader: AssetImage("assets/images/calendarbanner.jpg"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder(
          cubit: BlocProvider.of<TeamBloc>(context),
          builder: (context, state) {
            return FabDialer(
              disabled: state.allTeamUids.length == 0,
              menu: <FabMiniMenuItemWidget>[
                FabMiniMenuItemWidget(
                  icon: const Icon(Icons.mail),
                  fabColor: Colors.lightBlueAccent,
                  text: messages.newmail,
                  onPressed: () => Navigator.pushNamed(context, "AddMessage"),
                ),
                FabMiniMenuItemWidget(
                  icon: const Icon(Icons.calendar_today),
                  fabColor: Colors.blueAccent,
                  text: messages.addevent,
                  onPressed: () => Navigator.pushNamed(context, "AddEvent"),
                ),
                FabMiniMenuItemWidget(
                  icon: const Icon(Icons.people),
                  fabColor: Colors.blueGrey,
                  text: messages.addtraining,
                  onPressed: () => Navigator.pushNamed(context, "AddTraining"),
                ),
                FabMiniMenuItemWidget(
                  icon: const Icon(Icons.gamepad),
                  fabColor: theme.accentColor,
                  text: messages.addgame,
                  onPressed: () => Navigator.pushNamed(context, "AddGame"),
                ),
              ],
              color: state.allTeamUids.length == 0
                  ? theme.disabledColor
                  : theme.accentColor,
              icon: Icon(Icons.add),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    _calendarEvents = GameListCalendarState(
        _details,
        BlocProvider.of<GameBloc>(context),
        () => _calendarState?.currentState?.updateEvents());
    _calendarEvents.loadGames(_details).then((d) {
      setState(() {});
    });
    _calendarSub = _calendarEvents.stream.listen((readon) {
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
